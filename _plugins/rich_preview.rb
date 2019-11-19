require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'digest'

module Jekyll
  class RichPreviewTag < Liquid::Tag
    def initialize(tag_name, tag_text, tokens)
      super
      @link_url = tag_text.scan(/https?:\/\/[\S]+/).first
      create_rich_preview
    end

    def create_rich_preview
      if cache_exists?(@link_url)
        @preview_content = read_cache(@link_url).to_s
      else
        begin
          doc = Nokogiri::HTML(open(@link_url))
        rescue
          doc = nil
        end
        title = get_title(doc, @link_url)
        image = get_image(doc)
        desc = get_description(doc)
        
        @preview_content = "
<div class=\"preview-tag\">
  <img src=\"#{image}\">
  <a href=\"#{@link_url}\" target=\"_blank\">#{title}</a>
  <div class=\"preview-tag-title\">#{desc}</div>
</div>
"
        write_cache(@link_url, @preview_content)
      end
    end

    def render(context)
      %|#{@preview_content}|
    end

  def get_title(doc, link_url)
    if doc == nil
      return link_url
    end
    title = get_tag_from_doc(doc, "meta[property='og:title']")
    unless title.to_s.strip.empty?
        return title
    end
    doc.title
  end

  def get_image(doc)
    if doc == nil
      return 'https://via.placeholder.com/300x200?text=No+preview'
    end
    image = get_tag_from_doc(doc, "meta[property='og:image']")
    unless image.to_s.strip.empty?
        return image
    end
    'https://via.placeholder.com/300x200?text=No+preview'
  end

  def get_description(doc)
    if doc == nil
      return 'Could not access URL to create rich link preview'
    end
    desc = get_tag_from_doc(doc, "meta[property='og:description']")
    unless desc.to_s.strip.empty?
        return desc
    end
    'No description available'
  end

  def get_tag_from_doc(doc, tag)
    return doc.search(tag).map { |n| n['content']}.first
  end

  def cache_key(link_url)
    Digest::MD5.hexdigest(link_url)
  end

  def cache_exists?(link_url)
    File.exist?("_cache/#{cache_key(link_url)}")
  end

  def write_cache(link_url, content)
    File.open("_cache/#{cache_key(link_url)}", 'w') { |f| f.write(content) }
  end

  def read_cache(link_url)
    File.read("_cache/#{cache_key(link_url)}")
  end

  end
end

Liquid::Template.register_tag('richpreview', Jekyll::RichPreviewTag)
