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

require_relative 'representation'

module Async
	module Slack
		class Message < Representation
			def channel
				value[:channel]
			end
			
			def text
				value[:text]
			end
			
			def text= text
				value[:text] = text
			end
			
			def timestamp
				value[:ts]
			end
			
			def username
				value[:username]
			end
			
			def call(value)
				if value.nil?
					self.delete if self.timestamp
				elsif value.key?(:ts)
					self.with(path: 'chat.update').post(value)
				else
					self.with(path: 'chat.postMessage').post(value)
				end
			end
			
			def assign(value)
				response = self.call(value)
				
				if body = response.read
					channel = body[:channel]
					
					if message = body[:message]
						message[:channel] ||= channel
						
						return message
					end
				end
				
				return value
			end
			
			def delete
				self.with(path: 'chat.delete').post({ts: self.timestamp, channel: self.channel})
			end
			
			def inspect
				"\#<#{self.class} timestamp=#{self.timestamp} text=#{self.text.inspect}>"
			end
		end
		
		class Chat < Representation
			def send_message(channel:, **payload)
				message = self.with(Message, parameters: {channel: channel})
				
				message.value = payload
				
				return message
			end
		end
	end
end
