Delayed::Worker.max_attempts = 10
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
