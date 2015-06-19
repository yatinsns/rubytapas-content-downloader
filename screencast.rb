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

def get_selected_screencasts_in_range(start_id, end_id)
  page = get_page "./content.html"
  screencast_info = get_screencast_info page

  screencast_info.select do |screencast|
    start_id <= screencast[0] && screencast[0] <= end_id
  end
end

def download_screencast screencast
  puts "Fetching #{screencast[0]} from #{screencast[2]}"
end

def download_screencasts_in_range(start_id, end_id)
  selected_screencasts = get_selected_screencasts_in_range(start_id, end_id)
  selected_screencasts.each do |screencast|
    download_screencast screencast
  end
end

def main
  print "start id: "
  start_id = STDIN.gets.chomp.to_i
  print "end id: "
  end_id = STDIN.gets.chomp.to_i

  download_screencasts_in_range(start_id, end_id)
end

main if __FILE__ == $0

