Gem::Specification.new do |s|
  s.name         = 'uuid'
  s.version      = '0.1'
  s.platform     = Gem::Platform::RUBY
  s.author       = 'Gabriel Boyer'
  s.email        = 'gboyer@gmail.com'
  s.homepage     = 'http://github.com/gabe/uuid/'
  s.summary      = 'Simple UUID implementation'
  s.description  = 'Simple UUID (version 4) implementation, as per RFC 4122 (http://www.ietf.org/rfc/rfc4122.txt)'
  s.require_path = "lib"
  s.files        = %w( LICENSE README.markdown Rakefile ) + Dir["{lib,spec,vendor}/**/*"]
  s.required_ruby_version = ">= 1.8.6"
end
