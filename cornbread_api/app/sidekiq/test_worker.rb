class TestWorker
 include Sidekiq::Worker
 sidekiq_options :queue => :default , :retry => 1

 def perform(type)
  puts "Does this work"
 end
 Sidekiq::Cron::Job.new(name: 'Test Worker - every minute', cron: '* * * * *', class: 'TestWorker')
end
