require 'opensearch/base'

module OpenSearch
  class OpenSearch11 < OpenSearch::OpenSearchBase
    Nodes = { 
      "url"               => { :format => {}, :requirements => [] },
      "short_name"        => { :format => "", :requirements => nil }, 
      "long_name"         => { :format => "", :requirements => nil },
      "description"       => { :format => "", :requirements => nil },
      "tags"              => { :format => "", :requirements => nil },
      "image"             => { :format => {}, :requirements => [] },
      "query"             => { :format => {}, :requirements => [] },
      "developer"         => { :format => "", :requirements => nil },
      "contact"           => { :format => "", :requirements => nil },
      "attribution"       => { :format => "", :requirements => nil },
      "syndication_right" => { :format => "", :requirements => nil },
      "adult_content"     => { :format => "", :requirements => nil },
      "language"          => { :format => "", :requirements => [] },
      "input_encoding"    => { :format => "", :requirements => [] },
      "output_encoding"   => { :format => "", :requirements => [] },
    }
    Pagers = { 
      "count"           => 20,
      "start_index"     => 1,
      "start_page"      => 1,
      "language"        => "*",
      "output_encoding" => "UTF-8",
      "input_encoding"  => "UTF-8",
    }

    def initialize(doc)
      @description = Hash.new
      @pager       = Pagers.dup
      super
    end

    def search(query, type = nil)
      url  = nil
      post = false
      if type.nil?
        url = @description["url"][0]["template"]
      else
        @description["url"].each do |u|
          if u["type"] == type
            url = u["template"] 
            if u["method"] =~ /post/i
              post = u["param"] 
              post = setup_query(post, query)
            end
          end
        end
      end
      raise "cannot find strict url from Description." if url.nil?
      super(url, query, post)
    end

    private
    def install_accessor
      class << self
        Nodes.each_key do |node|
          define_method(node){ @description[node] }
        end

        Pagers.each_key do |pager|
          define_method(pager){ @pager[pager] }
          define_method("#{pager}="){|value| @pager[pager] = value }
          define_method("set_custom"){|pager, value|  @pager[pager] = value }
          define_method("get_pager"){|pager|  @pager[pager] }
        end
      end
    end

    def setup_description(doc)
      Nodes.each_key do |node|
        REXML::XPath.each(doc, "//#{node.gsub(/(^|_)(.)/){$2.upcase}}") do |n|
          description = nil
          if Nodes[node][:format].class == Hash
            description = Hash.new
            n.attributes.each do |key, value|
              description[key] = value
            end
            description[node] = n.text unless n.text.nil?
            if node == "url" && n.has_elements?
              description["param"] = ""
              REXML::XPath.each(n, "//Param") do |param|
                param.attributes.each do |k, v|
                  description["param"] << "#{k}=#{v}&"
                end
              end
            end
          else
            description = n.text
          end
          if Nodes[node][:requirements].class == Array
            @description[node] = @description[node].to_a.push(description)
          else
            @description[node] = description
          end
        end
      end
    end
  end
end
