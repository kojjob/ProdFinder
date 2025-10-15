#!/usr/bin/env ruby

require 'net/http'
require 'uri'

def test_console_logging
  puts "🧪 Testing magic link console logging..."

  # Start with fresh session
  uri = URI.parse("http://localhost:3000/users/sign_in")
  http = Net::HTTP.new(uri.host, uri.port)

  # Get CSRF token
  response = http.get(uri.path)
  csrf_token = response.body.match(/name="authenticity_token" value="([^"]*)"/)[1]
  puts "✅ CSRF Token obtained"

  # Request magic link
  post_uri = URI.parse("http://localhost:3000/users/sign_in")
  post_request = Net::HTTP::Post.new(post_uri.path)
  post_request['Content-Type'] = 'application/x-www-form-urlencoded'
  post_request.set_form_data({
    'authenticity_token' => csrf_token,
    'user[email]' => 'test-console@example.com'
  })

  puts "📧 Sending magic link request..."
  response = http.request(post_request)

  if response.code == '302'
    puts "✅ Check your Rails server console for the magic link!"
    puts "🔍 Look for the 🔮 MAGIC LINK section in the logs"
    puts "📋 You can copy the link directly from the console"
  else
    puts "❌ Error: #{response.code}"
  end
end

test_console_logging
