# frozen_string_literal: true

require 'bcrypt'
require 'securerandom'

require_relative '../db/db'

##
# handles authentication requests
module Auth
  ##
  # handle a request to create an account
  def self.create_account(user)
    user['password'] = BCrypt::Password.create(user['password'])

    begin
      DB::User.create(user)
    rescue PG::Error => e
      puts e
      return [500, e]
    end

    'you have been signed up'
  end

  ##
  # handle a request to login to an existing account
  def self.login(user, session_cookie, response)
    # user['password'] = BCrypt::Password.create(user['password'])

    puts session_cookie

    begin
      raise Redis::CommandError unless session_cookie

      Session.get_session(session_cookie)
      'you have been logged in'
    rescue Redis::CommandError => e
      begin
        try_login(user)
        puts 'logged in'
        session_id = Digest::SHA256.hexdigest(SecureRandom.uuid)
        response.set_cookie('fileshare-website', {
                              value: session_id,
                              path: '/',
                              domain: ENV['COOKIE_DOMAIN']
                            })
        return [200, 'you have been logged in']
      rescue PG::Error => e
        puts e
        return [500, e]
      rescue StandardError => e
        return [500, e]
      end

      puts e
      [500, e]
    end
  end

  ##
  # try logging in using credentials into the database
  def self.try_login(user)
    fetched_user = DB::User.get(user)

    puts user['password']
    puts fetched_user[:password]

    return if BCrypt::Password.new(fetched_user[:password]) == user['password']

    raise StandardError,
          'the password is incorrect'
  end
end
