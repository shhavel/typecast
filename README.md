# TypeCast

Type casting of attributes defined in superclass or realized through method_missing.<br />
Converts string attributes with parser object (object that respond_to? :parse)<br />
or attribute of any type with type-casting method (e.g. :to_i, :to_f).

## Installation

Add this line to your application's Gemfile:

    gem 'typecast'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typecast

## Usage

```ruby
class User
  def orders_count
    "4"
  end

  def aov
    "207.56"
  end

  def created_at
    "2014-05-26T19:31:04+03:00" 
  end

  def updated_at
    "2014-05-26 19:49:59 +0300"
  end

  def expires_at 
    "26 September 2014 at 19:50:38 EEST"
  end

  def suggestions_count
    nil
  end

  def method_missing(method_name, *args, &block)
    return super unless "dynamic_created_at" == method_name.to_s
    "2014-05-27T13:19:25+03:00"
  end
end

class Customer < User
  include TypeCast

  type_cast :expires_at, DateTime # performs type casting of ancestor's instance method with object which respond_to? parse method
  type_cast :created_at, :updated_at, Time # several attributes provided at once
  type_cast :dynamic_created_at, Time # attribute that works through method_missing
  type_cast :orders_count, :suggestions_count, :to_i
  type_cast :aov, :to_f
end

customer = Customer.new
customer.expires_at # => DateTime.parse("26 September 2014 at 19:50:38 EEST")
customer.created_at # => Time.parse("2014-05-26T19:31:04+03:00")
customer.updated_at # => Time.parse("2014-05-26 19:49:59 +0300")
customer.dynamic_created_at # => Time.parse("2014-05-27T13:19:25+03:00")
customer.orders_count # => 4
customer.suggestions_count # => 0
customer.aov # => 207.56

customer.created_at_before_type_cast # => "2014-05-26T19:31:04+03:00"
customer.orders_count_before_type_cast # => "4"
```

## History :)

Gem was originally created to use with ActiveRecourse, because next stuff don't work

```ruby
class User < ActiveResource::Base
  attribute 'created_at', :time # doesn't work
  attribute 'created_at', :datetime # doesn't work

  # doesn't work
  schema do
    datetime :created_at
  end

  # doesn't work
  schema do
    time :created_at
  end
end
```

Next solution works but has some issue

```ruby
# It check all atributes and parses to DateTime all that matches datetime regexp.
ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
ActiveSupport.parse_json_times = true
```

But ruby's [DateTime.strftime](http://apidock.com/ruby/DateTime/strftime) method has minor bug: `DateTime.strftime('%Z')` [output is incorrect format](https://www.ruby-forum.com/topic/4349831)

```ruby
Time.now.strftime('%Z') # => "EEST"
DateTime.now.strftime('%Z') # => "+03:00"
```

You can monkey patch `ActiveSupport` to use `Time.parse` insted of `DateTime.parse` to avoid this issue, but it still be slower

```ruby
module ActiveSupport
  module JSON
    class << self
    private
      def convert_dates_from(data)
        case data
        when nil
          nil
        when DATE_REGEX
          begin
            Time.parse(data)
          rescue ArgumentError
            data
          end
        when Array
          data.map! { |d| convert_dates_from(d) }
        when Hash
          data.each do |key, value|
            data[key] = convert_dates_from(value)
          end
        else
          data
        end
      end
    end
  end
end
```

Among cons of the proposed solution is that you'll need add type casting to all models.<br/>
Or perhaps `type_cast` common attributes in `ActiveResource::Base`

```ruby
class ActiveResource::Base
  include TypeCast
  type_cast :created_at, :updated_at, Time
end
```

## Contributing

1. Fork it ( http://github.com/shhavel/typecast/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
