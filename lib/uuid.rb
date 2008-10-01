begin
  require 'securerandom'
rescue LoadError
  require File.join(File.dirname(__FILE__), 'compat', 'securerandom')
end

class UUID
  def initialize(value = nil)
    @value = Integer(value)
    unless (@value >= 0) && (@value < (1 << 128))
      raise RangeError, "#{value} (Integer value #{@value}) is out of range (need unsigned 128-bit value)"
    end
  end
  
  def ==(other)
    eql?(other)
  end
  
  def clock_seq
    ((clock_seq_hi_variant & 0x3f) << 8) | clock_seq_low
  end
  
  def clock_seq_hi_variant
    (to_i >> 56) & 0xff
  end
  
  def clock_seq_low
    (to_i >> 48) & 0xff
  end
  
  def eql?(other)
    other.is_a?(self.class) && (other.to_i == to_i)
  end
  
  def hash
    to_i.hash
  end
  
  def hex
    '%032x' % to_i
  end
  
  def inspect
    to_s
  end
  
  def node
    to_i & 0xffffffffffff
  end
  
  def time
    ((time_hi_version & 0x0fff) << 48) | (time_mid << 32) | time_low
  end
  
  def time_hi_version
    (to_i >> 64) & 0xffff
  end
  
  def time_low
    (to_i >> 96)
  end
  
  def time_mid
    (to_i >> 80) & 0xffff
  end
  
  def to_i
    @value
  end
  
  def to_s
    h = hex
    '%s-%s-%s-%s-%s' % [h[0...8], h[8...12], h[12...16], h[16...20], h[20...32]]
  end
  
  def urn
    "urn:uuid:#{self}"
  end
  
  RESERVED_NCS, RFC_4122, RESERVED_MICROSOFT, RESERVED_FUTURE = [
    'reserved for NCS compatibility',
    'specified in RFC 4122',
    'reserved for Microsoft compatibility',
    'reserved for future definition'
  ]
  
  def variant
    case 0
    when to_i & (0x8000 << 48)
      RESERVED_NCS
    when to_i & (0x4000 << 48)
      RFC_4122
    when to_i & (0x2000 << 48)
      RESERVED_MICROSOFT
    else
      RESERVED_FUTURE
    end
  end
  
  def version
    (variant == RFC_4122) ? ((to_i >> 76) & 0xf) : nil
  end
  
  class << self
    def parse(uuid)
      str = uuid.to_s
      unless str =~ /^(urn:uuid:)?[0-9a-fA-F]{8}((-)?[0-9a-fA-F]{4}){3}(-)?[0-9a-fA-F]{12}$/
        raise ArgumentError, "#{str} is not a recognized UUID representation"
      end
      new bytes_to_i(str.gsub(/(^urn:uuid:|-)/, '').downcase.unpack('a2' * 16).collect { |x| x.to_i(16) }.pack('C*'))
    end
    
    def uuid4
      bytes = SecureRandom.random_bytes(16)
      bytes[6] = (bytes[6] & 0x0f) | 0x40
      bytes[8] = (bytes[8] & 0x3f) | 0x80
      new bytes_to_i(bytes)
    end
    
    private
    
    def bytes_to_i(bytes)
      bytes.unpack('C*').inject { |value, i| value * 256 | i }
    end
  end
end

UUID::Nil = UUID.new(0)
