#!/Users/carlo/.rubies/ruby-2.2.2/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'rss'

doc = Nokogiri::HTML(open('http://www.oreilly.com/biocoder/index.csp?submit=true'))
search_date = doc.css('meta[name="search_date"]').first.attr(:content)

feed = RSS::Maker.make('atom') do |maker|
  maker.channel.author = 'Carlo Zottmann <carlo@zottmann.org>'
  maker.channel.updated = Time.now.to_s
  maker.channel.about = 'http://www.oreilly.com/biocoder/index.csp?submit=true'
  maker.channel.title = 'O\'Reilly BioCoder'

  row = doc.css('section.archive div.row').first

  img_src = row.css('img').attr('src')
  img = "<img src='#{ img_src }' alt='Cover image' />"

  links = row.css('a').map do |link|
    url = link.attr(:href)
    ext = url.gsub(/^.+\./, '').upcase
    "<li><a href='#{ url }'>#{ ext }</a></li>"
  end
  links = links.join('')

  maker.items.new_item do |item|
    item.link = row.css('a').first.attr(:href)
    item.title = row.css('h2').text.gsub(/(NEW – )?Download the /, '')
    item.summary = img + "<ul>#{ links }</ul>"
    item.updated = DateTime.parse(search_date).iso8601
  end
end

fn = File.expand_path('~/c.zottmann.org/feeds/biocoder.atom')
File.open(fn, 'w') do |f|
  f.puts feed
end
