require 'spec_helper'
require 'nokogiri'
require 'open-uri'

describe 'Google Carousel Image Parser' do
  # Get all HTML files in the specified directory
  test_html_files = Dir.glob('./files/*.html')

  test_html_files.each do |html_file_path|
    context "with file #{html_file_path}" do
      let(:document) { Nokogiri::HTML.parse(open(html_file_path)) }
      let(:all_script_tags) { document.css('script') }
      let(:top_carousel) { document.at_css('g-scrolling-carousel') }
      let(:carousel_content) { top_carousel.at_css('div[jsname="haAclf"]') }

      it 'opens a valid HTML file' do
        expect { Nokogiri::HTML.parse(open(html_file_path)) }.not_to raise_error
      end

      it 'contains a g-scrolling-carousel element' do
        expect(top_carousel).not_to be_nil
      end

      it 'gets all the script tag contents' do
        expect(all_script_tags).not_to be_empty
        expect(all_script_tags).to all(be_a(Nokogiri::XML::Element))
      end

      it 'extracts HTML data correctly from each carousel link' do
        carousel_content.css('a').each do |link|
          title = link['aria-label']
          extensions = link.css('.ellip, .klmeta').map(&:text)
          image = link.at_css('img')
          image_id = image ? image['id'] : nil

          expect(title).to_not be_nil
          expect(title).to be_a(String)

          expect(extensions).to be_an(Array)

          expect(link['href']).to_not be_empty
          expect(link['href']).to be_a(String)

          expect(image_id).to be_a(String).or be_nil

          extensions.each do |year|
            expect(year).to match(/\b\d{4}\b/).or eq("")
          end
        end
      end

      it 'extracts a base64 URI from the script tags matching the image ID' do
        carousel_content.css('a').each do |link|
          image = link.at_css('img')
          image_id = image ? image['id'] : nil
          next if image_id.nil?

          all_script_tags.each do |script|
            match_data = script.content.match(/var\s+s\s*=\s*'([^']+)';\s*var\s+ii\s*=\s*\[\s*'#{image_id}'\s*\];/)

            expect(match_data[1]).to start_with('data:image/jpeg;base64,') if match_data
          end
        end
      end
    end
  end
end
