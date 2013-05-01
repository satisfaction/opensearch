require 'opensearch/base'

module OpenSearch 
  class OpenSearch10 < OpenSearchBase
    Nodes = %w(url format short_name long_name description tags image sample_search developer contact attribution syndication_right adult_content)
    Pagers = { 
      "count"       => 20,
      "start_index" => 1,
      "start_page"  => 1
    }

    def initialize(doc)
      @description = Hash.new
      @pager       = Pagers.dup
      super
    end

    def search(query)
      url =  @description["url"] 
      rss = super(url, query)
      parse_rss(rss)
    end

    private
    def install_accessor
      class << self
        Nodes.each do |node|
          define_method(node){ @description[node] }
        end

        Pagers.each_key do |pager|
          define_method(pager){ @pager[pager] }
          define_method("#{pager}="){|value| @pager[pager] = value }
        end
      end
    end

    def setup_description(doc)
      Nodes.each do |node|
       REXML::XPath.each(doc, "//#{node.gsub(/(^|_)(.)/){$2.upcase}}") do |n|
         @description[node] = n.text
       end
      end
    end
  end
end
