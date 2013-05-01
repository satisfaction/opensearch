#
# Copyright (C) 2006 drawnboy (drawn.boy@gmail.com)
#
# This program is free software.
# You can distribute/modify this program under the terms of the Ruby License.
#

require 'open-uri'
require 'rexml/document'

require 'opensearch/1.0'
require 'opensearch/1.1'

module OpenSearch
  class OpenSearch
    class << self
      def new(url)
        engine = nil
        ns_uri, doc = fetch_description url

        case ns_uri
        when %r"http://a9.com/-/spec/opensearch(rss|)/1.0/"
          engine = OpenSearch10.new doc
        when %r"http://a9.com/-/spec/opensearch/1.1/"
          engine = OpenSearch11.new doc
        end

        raise "Cannot detect description of opensearch version 1.0 or 1.1" if engine.nil?
        engine
      end

      private
      def fetch_description(url)
        content = open(url) {|f| content = f.read }
        doc = REXML::Document.new content
        ns_uri = nil
        REXML::XPath.each(doc, "//Format") do |node|
          ns_uri = node.text
        end
        if ns_uri.nil?
          REXML::XPath.each(doc, "//OpenSearchDescription") do |node|
            ns_uri = node.attributes.get_attribute("xmlns").to_s
          end
        end
        return ns_uri, doc
      end
    end
  end
end

if __FILE__ == $0
  #engine = OpenSearch::OpenSearch.new "http://bulkfeeds.net/opensearch.xml"
  engine = OpenSearch::OpenSearch.new "http://127.0.0.1/example.xml"
  engine.set_custom("items_per_page", 20)
  feed = engine.search("test", "text/html")
  p feed
end
