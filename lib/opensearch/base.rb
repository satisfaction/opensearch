require 'uri'
require 'net/https'
require 'rexml/document'

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
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
      end
      http.start {
        response = http.get("#{uri.path}?#{uri.query}")
        raise "Get Error : #{response.code} - #{response.message}" unless response.code == "200"
        response.body
      }
    end

    def post_content(uri, data)
      uri =  URI.parse(uri)
      Net::HTTP.version_1_2
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"  # enable SSL/TLS
        http.use_ssl = true
      end
      http.start {
        response = http.get("#{uri.path}?#{uri.query}", data)
        raise "Post Error : #{response.code} - #{response.message}" unless response.code == "200"
        response.body
      }
    end

    ## No implementation of atom format parser, not yet...
    # def atom_parser(xml)
    # end
  end
end
