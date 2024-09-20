# frozen_string_literal: true

require 'pg'

##
# a module for interacting with the database
module DB
  ##
  # connect to the database
  def self.connect
    @connect ||= PG.connect(host: ENV['POSTGRES_HOST'], port: ENV['POSTGRES_PORT'], dbname: 'fileshare-website',
                            user: ENV['POSTGRES_USER'], password: ENV['POSTGRES_PASSWORD'])
  end

  ##
  # check database connection
  def self.connected?
    @connect.status == PG::CONNECTION_OK
  end

  ##
  # a module for interacting with user objects in the database
  module User
    ##
    # create a user
    # user: object
    def self.create(user)
      sql = 'INSERT INTO users (username, password) VALUES ($1, $2)'

      DB.connect.exec_params(sql, [user['username'], user['password']])
    end

    ##
    # get a user
    # username: string
    def self.get(user)
      sql = 'SELECT * FROM users WHERE username = $1'

      DB.connect.exec_params(sql, [user['username']]) do |result|
        result.each do |res|
          return { "username": res.values_at('username')[0], "password": res.values_at('password')[0] }
        end
      end
    end
  end
end

##
# a module for interacting with db migrations
module Migration
  def self.run_migrations
    @connect ||= PG.connect(host: ENV['POSTGRES_HOST'], port: ENV['POSTGRES_PORT'], dbname: 'fileshare-website',
                            user: ENV['POSTGRES_USER'], password: ENV['POSTGRES_PASSWORD'])

    create_user_table

    @connect.close
  end

  def self.create_user_table
    sql = %{
      CREATE TABLE "users" (
        "username" VARCHAR(250) NOT NULL,
        "password" VARCHAR(250) NOT NULL,
        PRIMARY KEY ("username")
      );
    }

    begin
      @connect.exec(sql)
    rescue PG::Error => e
      puts e
    end
  end
end
