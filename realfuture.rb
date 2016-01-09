#!/Users/carlo/.rubies/ruby-2.2.2/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'rss'

doc = Nokogiri::HTML(open('https://tinyletter.com/realfuture/archive'))

feed = RSS::Maker.make('atom') do |maker|
  maker.channel.author = 'Alexis Madrigal'
  maker.channel.updated = Time.now.to_s
  maker.channel.about = 'https://tinyletter.com/realfuture'
  maker.channel.title = 'Alexis Madrigal\'s Real Future'

  count = 0
  doc.css('li.message-item').each do |row|
    message_date = row.css('span.message-date').text
    url = row.css('a.message-link').attr('href')
    title = row.css('a.message-link').text.strip

    entry_doc = Nokogiri::HTML(open(url))
    body = entry_doc.css('div.message-body').inner_html

    maker.items.new_item do |item|
      item.link = url
      item.title = title
      item.summary = body
      item.updated = DateTime.parse(message_date).iso8601
    end

    count += 1
    break if count == 3
  end
end

fn = File.expand_path('~/c.zottmann.org/feeds/realfuture.atom')
File.open(fn, 'w') do |f|
  f.puts feed
end
