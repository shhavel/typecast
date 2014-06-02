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
