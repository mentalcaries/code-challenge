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

data = { "artworks": [] }


# def get_element_text_content(element, title_selector)
#   selected_element = element.css(title_selector)
#   if selected_element
#     text_content = selected_element.text.strip.gsub(/\s+/, ' ')
#   return text_content
#   else
#     return ''
#   end
# end

# def get_image_src (element)
#   image = element.at_css('img')
#   if image
#     return image['src']
#   else
#     return ''
#   end
# end



top_carousel.css('a').each do |link|

  title = link['aria-label']
  extensions = link.css('.ellip, .klmeta').map(&:text)
  image_url = "https://www.google.com#{link['href']}"
  image = link.at_css('img')
  image_id = image['id']
  thumbnail = nil
  puts title

  all_script_tags.each do |script|
    match_data = script.content.match(/var\s+s\s*=\s*'([^']+)';\s*var\s+ii\s*=\s*\[\s*'#{image_id}'\s*\];/)
    if match_data
      decoded_thumbnail = Base64.strict_encode64(Base64.decode64(match_data[1]))
      thumbnail = decoded_thumbnail
    end
  end

  result = {
    "name": title,
    "extensions": extensions,
    "link": image_url,
    "image": thumbnail
  }

  data[:artworks] << result

end


puts JSON.pretty_generate(data)
