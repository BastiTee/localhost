require 'rubygems'
require 'open-uri'
require 'nokogiri'

module Jekyll
  class PreviewTag < Liquid::Tag
    def initialize(tag_name, tag_text, tokens)
      super
      @link_url = tag_text.scan(/https?:\/\/[\S]+/).first
      build_preview_content
    end

    def build_preview_content
      doc = Nokogiri::HTML(open(@link_url))

      title = get_title(doc)
      image = get_image(doc)
      desc = get_description(doc)
      
      @preview_content = "
<div class=\"preview-tag\">
  <img src=\"#{image}\">
  <a href=\"#{@link_url}\" target=\"_blank\">#{title}</a>
  <div class=\"preview-tag-title\">#{desc}</div>
</div>
"
    end

    def render(context)
      %|#{@preview_content}|
    end

  def get_title(doc)
    title = get_tag_from_doc(doc, "meta[property='og:title']")
    unless title.to_s.strip.empty?
        return title
    end
    doc.title
  end

  def get_image(doc)
    image = get_tag_from_doc(doc, "meta[property='og:image']")
    unless image.to_s.strip.empty?
        return image
    end
    'https://via.placeholder.com/300x200?text=No+preview'
  end

  def get_description(doc)
    desc = get_tag_from_doc(doc, "meta[property='og:description']")
    unless desc.to_s.strip.empty?
        return desc
    end
    'No description available'
  end

  def get_tag_from_doc(doc, tag)
    return doc.search(tag).map { |n| n['content']}.first
  end

  end
end

Liquid::Template.register_tag('richpreview', Jekyll::PreviewTag)
