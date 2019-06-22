#!/usr/bin/env ruby

require "../../lib/async/slack"

token = ENV['SLACK_TOKEN']

class Connection < Async::WebSocket::Connection
	def receive_pong(frame)
		Async.logger.info(self) {"receive_pong: #{frame.inspect}"}
	end
end

Async::Slack.connect(token: token) do |client|
	client.real_time.connect(handler: Connection) do |connection|
		id = 1
		
		Async do |task|
			while true
				task.sleep 5
				
				Async.logger.info(self) {"Sending WebSocket Ping Frame #{id}..."}
				
				connection.send_ping("id=#{id}")
				connection.flush
				
				id += 1
			end
		end
		
		while message = connection.read
			Async.logger.info(self) {"message: #{message.inspect}"}
		end
	end
end
