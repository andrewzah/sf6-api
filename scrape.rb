require 'httparty'
require 'nokogiri'
require 'json'

profile_url = "https://www.streetfighter.com/6/buckler/profile/1052558378/play"
ranking_url = "https://www.streetfighter.com/6/buckler/ranking/league"
ranking_url_jp_albania = "https://www.streetfighter.com/6/buckler/ranking/league?character_filter=4&character_id=jp&platform=1&user_status=1&home_filter=3&home_category_id=7&home_id=2&league_rank=0&page=1"

# 'https://www.streetfighter.com/6/buckler/ranking/league?character_filter=1&character_id=luke&platform=1&user_status=1&home_filter=2&home_category_id=1&home_id=1&league_rank=0&page=1'

# home_category_id":[{"value":"0","label":"All"},{"value":"1","label":"Africa"},{"value":"2","label":"Asia"},{"value":"3","label":"Europe"},{"value":"4","label":"South America"},{"value":"5","label":"North America"},{"value":"6","label":"Oceania"},{"value":"7","label":"Specific Region"}],"home_id"

cookies = {
    :buckler_id => ENV["BUCKLER_ID"] || "",
    :buckler_r_id => ENV["BUCKLER_R_ID"] || "",
    :buckler_praise_date => ENV["BUCKLER_PRAISE_DATE"] || ""
}

headers = {
    "User-Agent" => ENV["USER_AGENT"] || ""
}

response = HTTParty.get(
  ranking_url,
  :headers => headers,
  :cookies => cookies
)
puts response.code

html_doc = Nokogiri::HTML(response.body)
element = html_doc.at_css('script#__NEXT_DATA__')

if element != nil
  File.open("data/data-ranking", "w") do |f|
    f.write(element.content)
  end
else
  puts 'error, script tag __NEXT_DATA__ couldnt be found'
end
