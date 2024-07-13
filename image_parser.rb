require 'nokogiri'

# "artworks" : [{
#   "name": "",
#   "extensions": ["year"],
#   "link": "",
#   "image"
# }]

document = Nokogiri::HTML.parse(open('./files/van-gogh-paintings.html'))

tags = document.xpath("//a")

tags.each do |tag|
  puts tag[:title]
end
