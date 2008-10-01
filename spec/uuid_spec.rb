require File.join(File.dirname(__FILE__), 'spec_helper')

describe UUID, '.uuid4' do
  it 'generates a new UUID' do
    UUID.uuid4.should be_a_kind_of(UUID)
    UUID.uuid4.should_not == UUID.uuid4
  end
  
  it 'generates version 4 UUIDs' do
    UUID.uuid4.to_s.should =~ /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/
    UUID.uuid4.version.should == 4
  end
  
  it 'generates UUIDs of the RFC 4122 variant' do
    UUID.uuid4.variant.should == UUID::RFC_4122
  end
end

describe UUID, '.parse' do
  it 'creates a UUID from a valid string representation when passed one' do
    id = UUID.uuid4
    [id.to_s, id.hex, id.urn].each do |s|
      UUID.parse(s).should == id
    end
    UUID.parse(UUID::Nil.to_s).should == UUID::Nil
  end
  
  it 'raises an ArgumentError when passed a string it cannot parse into a UUID' do
    lambda { UUID.parse '<garbage>' }.should raise_error(ArgumentError)
  end
end

describe UUID, '#initialize' do
  it 'creates a UUID from an Integer when passed one that is within range for a UUID' do
    id = UUID.uuid4
    UUID.new(id.to_i).should == id
    UUID.new(0).should == UUID::Nil
  end

  it 'raises an ArgumentError when passed a parameter that cannot be coerced into an Integer' do
    lambda { UUID.new '<garbage>' }.should raise_error(ArgumentError)
  end

  it 'raises a RangeError when passed an Integer that is out of range for a UUID' do
    lambda { UUID.new(-1) }.should raise_error(RangeError)
    lambda { UUID.new(1 << 128) }.should raise_error(RangeError)
  end
end

describe UUID, '#to_i' do
  it 'returns an unsigned integer representation of the UUID' do
    i = UUID.uuid4.to_i
    i.should be_a_kind_of(Integer)
    i.should >= 0
    i.should < (1 << 128)
  end
end

delimited_hex_format = /[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}/

describe UUID, '#to_s' do
  it 'returns a UUID string in delimited hex format (i.e., xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)' do
    UUID.uuid4.to_s.should =~ /^#{delimited_hex_format}$/
  end
end

describe UUID, '#hex' do
  it 'returns a UUID string in undelimited hex format (i.e., xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)' do
    UUID.uuid4.hex.should =~ /^[0-9a-fA-F]{8}([0-9a-fA-F]{4}){3}[0-9a-fA-F]{12}$/
  end
end

describe UUID, '#urn' do
  it 'returns a UUID string in delimited hex format with a urn prefix (i.e., urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)' do
    UUID.uuid4.urn.should =~ /^urn:uuid:#{delimited_hex_format}$/
  end
end

describe 'UUID::Nil' do
  it 'has a string representation (#to_s) of 00000000-0000-0000-0000-000000000000' do
    UUID::Nil.to_s.should == '00000000-0000-0000-0000-000000000000'
  end
  
  it 'has an integer value (#to_i) of 0' do
    UUID::Nil.to_i.should == 0
  end
end
