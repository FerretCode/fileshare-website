# frozen_string_literal: true

require 'redis'
require 'json'

##
# handles session caching with redis
module Session
  ##
  # connect to the redis cache
  def self.connect
    @connect ||= Redis.new(url: ENV['REDIS_URL'])
  end

  ##
  # check if the redis connection is open
  def self.connected?
    @connect.ping == 'PONG'
  rescue Redis::CannotConnectError => e
    puts e
    false
  end

  ##
  # write a new session to the redis cache
  # session_id: String
  # session_object: Dictionary
  def self.write_session(session_id, session_object)
    json_str = JSON.dump(session_object)
    connect.set(session_id, json_str, ex: 60 * 60 * 24 * 7)
  end

  ##
  # get a session from the redis cache
  # session_id: String
  # returns: object
  def self.get_session(session_id)
    session = connect.get(session_id)
    JSON.parse(session)
  end
end
