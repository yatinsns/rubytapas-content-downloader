#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require './screencast.rb'

BASE_URL = ENV['BASE_URL']
USERNAME = ENV['RUBYTAPAS_USERNAME']
PASSWORD = ENV['RUBYTAPAS_PASSWORD']

SCREENCASTS_LIST_URL = "#{BASE_URL}/subscriber/content"
SCREENCASTS_LIST_PATH = "/tmp/content.html"
COOKIES_PATH = "/tmp/cookies.txt"

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

def generate_cookies
  system "curl -silent -c #{COOKIES_PATH} -d \"username=#{USERNAME}&password=#{PASSWORD}\" #{SCREENCASTS_LIST_URL}"
end

def get_screencasts_list_page
  system "curl -silent -b #{COOKIES_PATH} #{SCREENCASTS_LIST_URL} > #{SCREENCASTS_LIST_PATH}"
  Nokogiri::HTML(open(SCREENCASTS_LIST_PATH))
end

def get_selected_screencasts_in_range(start_id, end_id)
  page = get_screencasts_list_page

  screencast_info = get_screencast_info page

  screencast_info.select do |screencast|
    start_id <= screencast[0] && screencast[0] <= end_id
  end
end

def download_screencast screencast
  url = "#{BASE_URL}#{screencast[2]}"
  puts ""
  puts "Fetching #{screencast[0]} from #{url}"
  download_content_info_from_url url
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

