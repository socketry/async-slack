# frozen_string_literals: true
#
# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "async/websocket/client"
require "async/websocket/response"

require_relative 'representation'
require_relative 'error'

module Async
	module Slack
		class RealTime < Representation
			def connect(**options, &block)
				response = self.post
				
				parameters = response.read
				
				if url = parameters[:url]
					endpoint = Async::HTTP::Endpoint.parse(url)
					
					Async::WebSocket::Client.connect(endpoint, **options) do |connection|
						self.start(connection, &block)
					end
				else
					raise ConnectionError, parameters
				end
			end
			
			def start(connection, &block)
				id = 1
				
				pinger = Async do |task|
					while true
						task.sleep 60
						
						Async.logger.debug(self) {"Sending ping #{id}..."}
						connection.write({type: "ping", id: "pinger-#{id}"})
						connection.flush
						
						id += 1
					end
				end
				
				yield connection
			ensure
				pinger.stop
			end
		end
	end
end
