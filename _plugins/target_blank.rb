# _plugins/external_links.rb
module Jekyll
  module ExternalLinks
    class Processor
      def process(content)
        return content if !content.is_a?(String)
        
        content.gsub(/<a\s+(.*?)>/m) do |match|
          attrs = $1
          
          next match if attrs.include?('target=') || attrs.include?('href="#') || attrs.include?('mailto:')
          
          if attrs.include?('href="http')
            "<a #{attrs} target=\"_blank\" rel=\"noopener noreferrer\">"
          else
            match
          end
        end
      end
    end
  end
end

Jekyll::Hooks.register :pages, :post_render do |page|
  processor = Jekyll::ExternalLinks::Processor.new
  page.output = processor.process(page.output)
end

Jekyll::Hooks.register :posts, :post_render do |post|
  processor = Jekyll::ExternalLinks::Processor.new
  post.output = processor.process(post.output)
end