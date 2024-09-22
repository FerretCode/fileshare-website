# frozen_string_literal: true

require 'base64'

require_relative '../session/session'
require_relative '../bucket/bucket'

##
# handles file requests
module Files
  ##
  # handles file sync requests
  module Sync
    ##
    # delete files
    def self.delete_file(session_id, file)
      begin
        user = Session.get_session(session_id)
      rescue Redis::CommandError
        puts e
        return [500, e]
      end

      Bucket.connect.delete_object(bucket: ENV['S3_BUCKET_NAME'], key: "#{user['username']}/#{file}")

      [200, 'the file was deleted']
    rescue Aws::S3::Errors::ServiceError => e
      puts e
      [500, e]
    end

    ##
    # sync files up
    def self.post_files(session_id, files)
      begin
        user = Session.get_session(session_id)
      rescue Redis::CommandError
        puts e
        return [500, e]
      end

      results = []

      files.each do |file|
        filename = file[:filename]
        file_content = file [:tempfile]

        begin
          Bucket.connect.put_object(
            bucket: ENV['S3_BUCKET_NAME'],
            key: user['username'] + '/' + filename,
            body: file_content
          )

          results << {
            name: filename,
            size: file_content.size,
            code: 200
          }
        rescue Aws::S3::Errors::ServiceError => e
          results << {
            name: filename,
            size: file_content.size,
            code: 500,
            status: "error uploading #{filename}: #{e.message}"
          }
        end
      end

      [200, results.to_json]
    end

    ##
    # sync files down
    def self.get_files(session_id, with_content)
      begin
        user = Session.get_session(session_id)
      rescue Redis::CommandError
        puts e
        return [500, e, '']
      end

      begin
        list_params = {
          bucket: ENV['S3_BUCKET_NAME'],
          prefix: user['username']
        }

        response = Bucket.connect.list_objects_v2(list_params)

        files = response.contents.map do |object|
          result = {
            key: object.key,
            size: object.size
          }

          if with_content
            content = Bucket.connect.get_object(bucket: ENV['S3_BUCKET_NAME'], key: object.key)
            result['content'] = Base64.strict_encode64(content.body.read)
          end

          result
        end

        [200, files.to_json, user['username']]
      rescue Aws::S3::Errors::ServiceError => e
        puts e
        [500, e, user['username']]
      end
    end

    def self.download_file(session_id, file)
      begin
        user = Session.get_session(session_id)
      rescue Redis::CommandError
        puts e
        return [500, e]
      end

      file = Bucket.connect.get_object(bucket: ENV['S3_BUCKET_NAME'], key: "#{user['username']}/#{file}")
      [200, file.body.read]
    rescue Aws::S3::Errors::ServiceError
      [404, 'file nonexistent']
    end
  end
end
