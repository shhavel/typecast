# TypeCast

Type casting of attributes defined in superclass or realized through method_missing. Works only for string attributes.

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
  type_cast :orders_count, :to_i
  type_cast :aov, :to_f
end

customer = Customer.new
customer.expires_at # => DateTime.parse("26 September 2014 at 19:50:38 EEST")
customer.created_at # => Time.parse("2014-05-26T19:31:04+03:00")
customer.updated_at # => Time.parse("2014-05-26 19:49:59 +0300")
customer.dynamic_created_at # => Time.parse("2014-05-27T13:19:25+03:00")
customer.orders_count # => 4
customer.aov # => 207.56

customer.created_at_before_type_cast # => "2014-05-26T19:31:04+03:00"
customer.orders_count_before_type_cast # => "4"
```

## Contributing

1. Fork it ( http://github.com/shhavel/typecast/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
