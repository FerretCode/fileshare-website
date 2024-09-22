# frozen_string_literal: true

require 'sinatra'
require 'dotenv/load'
require 'json'

require_relative 'db/db'
require_relative 'session/session'
require_relative 'files/files'
require_relative 'bucket/bucket'
require_relative 'auth/auth'
require_relative 'middleware/auth'

Migration.run_migrations
DB.connect
Session.connect
Bucket.connect

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
  erb :'files/sync.html', { layout: :'layout.html' }
end

post '/files/sync/up' do
  files = params[:files]
  return [500, 'no files were provided'] if files.nil?

  content_type :json

  Files::Sync.post_files(request.cookies['fileshare-website'], files)
end

get '/files/sync/down' do
  status, body = Files::Sync.get_files(request.cookies['fileshare-website'], true)

  content_type :json if status == 200

  [status, body]
end

get '/files/sync/down/:filename' do
  filename = params[:filename]

  status, body = Files::Sync.download_file(request.cookies['fileshare-website'], filename)

  return [status, body] if status != 200

  content_type 'application/octet-stream'
  attachment(filename)
  body
end

post '/files/sync/delete/:filename' do
  Files::Sync.delete_file(request.cookies['fileshare-website'], params[:filename])
end

get '/files/me' do
  status, body, username = Files::Sync.get_files(request.cookies['fileshare-website'], false)

  return [status, body] if status != 200

  puts body

  erb :'files/me.html', { layout: :'layout.html', locals: { data: JSON.parse(body), username: username } }
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
