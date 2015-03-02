require "type_cast/version"

module TypeCast
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def type_cast(*args)
      caster = args.pop
      if args.empty?
        raise ArgumentError, 'Instance methods for type casting supposed to be provided (e.g. type_cast :created_at, :updated_at, Time).'
      end
      if caster.respond_to?(:parse)
        args.each do |attribute|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attribute}
              @#{attribute}_after_type_cast ||= begin
                uncasted = if defined?(super)
                  super
                else
                  method_missing(:#{attribute})
                end
                self.#{attribute}_before_type_cast = uncasted
                if uncasted.kind_of?(String)
                  #{caster}.parse(uncasted)
                else
                  uncasted
                end
              rescue
                uncasted
              end
            end
            attr_writer :#{attribute}_before_type_cast
            def #{attribute}_before_type_cast
              @#{attribute}_before_type_cast || (#{attribute}; #{attribute}_before_type_cast)
            end
          RUBY
        end
      elsif caster.respond_to?(:to_sym)
        conversion_method = caster.to_sym
        args.each do |attribute|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attribute}
              @#{attribute}_after_type_cast ||= begin
                uncasted = if defined?(super)
                  super
                else
                  method_missing(:#{attribute})
                end
                self.#{attribute}_before_type_cast = uncasted
                if uncasted.respond_to?(:#{conversion_method})
                  uncasted.__send__(:#{conversion_method})
                else
                  uncasted
                end
              rescue
                uncasted
              end
            end
            attr_writer :#{attribute}_before_type_cast
            def #{attribute}_before_type_cast
              @#{attribute}_before_type_cast || (#{attribute}; #{attribute}_before_type_cast)
            end
          RUBY
        end
      else
        raise ArgumentError, 'Type casting needs an object with parse method or method name which should be called on casted attributes. Supply it as last argument (e.g. type_cast :created_at, Time).'
      end
    end
    alias_method :typecast, :type_cast
  end
end

begin
  require 'active_resource'
  class ActiveResource::Base
    include TypeCast
    type_cast :created_at, :updated_at, Time
  end
rescue LoadError
end
