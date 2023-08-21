require "bundler/inline"
require "rss"

gemfile do
  source "https://rubygems.org"
  gem "http"
end

original_feed = RSS::Parser.parse(HTTP.get("https://scrapbox.io/api/feed/june29").body.to_s)
nikki_items = original_feed.items.select {
  _1.title.match(/^\d{4}-\d{2}-\d{2} \w{3} : .+/) && !_1.title.include?("(書きかけ)")
}

new_feed = RSS::Maker.make("2.0") do |maker|
  maker.channel.title = "純朴日記"
  maker.channel.link = "https://scrapbox.io/june29/"
  maker.channel.description = "junebokuが書いている日記です"
  maker.channel.updated = nikki_items.sort_by(&:pubDate).last.pubDate

  nikki_items.sort_by(&:pubDate).reverse.each do |item|
    maker.items.new_item do |new_item|
      new_item.title = item.title.sub(" - junebox - Scrapbox", "")
      new_item.link = item.link
      new_item.description = item.description
      new_item.updated = item.pubDate
    end
  end
end

puts new_feed
