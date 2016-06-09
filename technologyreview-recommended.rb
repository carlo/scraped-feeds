#!/Users/carlo/.rubies/ruby-2.2.2/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'rss'


url = 'https://www.technologyreview.com/stream/rss/'
feed = nil

open(url) do |rss|
  old_feed = RSS::Parser.parse(rss, false)
  old_feed.items.select! do |item|
    item.title.match(/Must-Read Stories|Recommended/)
  end

  feed = RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'MIT Technology Review'
    maker.channel.link = maker.channel.id = old_feed.channel.link
    maker.channel.title = 'MIT Technology Review: Must-Read & Recommended Stories'
    maker.channel.updated = Time.now

    old_feed.items.each do |item|
      doc = Nokogiri::HTML(open(item.link))

      maker.items.new_item do |new_item|
        new_item.link = item.link
        new_item.title = item.title
        new_item.summary = doc.css('.article-body__content').inner_html
        new_item.updated = item.pubDate
      end
    end
  end
end

fn = File.expand_path('~/Google Drive/Sites/czm.io/feeds/technologyreview-recommended.atom')
File.open(fn, 'w') do |f|
  f.puts feed
end
