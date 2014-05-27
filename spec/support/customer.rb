require_relative 'user'

class Customer < User
  include TypeCast

  type_cast :expires_at, DateTime
  type_cast :created_at, :updated_at, Time
  type_cast :orders_count, :to_i
  type_cast :aov, :to_f
  type_cast :dynamic_created_at, Time
end
