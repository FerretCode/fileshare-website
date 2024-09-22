# frozen_string_literal: true

require 'sinatra'
require 'dotenv/load'

require_relative 'db/db'
require_relative 'session/session'
require_relative 'auth/auth'
require_relative 'middleware/auth'

Migration.run_migrations
DB.connect
Session.connect

raise StandardError, 'the connection to the postgres database failed.' unless DB.connected?
raise StandardError, 'the connection to the redis database failed.' unless Session.connected?

get '/' do
  erb :'index.html', { layout: :'layout.html' }
end

####
# file routes
####

use Middleware::CheckAuth

get '/files/sync' do
end

post '/files/sync' do
end

get '/files/me' do
  '/'
end

####
# auth routes
####

get '/auth/create' do
  erb :'auth/create.html', { layout: :'layout.html' }
end

post '/auth/create' do
  request_payload = params

  status, text = Auth.create_account(request_payload, response)

  puts status, text

  return [status, text] if status != 200

  redirect '/'
end

get '/auth/login' do
  erb :'auth/login.html', { layout: :'layout.html' }
end

post '/auth/login' do
  request_payload = params

  status, text = Auth.login(request_payload, request.cookies['fileshare-website'], response)

  return [status, text] if status != 200

  redirect '/'
end
