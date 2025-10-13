#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'cgi'

# Get the signup page to extract CSRF token
uri = URI('http://localhost:3000/users/sign_up')
response = Net::HTTP.get_response(uri)

# Extract CSRF token from the page
csrf_token = response.body.match(/name="csrf-token" content="([^"]+)"/)[1]
puts "CSRF Token: #{csrf_token}"

# Prepare form data
timestamp = Time.now.to_i
form_data = {
  'authenticity_token' => csrf_token,
  'user[email]' => "test#{timestamp}@example.com",
  'user[username]' => "testuser#{timestamp}",
  'user[full_name]' => 'Test User'
}

# Submit the registration form
uri = URI('http://localhost:3000/users')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri)
request.set_form_data(form_data)
request['Cookie'] = response['Set-Cookie'] if response['Set-Cookie']

response = http.request(request)
puts "Response Code: #{response.code}"
puts "Response Body: #{response.body[0..500]}..." if response.body.length > 500
