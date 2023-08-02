require 'mongo'
include Kernel

class Scrape::BuildScrapeQueueJob
  include Sidekiq::Job
  sidekiq_options queue: :long, retry: 15

  def perform
    client = Mongo::Client.new(ENV['DATABASE_URL'])

    collection_name = 'cornbread-rankings'
    stored_pages = client[collection_name].find({}, projection: { 'query.page' => 1 }).map { |doc| doc['query']['page'].to_i }
    total_pages = (1..84498).to_a

    remaining_pages = total_pages - stored_pages

    queue = []
    until remaining_pages.empty?
      puts "[INFO] upcoming queue: #{queue}"

      unless queue.length > 30
        queue.concat(remaining_pages.shift(10))
      end
      sleep 5
      Scrape::ScrapeRankingPageJob.perform_async(queue.shift)
    end
  end
end
