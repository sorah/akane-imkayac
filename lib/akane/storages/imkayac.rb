require 'net/http'
require 'erb'
require 'digest/sha1'
require 'logger'
require 'json'

require 'akane/storages/abstract_storage'
require 'akane-imkayac/version'

module Akane
  module Storages
    class Imkayac < AbstractStorage
      class RequestError < StandardError; end

      VERSION = AkaneImkayac::VERSION
      DEFAULT_ENDPOINT = 'http://im.kayac.com/api/post'.freeze
      DEFAULT_MESSAGE = '[tw] <%= tweet.user.screen_name %>: <%= tweet.text %>'

      def initialize(config: raise(ArgumentError, 'missing config'), logger: Logger.new($stdout))
        super

        @config["keywords"] ||= []
        @config["excludes"] ||= []
        @config["message"]  ||= DEFAULT_MESSAGE
        @config["endpoint"] ||= DEFAULT_ENDPOINT


        unless @config["user"]
          raise ArgumentError, "config `user` is required"
        end
        unless @config["keywords"].kind_of?(Enumerable)
          raise ArgumentError, "config `keywords` should be Enumerable"
        end
        unless @config["excludes"].kind_of?(Enumerable)
          raise ArgumentError, "config `excludes` should be Enumerable"
        end

        @endpoint = URI.parse("#{@config["endpoint"].gsub(%r{/\z}, '')}/#{@config["user"]}")
      end

      def record_tweet(account, tweet)
        unless tweet.text &&
          !tweet.retweet? &&
          @config["excludes"].all? { |_| ! tweet.text.include?(_.to_s) } &&
          @config["keywords"].all? { |_| tweet.text.include?(_.to_s) }
          return
        end
        payload = { message: ERB.new(@config["message"]).result(binding), }

        payload[:password] = @config["password"] if @config["password"]

        if @config["secret"]
          payload[:sig] = Digest::SHA1.hexdigest("#{payload[:message]}#{@config["secret"]}")
        end

        if @config["handler"]
          payload[:handler] = ERB.new(@config["handler"]).result(binding)
        end

        @logger.debug("im.kayac: sending #{payload[:message].inspect} to #{@config["user"].inspect}")
        response = Net::HTTP.post_form(@endpoint, payload)
        json = JSON.parse(response.body || '')
        @logger.info("im.kayac: sent #{payload[:message].inspect} to #{@config["user"].inspect} -- #{json.inspect}")

        raise RequestError, json["error"] if json["error"] && !json["error"].empty?

      rescue JSON::ParserError => e
        r.value
        raise e
      end

      def mark_as_deleted(*)
      end

      def record_event(*)
      end

      def record_message(*)
      end
    end
  end
end
