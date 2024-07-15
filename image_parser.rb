require 'nokogiri'
require 'httparty'
require 'base64'
require 'json'

# "artworks" : [{
#   "name": "",
#   "extensions": ["year"],
#   "link": "",
#   "image": ""
# }]

document = Nokogiri::HTML.parse(open('./files/van-gogh-paintings.html'))

top_carousel = document.css('g-scrolling-carousel.wqBQjd')
all_script_tags = document.css('script')

data = { "artworks" => [] }

top_carousel.css('a').each do |link|

  title = link['aria-label']
  extensions = link.css('.ellip, .klmeta').map(&:text)
  image_url = "https://www.google.com#{link['href']}"
  image = link.at_css('img')
  image_id = image['id']
  thumbnail = nil

  all_script_tags.each do |script|
    match_data = script.content.match(/var\s+s\s*=\s*'([^']+)';\s*var\s+ii\s*=\s*\[\s*'#{image_id}'\s*\];/)
    if match_data
      decoded_thumbnail = Base64.strict_encode64(Base64.decode64(match_data[1]))
      thumbnail = decoded_thumbnail
    end
  end

  result = {
    "name"=> title,
    "extensions"=> extensions,
    "link"=> image_url,
    "image"=> thumbnail
  }

  data["artworks"] << result

end

formatted_json = JSON.pretty_generate(data)
puts formatted_json
File.write('./image-parser-output.json', formatted_json)
