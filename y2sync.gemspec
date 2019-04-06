
$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "y2sync/version"

Gem::Specification.new do |s|
  s.name = "y2sync"
  s.version = Y2sync::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.5.0"
  s.authors = ["Ladislav Slezák"]
  s.description = <<-DESCRIPTION
    Sync tool
  DESCRIPTION

  s.bindir = "bin"
  s.executables = ["y2sync"]

  s.email = "yast-devel@opensuse.org"
  s.files = `git ls-files bin lib LICENSE README.md`
            .split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.homepage = "https://github.com/lslezak/y2sync"
  s.licenses = ["GPL v2"]
  s.summary = ""

  s.metadata = {
    "homepage_uri"      => "https://github.com/lslezak/y2sync",
    "changelog_uri"     => "https://github.com/lslezak/y2sync/blob/master/CHANGELOG.md",
    "source_code_uri"   => "https://github.com/lslezak/y2sync/",
    "documentation_uri" => "https://lslezak.github.io/y2sync",
    "bug_tracker_uri"   => "https://github.com/lslezak/y2sync/issues"
  }

  s.add_runtime_dependency("parallel", "~> 1.10")
  s.add_runtime_dependency("rainbow", ">= 2.2.2", "< 4.0")
  s.add_runtime_dependency("ruby-progressbar", "~> 1.7")
  s.add_runtime_dependency("octokit")
  s.add_runtime_dependency("netrc")

  s.add_development_dependency("bundler", "~> 1.3")
  #  s.add_development_dependency('rake', '~> 1.3')

end
