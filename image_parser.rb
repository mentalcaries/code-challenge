require 'nokogiri'

# "artworks" : [{
#   "name": "",
#   "extensions": ["year"],
#   "link": "",
#   "image"
# }]

document = Nokogiri::HTML.parse(open('./files/van-gogh-paintings.html'))

tags = document.xpath("//a")

carousel_links = document.css('g-scrolling-carousel a')

puts "There are #{carousel_links.count} images\n \n"

carousel_links.each do |tag|
  puts tag[:title]
end
