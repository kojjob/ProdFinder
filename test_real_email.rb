#!/usr/bin/env ruby

require 'net/http'
require 'uri'

def test_magic_link_real_email
  puts "🔮 Testing magic link with real email delivery..."

  # Start with fresh session
  uri = URI.parse("http://localhost:3000/users/sign_in")
  http = Net::HTTP.new(uri.host, uri.port)

  # Get CSRF token
  response = http.get(uri.path)
  csrf_token = response.body.match(/name="authenticity_token" value="([^"]*)"/)[1]
  puts "✅ CSRF Token: #{csrf_token[0..20]}..."

  # Request magic link for kojcoder@gmail.com
  post_uri = URI.parse("http://localhost:3000/users/sign_in")
  post_request = Net::HTTP::Post.new(post_uri.path)
  post_request['Content-Type'] = 'application/x-www-form-urlencoded'
  post_request.set_form_data({
    'authenticity_token' => csrf_token,
    'user[email]' => 'kojcoder@gmail.com'
  })

  response = http.request(post_request)

  puts "📧 Response Code: #{response.code}"
  puts "📍 Response Location: #{response['Location']}" if response['Location']

  if response.code == '302'
    puts "✅ Magic link sent successfully to kojcoder@gmail.com!"
    puts "📬 Check your Gmail inbox (including spam folder)"
    puts "⏱️  The link expires in 20 minutes"
  else
    puts "❌ Error: #{response.code}"
    puts response.body[0..500]
  end
end

test_magic_link_real_email
