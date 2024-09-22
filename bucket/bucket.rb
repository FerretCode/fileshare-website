# frozen_string_literal: true

require 'aws-sdk-s3'

##
# a module for interacting with the storage bucket
module Bucket
  def self.connect
    @connect ||= Aws::S3::Client.new(
      access_key_id: ENV['S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
      endpoint: "https://#{ENV['CLOUDFLARE_ACCOUNT_ID']}.r2.cloudflarestorage.com",
      region: 'auto'
    )
  end
end
