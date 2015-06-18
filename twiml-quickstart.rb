require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

points = 0

q1_pool = [
  ["english", "Homer Simpson", "466"],
  ["neddoodle", "Ned Flanders", "633"],
  ["exports", "Bart Simpson", "227"],
]
q1 =""

q2_pool = [
  ["surgery", "Doctor Nick Riviera", "642"],
  ["alcohol", "Mayor Joe Quimby", "563"],
  ["nelsonhero", "Milhouse Van Houten", "645"],
]
q2 = ""

q3_pool = [
  ["roof", "Cletus Spuckler", "253"],
  ["game", "Chief Clancy Wiggum", "252"],
  ["titpecker", "Prinipal Seymore Skinner", "739"],
]
q3 = ""

get '/hello' do
  people = {
    '+14047180928' => 'Corinne Sarah Scott',
    '+14043755575' => 'Mike Scott with a K',
    '+16786405495' => 'Myron Eli Scott with a K',
    '+14042757666' => 'Doctor Richard Smiley',
    '+18182926583' => 'Chunk Daddy',
  }
  name = people[params['From']] || 'Simpsons fan'
  Twilio::TwiML::Response.new do |r|
    r.Say "Ahoy hoy #{name}, Welcome to", voice: 'alice'
    r.Say "Mike Skott's"
    r.Say "Simpson's audio game", voice: 'alice'
    r.Gather :numDigits => '1', :action => '/hello/simps', :method => 'get' do |g|
      r.Play '/sounds/simpsons_intro.mp3'
      r.Say 'Get ready to play the Simpsons audio game!', voice: 'alice'
      r.Play '/sounds/hacker.mp3'
      g.Say 'Press 1 to play.', voice: 'alice'
      g.Say 'Press any other key to start over.', voice: 'alice'
    end
  end.text
end

get '/hello/simps' do
  redirect '/hello' unless ['1'].include?(params['Digits'])
  points = 0
  q1 = q1_pool.sample
  q2 = q2_pool.sample
  q3 = q3_pool.sample
  Twilio::TwiML::Response.new do |r|
    r.Gather :numDigits => '1', :action => '/hello/simps/1', :method => 'get' do |g|
      g.Say 'To skip these instructions and get straight to the game, press 1 at any time. Press any other number to repeat these instructions.', voice: 'alice'
      g.Say 'In a moment, you will hear an audio clip from the Simpsons. You must try to determine the name of the character that you hear in the clip.', voice: 'alice'
      g.Say 'If you hear more than one character, please respond with the first character you hear in the clip.', voice: 'alice'
      g.Say 'You will enter your response by dialing the first three letters of the characters first name.', voice: 'alice'
      g.Say 'There will be three audio quotes in each game. Good luck!', voice: 'alice'
      g.Say 'Press 1 to begin the game, or any other number to repeat these instructions.', voice: 'alice'
    end
  end.text
end

# QUESTION 1

get '/hello/simps/1' do
  redirect '/hello/simps' unless ['1'].include?(params['Digits'])
  Twilio::TwiML::Response.new do |r|
    r.Say 'This first question is worth 10 points.', voice: 'alice'
    r.Play '/sounds/02-coin.mp3'
    r.Say 'Round one... begin!', voice: 'alice'
    r.Gather :numDigits => '3', :action => '/hello/simps/1/a', :method => 'get' do |g|
      r.Play "/sounds/#{q1[0]}.mp3"
      g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
    end
  end.text
end

get '/hello/simps/1/a' do
  if params['Digits'] == q1[2]
    points += 10
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/woohoo.mp3'
      r.Say "#{q1[1]} is correct for 10 points!", voice: 'alice'
      r.Say "You now have a total of #{points.to_s} points.", voice: 'alice'
      r.Redirect "/hello/simps/2"
    end
  else
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/doh.mp3'
      r.Say "That is incorrect. The correct answer was #{q1[1]} or #{q1[2]}.", voice: 'alice'
      r.Say 'You have no points... May god have mercy upon your soul.', voice: 'alice'
      r.Redirect "/hello/simps/2"
    end
  end
  response.text
end

get '/hello/simps/2' do
  Twilio::TwiML::Response.new do |r|
    r.Play '/sounds/44-coin-2.mp3'
    r.Say 'This next question is worth 20 points.', voice: 'alice'
    r.Say 'Round two... begin!', voice: 'alice'
    r.Gather :numDigits => '3', :action => '/hello/simps/3', :method => 'get' do |g|
      r.Play "/sounds/#{q2[0]}.mp3"
      g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
    end
  end.text
end

get '/hello/simps/3' do
  if params['Digits'] == q2[2]
    points += 20
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/woohoo.mp3'
      r.Say "#{q2[1]} is correct for 20 points!", voice: 'alice'
      r.Say "You now have a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/45-coin-3.mp3'
      r.Say 'This next question is worth 30 points.', voice: 'alice'
      r.Say 'Round three... begin!', voice: 'alice'
      r.Gather :numDigits => '3', :action => '/hello/simps/end', :method => 'get' do |g|
        r.Play '/sounds/game.mp3'
        g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
      end
    end
  else
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/doh.mp3'
      r.Say "That is incorrect. The correct answer was #{q2[1]} or #{q2[2]}.", voice: 'alice'
      r.Say "You now have a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/45-coin-3.mp3'
      r.Say 'This next question is worth 30 points.', voice: 'alice'
      r.Say 'Round three... begin!', voice: 'alice'
      r.Gather :numDigits => '3', :action => '/hello/simps/end', :method => 'get' do |g|
        r.Play '/sounds/game.mp3'
        g.Say '... Dial the first three letters of the characters first name.', voice: 'alice'
      end
    end
  end
  response.text
end

get '/hello/simps/end' do
  if params['Digits'] == q3[2]
    points += 30
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/woohoo.mp3'
      r.Say "#{q3[1]} is correct for 30 points!", voice: 'alice'
      r.Say "Congratulations #{name}! You finished the game with a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/43-game-over.mp3'
      r.Gather :numDigits => '1', :action => '/hello/simps/end-menu', :method => 'get' do |g|
        g.Say 'To play again, press 1 now.', voice: 'alice'
        g.Say 'Press 2 to return to the main menu.', voice: 'alice'
        g.Say 'Press any other key to disconnect.', voice: 'alice'
      end
    end
  else
    response = Twilio::TwiML::Response.new do |r|
      r.Play '/sounds/doh.mp3'
      r.Say "That is incorrect. The correct answer was #{q3[1]} or #{q3[2]}.", voice: 'alice'
      r.Say "You finished the game with a total of #{points.to_s} points.", voice: 'alice'
      r.Play '/sounds/43-game-over.mp3'
      r.Gather :numDigits => '1', :action => '/hello/simps/end-menu', :method => 'get' do |g|
        g.Say 'To play again, press 1 now.', voice: 'alice'
        g.Say 'Press any other key to disconnect.', voice: 'alice'
      end
    end
  end
  response.text
end

get '/hello/simps/end-menu' do
  if params['Digits'] == '1'
    redirect '/hello/simps'
  else
    Twilio::TwiML::Response.new do |r|
      r.Say 'Goodbye.', voice: 'alice'
      r.Play '/sounds/beep15.mp3'
    end.text
  end
end
