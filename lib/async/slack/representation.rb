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

require 'async/rest/representation'
require 'async/rest/wrapper/json'
require 'async/rest/wrapper/url_encoded'

module Async
	module Slack
		class Wrapper < Async::REST::Wrapper::JSON
			def prepare_request(payload, headers)
				super(nil, headers)
				
				if payload
					headers['content-type'] = Async::REST::Wrapper::URLEncoded::APPLICATION_FORM_URLENCODED
					
					::Protocol::HTTP::Body::Buffered.new([
						::Protocol::HTTP::URL.encode(payload)
					])
				end
			end
			
			class Parser < HTTP::Body::Wrapper
				def join
					body = ::JSON.parse(super, symbolize_names: true)
					
					if error = body[:error]
						raise REST::Error, error
					end
					
					return body
				end
			end
			
			def wrap_response(response)
				if body = response.body
					response.body = Parser.new(body)
				end
			end
		end
		
		class Representation < Async::REST::Representation
			def initialize(*args, **options)
				super(*args, wrapper: Wrapper.new, **options)
			end
		end
	end
end
