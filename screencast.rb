#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'

def get_headings page
  page.css('div[class=blog-entry]').css('h3').map do |heading|
    heading.text
  end
end

def get_ids page
  page.css('div[class=blog-entry]').css('h3').map do |heading|
     heading.text.scan(/\d+/).first.to_i
  end
end

def get_links page
  links = page.css('div[class=blog-entry]').css('a').select do |link|
    link.text == 'Read More'
  end
  links.map { |link| link["href"] }
end

def get_screencast_info page
  ids = get_ids page
  headings = get_headings page
  links = get_links page
  ids.zip(headings, links)
end

def get_page url
  Nokogiri::HTML(open(url))
end

def main
  page = get_page "./content.html"
  screencast_info = get_screencast_info page
  puts screencast_info
end

main if __FILE__ == $0

