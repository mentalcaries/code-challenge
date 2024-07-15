require 'nokogiri'
require 'httparty'

# "artworks" : [{
#   "name": "",
#   "extensions": ["year"],
#   "link": "",
#   "image": ""
# }]

document = Nokogiri::HTML.parse(open('./files/van-gogh-paintings.html'))

top_carousel = document.css('g-scrolling-carousel.wqBQjd')
all_script_tags = document.css('script')


pattern = /var\s+s\s*=\s*'([^']+)';\s*var\s+ii/

data = { "artworks": [] }

thumbnails = []

def get_image_title(element, title_selector)
  title_element = element.css(title_selector)
  if title_element
    title = title_element.text.strip.gsub(/\s+/, ' ')
  return title
  else
    return ''
  end
end

def get_image_src (element)
  image = element.at_css('img')
  if image
    return image['src']
  else
    return ''
  end
end



top_carousel.css('a').each do |link|

  title = get_image_title(link, '.kltat')
  # puts "Title: #{title}"

  image = link.at_css('img')
  image_id = image['id']

  all_script_tags.each do |script|
    match_data = script.content.match(/var\s+s\s*=\s*'([^']+)';\s*var\s+ii\s*=\s*\[\s*'#{image_id}'\s*\];/)
    if match_data
      thumbnails << match_data[1]
    end
  end

  puts thumbnails




end
