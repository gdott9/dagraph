# frozen_string_literal: true

require_relative "lib/dagraph/version"

Gem::Specification.new do |spec|
  spec.name = "dagraph"
  spec.version = Dagraph::VERSION
  spec.authors = ["Guillaume Dott"]
  spec.email = ["guillaume+github@dott.fr"]

  spec.summary = "Add support for directed acyclic graphs (DAG) to your ActiveRecord model"
  spec.description = spec.summary
  spec.homepage = "https://github.com/gdott9/dagraph"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gdott9/dagraph"
  spec.metadata["changelog_uri"] = "https://github.com/gdott9/dagraph/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activerecord', '>= 6.0.0'
  spec.add_runtime_dependency 'activesupport', '>= 6.0.0'
  spec.add_runtime_dependency 'with_advisory_lock', '>= 4.0.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
