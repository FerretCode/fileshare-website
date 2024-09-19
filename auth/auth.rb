# frozen_string_literal: true

require 'bcrypt'

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
  def self.login; end
end
