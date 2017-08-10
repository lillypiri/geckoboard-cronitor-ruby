require 'sinatra'
require 'faraday'
require 'json'

connection = Faraday.new('https://cronitor.io/')
connection.basic_auth(ENV['TOKEN'], '')

get '/' do
  result = connection.get '/v3/monitors'

  failing_crons = JSON.parse(result.body)["monitors"].select do |m|
    !m["running"] && !m["passing"]
  end

  content_type :json
  {
    status: if failing_crons.length == 0 then "Up" else "Down" end,
    downTime: if failing_crons.length == 0 then "" else failing_crons.first["status"] end,
    responseTime: ''
  }.to_json
end
