#!/usr/bin/env ruby

require "../../lib/async/slack"

token = ENV['SLACK_TOKEN']

Async::Slack.connect(token: token) do |client|
	client.real_time.connect do |connection|
		id = 1
		
		Async do |task|
			while true
				task.sleep 5
				
				Async.logger.info(self) {"Sending Slack Ping Frame #{id}..."}
				
				connection.write({type: "ping", id: id})
				connection.flush
				
				id += 1
			end
		end
		
		while message = connection.read
			Async.logger.info(self) {"message: #{message.inspect}"}
		end
	end
end
