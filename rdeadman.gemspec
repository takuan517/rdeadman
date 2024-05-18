# rdeadman.gemspec
require_relative 'lib/rdeadman/version'

Gem::Specification.new do |spec|
  spec.name          = "rdeadman"
  spec.version       = Rdeadman::VERSION
  spec.authors       = ["Takumi Ishihara"]
  spec.email         = ["takuan@wide.ad.jp"]
  spec.summary       = %q{A network monitoring tool}
  spec.description   = %q{A tool for monitoring the availability of multiple hosts using ping}
  spec.homepage      = "https://github.com/takuan517/rdeadman"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] + ["bin/rdeadman"]
  spec.bindir        = "bin"
  spec.executables   = ["rdeadman"]
  spec.require_paths = ["lib"]

  spec.add_dependency "net-ping", "~> 2.0"
  spec.add_dependency "curses", "~> 1.2"

  spec.add_development_dependency "rspec", "~> 3.10"
end
