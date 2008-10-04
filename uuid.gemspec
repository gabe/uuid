Gem::Specification.new do |s|
  s.name         = 'uuid'
  s.version      = '0.3.2'
  s.platform     = Gem::Platform::RUBY
  s.author       = 'Gabriel Boyer'
  s.email        = 'gboyer@gmail.com'
  s.homepage     = 'http://github.com/gabe/uuid/'
  s.summary      = 'Simple UUID implementation'
  s.description  = 'Simple UUID implementation, as per RFC 4122'
  s.require_path = "lib"
  s.files        = %w[ LICENSE README.markdown Rakefile
	                     spec/spec_helper.rb spec/uuid_spec.rb
	                     lib/uuid.rb lib/compat/securerandom.rb ]
  s.required_ruby_version = "~> 1.8.6"
end
