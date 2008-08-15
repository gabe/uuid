require File.join(File.dirname(__FILE__), 'spec_helper')

describe UUID::RandomDevice, '#read' do
  before do
    @device = UUID::RandomDevice.new
  end
  
  it 'returns 16 bytes' do
    @device.read.size.should == 16
  end
  
  it 'returns different bytes for subsequent calls' do
    @device.read.should_not == @device.read
  end
end
