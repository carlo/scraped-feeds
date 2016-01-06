#!/Users/carlo/.rubies/ruby-2.2.2/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'rss'

doc = Nokogiri::HTML(open('http://www.diamandis.com/blog/archive'))

feed = RSS::Maker.make('atom') do |maker|
  maker.channel.author = 'Peter Diamandis'
  maker.channel.updated = Time.now.to_s
  maker.channel.about = 'http://www.diamandis.com/blog/'
  maker.channel.title = 'Peter Diamandis\' Blogs'

  doc.css('li.blog-archive-entry').each do |row|
    url = row.css('a').first.attr('href')
    title = row.css('h4').text.strip

    maker.items.new_item do |item|
      item.link = url
      item.title = title
      item.updated = Time.now.to_s
    end

    break
  end
end

fn = File.expand_path('~/c.zottmann.org/feeds/diamandis-blog.atom')
File.open(fn, 'w') do |f|
  f.puts feed
end
