require 'bit-struct'

# Implements version 4 UUIDs as defined in RFC 4122 (http://www.ietf.org/rfc/rfc4122.txt)
class UUID
  def initialize(bytes = RandomDevice.new.read)
    @bytes = Bytes.new(bytes)
    return if bytes.nil?
    @bytes.clock_seq = (@bytes.clock_seq & 0x3FFF) | 0x8000
    @bytes.time_hi_and_version = (@bytes.time_hi_and_version & 0x0FFF) | 0x4000
  end
  
  def ==(other)
    other.to_s == to_s
  end
  
  def eql?(other)
    other.is_a?(self.class) && (other == self)
  end
  
  def hash
    to_s.hash
  end
  
  def inspect
    to_s
  end
  
  def to_i
    raise NotImplementedError
  end
  
  def to_s
    "%8.8x-%4.4x-%4.4x-%4.4x-%12.12x" % [
      @bytes.time_low,
      @bytes.time_mid,
      @bytes.time_hi_and_version,
      @bytes.clock_seq,
      @bytes.node
    ]
  end
  
  def to_urn
    "urn:uuid:#{self}"
  end
  
  def self.parse(value)
    raise NotImplementedError
  end
end

class UUID::Bytes < BitStruct
  unsigned :time_low, 32
  unsigned :time_mid, 16
  unsigned :time_hi_and_version, 16
  unsigned :clock_seq, 16
  unsigned :node, 48
end

class UUID::RandomDevice
  def read
    File.read('/dev/urandom', 16)
  end
end

UUID::Nil = UUID.new(nil).freeze
