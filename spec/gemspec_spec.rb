require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rubygems/specification'

describe 'uuid.gemspec' do
  it 'evals without error under $SAFE = 3' do
    data = File.read(File.join(File.dirname(__FILE__), '..', 'uuid.gemspec'))
    spec = nil
    lambda {
      Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
    }.should_not raise_error(SecurityError)
  end
end
