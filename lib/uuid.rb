begin
  require 'securerandom'
rescue LoadError
  require 'compat/securerandom'
end

class UUID
  FORMATS = {
    :compact => "%08x%04x%04x%04x%04x%08x",
    :default => "%08x-%04x-%04x-%04x-%04x%08x",
    :urn     => "urn:uuid:%08x-%04x-%04x-%04x-%04x%08x"
  }
  
  REGEXP = %r|^(urn:uuid:)?[0-9a-fA-F]{8}((-)?[0-9a-fA-F]{4}){3}(-)?[0-9a-fA-F]{12}$|
  
  def initialize(bytes = nil)
    if bytes.nil?
      # Generate a new UUID (version 4)
      @bytes = SecureRandom.random_bytes(16)
      @bytes[6] = (@bytes[6] & 0x0f) | 0x40
      @bytes[8] = (@bytes[8] & 0x3f) | 0x80
    elsif bytes =~ REGEXP
      # Parse UUID byte values from a string in any of the supported FORMATS
      @bytes = bytes.gsub(/(^urn:uuid:|-)/, '').downcase.unpack('a2' * 16).collect { |x| x.to_i(16) }.pack('C*')
    else
      raise ArgumentError, "#{bytes} could not be converted into a UUID"
    end
    @bytes.freeze
  end
  
  def ==(other)
    eql?(other)
  end
  
  def eql?(other)
    other.is_a?(self.class) && (other.bytes == bytes)
  end
  
  def hash
    bytes.hash
  end
  
  def inspect
    to_s
  end
  
  def to_s(format = :default)
    unless FORMATS.has_key?(format)
      raise ArgumentError, "#{format} is not a recognized UUID format"
    end
    FORMATS[format] % bytes.unpack('NnnnnN')
  end
  
  protected
  
  attr_reader :bytes
end

UUID::Nil = UUID.new('00000000-0000-0000-0000-000000000000')
