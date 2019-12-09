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
		class Pagination < Representation
			include Enumerable

			def each(page: 1, count: 100, **parameters)
				return to_enum(:each, page: page, count: count, **parameters) unless block_given?
				
				collection = self.collection(**parameters)
				
				while true
					representation = collection.get(self.class, page: page, count: count)
					
					records = representation.records
					
					records.each do |value|
						yield represent(representation.metadata, value)
					end
					
					# Was this the last page?
					break if records.size < count
					
					page += 1
				end
			end

			def empty?
				self.value.empty?
			end
		end
		
		class Messages < Pagination
			class Message < Message
				def channel
					value[:channel][:id]
				end
			end
			
			def collection(**parameters)
				@resource.with(path: 'search.messages', parameters: parameters)
			end
			
			def representation
				Message
			end
			
			def records
				binding.irb
				self.value[:messages][:matches]
			end

			def represent(metadata, attributes)
				representation.new(@resource, metadata: metadata, value: attributes)
			end
		end
		
		class Search < Representation
			def messages(**parameters, &block)
				messages = self.with(Messages, parameters: parameters)
				
				if block_given?
					messages.each(&block)
				else
					return messages
				end
			end
		end
	end
end
