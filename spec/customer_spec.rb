require "spec_helper"
require "type_cast"
require "date"

describe Customer do
  it "performs type casting of ancestor's instance method with object which respond_to? parse method" do
    expect(subject.expires_at).to eq DateTime.parse("26 September 2014 at 19:50:38 EEST")
  end

  it "performs type casting of several attributes provided at once" do
    expect(subject.created_at).to eq Time.parse("2014-05-26T19:31:04+03:00")
    expect(subject.updated_at).to eq Time.parse("2014-05-26 19:49:59 +0300")
  end

  it "performs type casting of attribute that works through method_missing" do
    expect(subject.dynamic_created_at).to eq Time.parse("2014-05-27T13:19:25+03:00")
  end

  it "performs type casting of ancestor's instance method providing with method name which should be called on that" do
    expect(subject.orders_count).to eq 4
    expect(subject.aov).to eq 207.56
  end

  it "raises exception if last argument doesn't respont to parse method and doesn't respont to :to_sym" do
    expect { described_class.class_eval { type_cast :name, Array } }.to raise_error(ArgumentError)
  end

  it "raises exception if no arguments for type casting provided" do
    expect { described_class.class_eval { type_cast Time } }.to raise_error(ArgumentError)
  end

  it "declares a method for attribute with the *_before_type_cast suffix" do
    expect(subject.created_at_before_type_cast).to eq "2014-05-26T19:31:04+03:00"
    expect(subject.dynamic_created_at_before_type_cast).to eq "2014-05-27T13:19:25+03:00"
  end

  it "performs type casting of any value (not only String) if provided method name for type cast" do
    expect(subject.suggestions_count).to eq 0
  end
end
