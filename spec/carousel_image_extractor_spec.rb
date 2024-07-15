require 'spec_helper'

describe 'Google Carousel Image Parser' do
  let(:html_file_path) { './files/van-gogh-paintings.html' }
  let(:document) { Nokogiri::HTML.parse(open(html_file_path)) }
  let(:all_script_tags) { document.css('script') }
  let(:top_carousel) { document.at_css('g-scrolling-carousel') }
  let(:carousel_content) {top_carousel.at_css('div[jsname="haAclf"]') }

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
      image_id = nil
      if image
        image_id = image['id']
      end

      expect(title).not_to be_nil
      expect(title).to be_a(String)

      expect(extensions).to be_an(Array)

      expect(link['href']).to be_a(String)
      expect(image_id).not_to be_nil
      expect(image_id).to be_a(String)

      extensions.each do |year|
        expect(year).to match(/\b\d{4}\b/)
      end


    end
  end




end
