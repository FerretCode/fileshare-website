# frozen_string_literal: true

require_relative '../session/session'

##
# a module containing middlewares
module Middleware
  ##
  # check whether a user is logged in or not
  class CheckAuth
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      return @app.call(env) unless request.path.start_with?('/files')

      cookies = request.cookies

      unless cookies['fileshare-website']
        return Rack::Response.new('unauthorized', 401,
                                  {}).finish
      end

      begin
        unless Session.connect.exists(cookies['fileshare-website'])
          return Rack::Response.new('unauthorized', 401,
                                    {}).finish
        end
      rescue Redis::CommandError => e
        puts e
        return Rack::Response.new('internal server error', 500, {}).finish
      end

      @app.call(env)
    end
  end
end
