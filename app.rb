# A really simple chatroom app for exploring how to use websockets in Ruby.
# The vast majority of the logic came from the tutorial found here:
#
# https://blog.engineyard.com/2013/getting-started-with-ruby-and-websockets
#
# Start the application with 'bundle exec ruby app.rb'

require 'thin'
require 'sinatra/base'
require 'em-websocket'

EventMachine.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end

  # our WebSockets server logic will go here
  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      @clients << ws
      ws.send "Connected to #{handshake.path}."
    end

    ws.onclose do
      ws.send "Closed."
      @clients.delete ws
    end

    ws.onmessage do |msg|
      if msg == 'STOP'
        EventMachine.stop
      elsif msg == 'CLOSE'
        ws.close(1000, "I'm closed.")
      else
        puts "Received Message: #{msg}\n"
        @clients.each do |socket|
          socket.send msg
        end
      end
    end
  end

  App.run! :port => 3000
end