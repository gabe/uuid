require File.join(File.dirname(__FILE__), 'spec_helper')

describe UUID, '#initialize' do
  it 'generates a new UUID when passed no parameters' do
    UUID.new.should_not == UUID.new
  end
  
  it 'creates a UUID from a valid string representation when passed one' do
    id = UUID.new
    UUID::FORMATS.each do |name, _|
      UUID.new(id.to_s(name)).should == id
    end
    UUID.new(UUID::Nil.to_s).should == UUID::Nil
  end
  
  it 'raises an ArgumentError when passed a value it cannot convert into a UUID' do
    lambda { UUID.new '<garbage>' }.should raise_error(ArgumentError)
  end
end

describe UUID, "#to_i" do
  it 'returns a 128-bit integer representation of the UUID'
end

describe UUID, '#to_s' do
  
  COMPACT_FORMAT = /[0-9a-fA-F]{8}([0-9a-fA-F]{4}){3}[0-9a-fA-F]{12}/
  DEFAULT_FORMAT = /[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}/
  
  before do
    @id = UUID.new
  end

  it 'returns a UUID string in delimited hex format when passed no parameters (i.e., xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)' do
    @id.to_s.should =~ /^#{DEFAULT_FORMAT}$/
  end

  it 'returns a UUID string in delimited hex format when passed :default (i.e., xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)' do
    @id.to_s(:default).should =~ /^#{DEFAULT_FORMAT}$/
  end

  it 'returns a UUID string in undelimited hex format when passed :compact (i.e., xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)' do |variable|
    @id.to_s(:compact).should =~ /^#{COMPACT_FORMAT}$/
  end

  it 'returns a UUID string in delimited hex format with a urn prefix when passed :urn (i.e., urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)' do
    @id.to_s(:urn).should =~ /^urn:uuid:#{DEFAULT_FORMAT}$/
  end
end

describe 'UUID::Nil' do
  it 'has a default string representation (#to_s) of 00000000-0000-0000-0000-000000000000' do
    UUID::Nil.to_s.should == '00000000-0000-0000-0000-000000000000'
  end
end