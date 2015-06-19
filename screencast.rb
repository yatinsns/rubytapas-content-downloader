require 'nokogiri'

SCREENCAST_POST_PATH = "/tmp/post.html"
POST_COOKIES_PATH = "/tmp/cookies.txt"
BASE_DIR = ENV['RUBYTAPAS_BASE_DIR']

def get_content_info page
  page.css('div[class=blog-entry]').css('li').css('a').map do |link|
    {:href => link["href"], :name => link.text}
  end
end

def get_content_page url
  system "curl -silent -b #{POST_COOKIES_PATH} #{url} > #{SCREENCAST_POST_PATH}"
  Nokogiri::HTML(open(SCREENCAST_POST_PATH))
end

def download content
  content_url = "#{BASE_URL}#{content[:href]}"
  content_name = "#{content[:name]}".gsub(" ", "-")
  puts "Downloading #{content_name} from #{content_url}..."
  system "curl -silent -b #{POST_COOKIES_PATH} #{content_url} > #{BASE_DIR}/#{content_name}"
end

def download_content_info_from_url url
  page = get_content_page url
  content_info = get_content_info page
  content_info.each do |content|
    download content
  end
end
