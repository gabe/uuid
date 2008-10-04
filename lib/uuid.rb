begin
  require 'securerandom'
rescue LoadError
  require File.join(File.dirname(__FILE__), 'compat', 'securerandom')
end

class UUID
  VERSION = '0.3.2'
  
  def initialize(value)
    @value = Integer(value)
    unless (@value >= 0) && (@value < (1 << 128))
      raise RangeError, "#{value} (Integer value #{@value}) is out of range (need unsigned 128-bit value)"
    end
  end
  
  def ==(other)
    eql?(other)
  end
  
  def bytes
    bs = ''
    (0..120).step(8) { |shift| bs << ((@value >> (120 - shift)) & 0xff) }
    bs
  end
  
  def clock_seq
    ((clock_seq_and_reserved & 0x3f) << 8) | clock_seq_low
  end
  
  def clock_seq_and_reserved
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
  
  def nil_uuid?
    to_i == 0
  end
  
  def node
    to_i & 0xffffffffffff
  end
  
  def time
    ((time_hi_and_version & 0x0fff) << 48) | (time_mid << 32) | time_low
  end
  
  def time_hi_and_version
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
    '%s-%s-%s-%s-%s' % [h[0, 8], h[8, 4], h[12, 4], h[16, 4], h[20, 12]]
  end
  
  def urn
    "urn:uuid:#{self}"
  end
  
  RESERVED_NCS       = 0b000 # Reserved for NCS compatibility
  RFC_4122           = 0b100 # Specified in RFC 4122
  RESERVED_MICROSOFT = 0b110 # Reserved for Microsoft compatibility
  RESERVED_FUTURE    = 0b111 # Reserved for future definition
  
  def variant
    raw_variant = (clock_seq_and_reserved >> 5)
    if (raw_variant >> 2) == 0
      0x000
    elsif (raw_variant >> 1) == 2
      0x100
    else
      raw_variant
    end >> 6
  end
  
  def version
    (variant == RFC_4122) ? ((to_i >> 76) & 0xf) : nil
  end
  
  def self.new_from_bytes(bytes)
    unless bytes.length == 16
      raise ArgumentError, "#{bytes} must have length of 16"
    end
    new bytes.unpack('C*').inject { |value, i| value * 256 | i }
  end
  
  def self.parse(uuid)
    str = uuid.to_s
    unless str =~ /^(urn:uuid:)?[0-9a-fA-F]{8}((-)?[0-9a-fA-F]{4}){3}(-)?[0-9a-fA-F]{12}$/
      raise ArgumentError, "#{str} is not a recognized UUID representation"
    end
    new_from_bytes (str.gsub(/(^urn:uuid:|-)/, '').downcase.unpack('a2' * 16).collect { |x| x.to_i(16) }.pack('C*'))
  end
  
  def self.uuid4
    bytes = SecureRandom.random_bytes(16)
    bytes[6] = (bytes[6] & 0x0f) | 0x40
    bytes[8] = (bytes[8] & 0x3f) | 0x80
    new_from_bytes bytes
  end
end

UUID::Nil = UUID.new(0)
