require 'spec_helper'

describe 'Google Carousel Image Parser' do
  let(:html_file_path) { './files/van-gogh-paintings.html' }
  let(:document) { Nokogiri::HTML.parse(open(html_file_path)) }

  it 'opens a valid HTML file' do
    expect { Nokogiri::HTML.parse(open(html_file_path)) }.not_to raise_error
  end

  it 'contains a g-scrolling-carousel element' do
    top_carousel = document.at_css('g-scrolling-carousel')
    expect(top_carousel).not_to be_nil
  end

  

end
