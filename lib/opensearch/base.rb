require 'uri'
require 'net/http'
require 'rexml/document'
require "rss/1.0"
require "rss/2.0"
require "rss/dublincore"

module OpenSearch
  class OpenSearchBase
    def initialize(doc)
      install_accessor
      setup_description doc
      self
    end

    def search(url, query, post = false)
      query = setup_query(url, query)
      post ? post_content(query, post) : get_content(query)
    end

    private
    def install_accessor
    end

    def setup_description(doc)
    end

    def setup_query(url, query)
      search_terms = URI.escape(query)
      url.gsub!("{searchTerms}", search_terms)
      @pager.each do |key, value|
        key = key.gsub(/_(.)/){$1.upcase}
        url.gsub!(/\{#{key}(\?|)\}/, value.to_s)
      end
      url
    end

    def get_content(uri)
      uri =  URI.parse(uri)
      Net::HTTP.version_1_2
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get("#{uri.path}?#{uri.query}")
        raise "Get Error : #{response.code} - #{response.message}" unless response.code == "200"
        response.body
      end
    end

    def post_content(uri, data)
      uri =  URI.parse(uri)
      Net::HTTP.version_1_2
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get("#{uri.path}?#{uri.query}", data)
        raise "Post Error : #{response.code} - #{response.message}" unless response.code == "200"
        response.body
      end
    end

    def parse_rss(rss)
      begin
        RSS::Parser.parse(rss)
      rescue RSS::InvalidRSSError
        RSS::Parser.parse(rss, false)
      end
    end

    ## No implementation of atom format parser, not yet...
    # def atom_parser(xml)
    # end
  end
end
