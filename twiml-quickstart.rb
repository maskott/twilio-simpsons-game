require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

get '/hello-monkey' do
  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello Monkey'
    r.Play 'http://demo.twilio.com/hellomonkey/monkey.mp3'
  end.text
end
