require 'mongo'
require 'json'

class Scrape::RankingsJob
  include Sidekiq::Job
  sidekiq_options :queue => :default , :retry => 1


  def perform(data)
    # Connect to MongoDB server
    client = Mongo.Client.new('mongodb://localhost:27017/cornbread')

    # Get collection
    collection = client[:cornbreadCollection]

    # Convert JSON string to Ruby hash
    json_data = JSON.parse(data)

    response = collection.insert_one(json_data)
  end
  