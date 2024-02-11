require "bundler/inline"
require "rss"

gemfile do
  source "https://rubygems.org"
  gem "http"
  gem "builder"
end

original_feed = RSS::Parser.parse(HTTP.get("https://scrapbox.io/api/feed/june29").body.to_s)
nikki_items = original_feed.items.select do
  _1.title.match(/^\d{4}-\d{2}-\d{2} \w{3} : .+/) && !_1.title.include?("(書きかけ)")
end

xml = Builder::XmlMarkup.new(indent: 2)

xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.id "https://scrapbox.io/june29/"
  xml.title "純朴日記"
  xml.author do |author|
    author.name "juneboku"
  end
  xml.link href: "https://scrapbox.io/june29/"
  xml.link href: "https://api.june29.jp/nikki/atom.xml", rel: "self"
  xml.updated nikki_items.sort_by(&:pubDate).last.pubDate.to_datetime.rfc3339

  nikki_items.sort_by(&:pubDate).reverse.each do |item|
    xml.entry do
      xml.title item.title.sub(" - junebox - Scrapbox", "")
      xml.link href: item.link
      xml.id item.link
      xml.updated item.pubDate.to_datetime.rfc3339
      xml.content type: "html" do
        xml.cdata! item.description
      end
    end
  end
end

puts xml.target!
