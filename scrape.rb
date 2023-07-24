require 'httparty'
require 'nokogiri'
require 'json'

url = "https://www.streetfighter.com/6/buckler/profile/1052558378/play"

cookies = {
    :buckler_id => ENV["BUCKLER_ID"] || "",
    :buckler_r_id => ENV["BUCKLER_R_ID"] || "",
    :buckler_praise_date => ENV["BUCKLER_PRAISE_DATE"] || ""
}

headers = {
    "User-Agent" => ENV["USER_AGENT"] || ""
}

response = HTTParty.get(
  url,
  :headers => headers,
  :cookies => cookies
)

puts response.code

html_doc = Nokogiri::HTML(response.body)

puts html_doc

element = html_doc.at_css('script#__NEXT_DATA__')

if element != nil
  File.open("data.json", "w") do |f|
    f.write(element.content)
  end
else
  puts 'error, script tag __NEXT_DATA__ couldnt be found'
end
