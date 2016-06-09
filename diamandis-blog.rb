#!/Users/carlo/.rubies/ruby-2.2.2/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'rss'

doc = Nokogiri::HTML(open('http://www.diamandis.com/blog/archive'))

last_entry = doc.css('li.blog-archive-entry')
last_entry_title = last_entry.css('h4').first.text.strip
last_entry_url = last_entry.css('a').first.attr('href')
last_entry_doc = Nokogiri::HTML(open(last_entry_url))
last_entry_body = last_entry_doc.css('#page-content-body').inner_html

feed = RSS::Maker.make('atom') do |maker|
  maker.channel.author = 'Peter Diamandis'
  maker.channel.updated = Time.now.to_s
  maker.channel.link = 'http://www.diamandis.com/blog/archive'
  maker.channel.id = 'http://www.diamandis.com/blog/archive'
  maker.channel.title = 'Peter Diamandis\' Blogs'

  maker.items.new_item do |item|
    item.link = last_entry_url
    item.title = last_entry_title
    item.summary = last_entry_body
    item.updated = Time.now.to_s
  end
end

fn = File.expand_path('~/Google Drive/Sites/czm.io/feeds/diamandis-blog.atom')
File.open(fn, 'w') do |f|
  f.puts feed
end
