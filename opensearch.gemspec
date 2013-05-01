# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = "opensearch"
  s.version = 0.1
  s.authors = ["drawnboy"]
  s.email = ["drawn.boy@gmail.com.nospam"]
  s.homepage = "http://opensearch.rubyforge.org"
  s.summary = %q{Ruby/OpenSearch - Search A9 OpenSearch compatible engines}
  s.description = %q{This library is for OpenSearch version 1.0 or 1.1}

  s.rubyforge_project = "opensearch"

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
