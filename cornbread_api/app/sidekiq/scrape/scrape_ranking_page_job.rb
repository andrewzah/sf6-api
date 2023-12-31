require "net/https"
require 'httparty'
require 'json'
require 'mongo'
require 'nokogiri'
include Kernel

class Scrape::ScrapeRankingPageJob
  include Sidekiq::Job
  include Mongo
  sidekiq_options :queue => :short , :retry => false

  @@client = Mongo::Client.new(ENV['DATABASE_URL'])

  def send_err_pushover(msg)
    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      :token => ENV['PUSHOVER_APP_TOKEN'],
      :user => ENV['PUSHOVER_USER_KEY'],
      :message => msg,
    })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end

  def make_sf6_query(url)
    cookies = {
        :buckler_id => ENV["BUCKLER_ID"],
        :buckler_r_id => ENV["BUCKLER_R_ID"],
        :buckler_praise_date => ENV["BUCKLER_PRAISE_DATE"],
    }

    headers = {
        "User-Agent" => ENV["USER_AGENT"]
    }

    response = HTTParty.get(
      url,
      :headers => headers,
      :cookies => cookies
    )

    html_doc = Nokogiri::HTML(response.body)
    element = html_doc.at_css('script#__NEXT_DATA__')
    json_data = JSON.parse(element.content)

    return json_data
  end

  def build_url(options = {})
    ranking_base_url = 'https://www.streetfighter.com/6/buckler/ranking/league'

    url = ranking_base_url + "?"

    if options[:character]
      url << "character_filter=4&character_id=#{options[:character]}"
    else
      url << 'character_filter=1&character_id=luke'
    end

    if options[:platform]
      url << "&platform=#{options[:platform]}"
    else
      url << '&platform=1'
    end

    if options[:user_status]
      url << "&user_status=#{options[:user_status]}"
    else
      url << '&user_status=1'
    end

    if options[:region]
      url << "&home_filter=3&home_category_id=7&home_id=#{options[:region]}"
    elsif options[:continent]
      url << "&home_filter=2&home_category_id=#{options[:continent]}"
    else
      url << '&home_filter=1&home_category_id=0&home_id=1'
    end

    if options[:league_rank]
      url << "&league_rank=#{options[:league_rank]}"
    else
      url << '&league_rank=0'
    end

    if options[:page]
      url << "&page=#{options[:page]}"
    end
    #&home_filter=1&home_category_id=0&home_id=1&league_rank=0&page=1
  end

  def perform(page)
    puts "performing starting job for page #{page}"

    url = "https://www.streetfighter.com/6/buckler/ranking/league?page=#{page}"

    # Get collection
    collection_name = 'cornbread-rankings'

    url_opts = {
      page: page,
    }
    url = build_url(url_opts)

    sleep_time = rand(3..25)
    puts "[INFO] about to sleep for #{sleep_time} seconds"
    sleep(sleep_time)
    data = make_sf6_query(url)

    common_data = data["props"]["pageProps"]["common"]
    raise StandardError if common_data["statusCode"] != 200

    rankings_data = data["props"]["pageProps"]["league_point_ranking"]
    query_data = data["query"]

    insert_data = {
      query: query_data,
      common: common_data,
      rankings: rankings_data,
    }

    puts "[INFO] inserting page #{page}"

    response = @@client[collection_name].insert_one(insert_data)
    puts "info, record for page #{page} inserted successfully"
  end
end

# r.data.props.pageProps.common.statusCode;
# r.data.props.pageProps.character_group.
# r.data.props.pageProps.league_point_ranking.ranking_fighter_list[0];
