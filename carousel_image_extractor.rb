require 'nokogiri'
require 'httparty'
require 'base64'
require 'json'

def extract_carousel_images(file_path)

  document = Nokogiri::HTML.parse(open(file_path))

  top_carousel = document.css('g-scrolling-carousel')
  carousel_content = top_carousel.at_css('div[jsname="haAclf"]')
  all_script_tags = document.css('script')

  extracted_data = { "artworks" => [] }

  carousel_content.css('a').each do |link|

    title = link['aria-label']

    extensions = []
    # year is more reliably available via the title attribute, but must be parsed
    extension_year = link['title'].match(/\((\d{4})\)/) ? link['title'].match(/\((\d{4})\)/)[1] : ""

    extensions << extension_year

    image_url = "https://www.google.com#{link['href']}"
    image = link.at_css('img')
    image_id = image ? image['id'] : nil
    thumbnail = nil

    all_script_tags.each do |script|
      match_data = script.content.match(/var\s+s\s*=\s*'([^']+)';\s*var\s+ii\s*=\s*\[\s*'#{image_id}'\s*\];/)
      if match_data
        # strip off data prefix to avoid decoding/encoding
        decoded_image = Base64.decode64(match_data[1]['data:image/jpeg;base64,'.length .. -1])
        encoded_thumbnail = Base64.strict_encode64(decoded_image)
        # prepend data prefix to output correct format
        thumbnail = "data:image/jpeg;base64,#{encoded_thumbnail}"
        break
      end
    end

    result = {
      "name"=> title,
      "extensions"=> extensions,
      "link"=> image_url,
      "image"=> thumbnail
    }

    extracted_data["artworks"] << result

  end

  formatted_json = JSON.pretty_generate(extracted_data)
  puts formatted_json
  File.write("./output/extracted-images-#{document.title.split.first}.json", formatted_json)
end
