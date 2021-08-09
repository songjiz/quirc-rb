require_relative "lib/quirc/version"

Gem::Specification.new do |spec|
  spec.name          = "quirc-rb"
  spec.version       = Quirc::VERSION
  spec.authors       = ["songji"]
  spec.email         = ["lekyzsj@gmail.com"]

  spec.summary       = "QRcode decoder based on quirc"
  spec.description   = "QRcode decoder based on quirc"
  spec.homepage      = "https://github.com/songjiz/quirc-rb"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata = {
    "homepage_uri"    => spec.homepage,
    "source_code_uri" => spec.homepage
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/quirc/extconf.rb"]

  spec.add_dependency "image_processing", "~> 1.12", ">= 1.12.1"
end
