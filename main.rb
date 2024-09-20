# frozen_string_literal: true

require 'sinatra'
require 'dotenv/load'

require_relative 'db/db'
require_relative 'session/session'
require_relative 'auth/auth'

Migration.run_migrations
DB.connect
Session.connect

raise StandardError, 'the connection to the postgres database failed.' unless DB.connected?
raise StandardError, 'the connection to the redis database failed.' unless Session.connected?

post '/auth/create' do
  request_payload = JSON.parse(request.body.read)

  Auth.create_account(request_payload)
end

post '/auth/login' do
  request_payload = JSON.parse(request.body.read)

  Auth.login(request_payload, request.cookies['fileshare-website'], response)
end
