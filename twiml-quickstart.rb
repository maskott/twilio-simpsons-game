require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

get '/hello' do
  people = {
    '+14047180928' => 'Corinne',
    '+14043755575' => 'Mike',
  }
  name = people[params['From']] || 'Caller'
  Twilio::TwiML::Response.new do |r|
    r.Say "Ahoy hoy #{name}, Welcome to", voice: 'alice'
    r.Play 'http://mike.skott.us/projects/sounds/beep14.mp3'
    r.Say "Twilio Test"
    r.Play 'http://mike.skott.us/projects/sounds/beep15.mp3'
    r.Gather :numDigits => '1', :action => '/hello/handle-gather', :method => 'get' do |g|
      g.Say 'To call Mikes cell phone, press 1.', voice: 'alice'
      g.Say 'Press 2 to record your own annoying voice.', voice: 'alice'
      g.Say 'Press any other key to start over.', voice: 'alice'
    end
  end.text
end


get '/hello/handle-gather' do
  redirect '/hello' unless ['1', '2'].include?(params['Digits'])
  if params['Digits'] == '1'
    response = Twilio::TwiML::Response.new do |r|
      r.Dial '+14043755575'
      r.Say 'Mikes phone is no longer available to you at this time. Goodbye.', voice: 'alice'
      r.Play 'http://mike.skott.us/projects/sounds/beep14.mp3'
      r.Say "Twilio Test... out"
      r.Play 'http://mike.skott.us/projects/sounds/beep15.mp3'
    end
  elsif params['Digits'] == '2'
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Record your grating voice after the tone, if you must.', voice: 'alice'
      r.Record :maxLength => '30', :action => '/hello/handle-record', :method => 'get'
    end
  end
  response.text
end


get '/hello/handle-record' do
  Twilio::TwiML::Response.new do |r|
    r.Say 'Seriously, just listen to what you sound like.', voice: 'alice'
    r.Play params['RecordingUrl']
    r.Say "I can't take any more. I just can't... Goodbye.", voice: 'alice'
    r.Play 'http://mike.skott.us/projects/sounds/beep14.mp3'
    r.Say "Twilio Test... out"
    r.Play 'http://mike.skott.us/projects/sounds/beep15.mp3'
  end.text
end
