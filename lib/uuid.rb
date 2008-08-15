# Implements UUIDs as defined in RFC 4122 (http://www.ietf.org/rfc/rfc4122.txt)

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'vendor')

require 'bit-struct'

class UUID
  FORMATS = {
    :compact => "%8.8x%4.4x%4.4x%4.4x%12.12x",
    :default => "%8.8x-%4.4x-%4.4x-%4.4x-%12.12x",
    :urn     => "urn:uuid:%8.8x-%4.4x-%4.4x-%4.4x-%12.12x"
  }
  
  REGEXP = %r|^(urn:uuid:)?[0-9a-fA-F]{8}((-)?[0-9a-fA-F]{4}){3}(-)?[0-9a-fA-F]{12}$|
  
  def initialize(bytes = nil)
    if bytes.nil?
      # Generate a new UUID (version 4)
      @bytes = Bytes.new(RandomDevice.new.read)
      @bytes.clock_seq = (@bytes.clock_seq & 0x3FFF) | 0x8000
      @bytes.time_hi_and_version = (@bytes.time_hi_and_version & 0x0FFF) | 0x4000
    elsif bytes =~ REGEXP
      # Parse UUID byte values from a string in any of the supported FORMATS
      @bytes = Bytes.new(bytes.gsub(/(^urn:uuid:|-)/, '').downcase.unpack('a2' * 16).collect { |x| x.to_i(16) }.pack('C*'))
    else
      raise ArgumentError, "#{bytes} could not be converted into a UUID"
    end
    @bytes.freeze
  end
  
  def ==(other)
    other.bytes == bytes
  end
  
  def eql?(other)
    other.is_a?(self.class) && (other == self)
  end
  
  def hash
    bytes.hash
  end
  
  def inspect
    to_s
  end
  
  def to_i
    raise NotImplementedError
  end
  
  def to_s(format = :default)
    unless FORMATS.has_key?(format)
      raise ArgumentError, "#{format} is not a recognized UUID format"
    end
    FORMATS[format] % [
      bytes.time_low,
      bytes.time_mid,
      bytes.time_hi_and_version,
      bytes.clock_seq,
      bytes.node
    ]
  end
  
  protected
  
  attr_reader :bytes
end

class UUID::Bytes < BitStruct
  unsigned :time_low,             32  
  unsigned :time_mid,             16
  unsigned :time_hi_and_version,  16
  unsigned :clock_seq,            16
  unsigned :node,                 48
end

class UUID::RandomDevice
  if RUBY_PLATFORM =~ /win32/i
    require 'Win32API'
    
    PROV_RSA_FULL                  = 1
    CRYPT_VERIFYCONTEXT            = 0xF0000000
    FORMAT_MESSAGE_IGNORE_INSERTS  = 0x00000200
    FORMAT_MESSAGE_FROM_SYSTEM     = 0x00001000
    
    CryptAcquireContext  = Win32API.new('advapi32', 'CryptAcquireContext', 'PPPII', 'L')
    CryptGenRandom       = Win32API.new('advapi32', 'CryptGenRandom', 'LIP', 'L')
    CryptReleaseContext  = Win32API.new('advapi32', 'CryptReleaseContext', 'LI', 'L')
    GetLastError         = Win32API.new('kernel32', 'GetLastError', '', 'L')
    FormatMessageA       = Win32API.new('kernel32', 'FormatMessageA', 'LPLLPLPPPPPPPP', 'L')
    
    def read
      hProvStr = ' ' * 4
      if CryptAcquireContext.call(hProvStr, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) == 0
        raise SystemCallError, "CryptAcquireContext failed: #{last_error_message}"
      end
      hProv, _ = hProvStr.unpack('L')
      bytes = ' ' * 16
      if CryptGenRandom.call(hProv, 16, bytes) == 0
        raise SystemCallError, "CryptGenRandom failed: #{last_error_message}"
      end
      if CryptReleaseContext.call(hProv, 0) == 0
        raise SystemCallError, "CryptReleaseContext failed: #{last_error_message}"
      end
      bytes
    end
    
    private
    
    def last_error_message
      code = GetLastError.call
      message = "\0" * 1024
      length = FormatMessageA.call(FORMAT_MESSAGE_IGNORE_INSERTS + FORMAT_MESSAGE_FROM_SYSTEM, 0, code, 0, msg, 1024, nil, nil, nil, nil, nil, nil, nil, nil)
      message[0, length].tr("\r", '').chomp
    end
  else
    def read
      random_device = ['/dev/urandom', '/dev/random'].find { |device| File.readable?(device) }
      unless random_device
        raise RuntimeError, 'Unable to find readable random device (e.g., /dev/urandom)'
      end
      File.read(random_device, 16)
    end
  end
end

UUID::Nil = UUID.new('00000000-0000-0000-0000-000000000000').freeze
