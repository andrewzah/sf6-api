require 'httparty'
require 'json'
require 'mongo'
require 'nokogiri'

class Scrape::RankingsJob
  include Sidekiq::Job
  sidekiq_options :queue => :default , :retry => 1


  def perform
    client = Mongo::Client.new(ENV['DATABASE_URL'])

    # Get collection
    collection_name = 'cornbread-rankings'

    ranking_url = "https://www.streetfighter.com/6/buckler/ranking/league"

    cookies = {
        :buckler_id => ENV["BUCKLER_ID"],
        :buckler_r_id => ENV["BUCKLER_R_ID"],
        :buckler_praise_date => ENV["BUCKLER_PRAISE_DATE"],
    }

    headers = {
        "User-Agent" => ENV["USER_AGENT"]
    }

    response = HTTParty.get(
      ranking_url,
      :headers => headers,
      :cookies => cookies
    )

    html_doc = Nokogiri::HTML(response.body)
    element = html_doc.at_css('script#__NEXT_DATA__')
    json_data = JSON.parse(element.content)

    if element != nil
      response = client[collection_name].insert_one(json_data)
      puts 'info, record inserted successfully'
    else
      puts 'error, script tag __NEXT_DATA__ couldnt be found'
    end
  end
end
