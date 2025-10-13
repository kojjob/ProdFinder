#!/usr/bin/env ruby

require 'net/http'
require 'uri'

# Get the login page to extract CSRF token
uri = URI('http://localhost:3000/users/sign_in')
response = Net::HTTP.get_response(uri)

# Extract CSRF token from the page
csrf_match = response.body.match(/name="csrf-token" content="([^"]+)"/)
if csrf_match
  csrf_token = csrf_match[1]
else
  puts "Could not extract CSRF token. Server response:"
  puts response.body[0..500]
  exit
end
puts "CSRF Token: #{csrf_token}"

# Prepare form data for magic link request
form_data = {
  'authenticity_token' => csrf_token,
  'user[email]' => 'test1760349540@example.com'  # Using our existing test user
}

# Submit the magic link request
uri = URI('http://localhost:3000/users/sign_in')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri)
request.set_form_data(form_data)
request['Cookie'] = response['Set-Cookie'] if response['Set-Cookie']

response = http.request(request)
puts "Response Code: #{response.code}"
puts "Response Location: #{response['Location']}" if response['Location']
puts "Response Body: #{response.body[0..300]}..." if response.body && response.body.length > 0
