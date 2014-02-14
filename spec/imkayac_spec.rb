require 'spec_helper'
require 'akane/storages/imkayac'

require 'digest/sha1'
require 'json'

require 'twitter/tweet'
require 'twitter/user'

describe Akane::Storages::Imkayac do
  let(:base_config) { {"user" => 'tester', "keywords" => %w(keyword), "excludes" => %w(ignore)} }
  let(:config) { base_config }

  let(:endpoint) { "http://im.kayac.com/api/post" }

  let(:tweet_text) { 'keyword' }
  let(:screen_name) { 'user' }
  let(:tweet) { Twitter::Tweet.new(id: 1, text: tweet_text, user: {id: 2, screen_name: screen_name}, retweeted_status: nil) }
  let(:retweet) { Twitter::Tweet.new(id: 2, text: "RT @#{screen_name}: #{tweet_text}", user: {id: 3, screen_name: 'retweeter'}, retweeted_status: tweet) }

  let(:error) { nil }
  let(:response) { {id: nil, error: error, result: error ? "" : "posted"} }

  subject { described_class.new(config: config, logger: Logger.new(nil)) }

  before do
    stub_request(:post, "#{endpoint}/tester").to_return(:body => response.to_json)
  end

  describe "#record_tweet" do
    describe "keyword matching:" do
      context "when matched keywords" do
        it "sends" do
          subject.record_tweet('tester', tweet)

          expect(a_request(:post, "#{endpoint}/tester").with(
            body: {message: '[tw] user: keyword'}
          )).to have_been_made
        end

        context "when error occured" do
          let(:error) { "test error" }

          it "raises error" do
            expect {
              subject.record_tweet('tester', tweet)
            }.to raise_error(Akane::Storages::Imkayac::RequestError, "test error")
          end
        end
      end

      context "when matched both keywords and ignored keywords" do
        let(:tweet_text) { 'keyword ignore' }

        it "doesn't send" do
          subject.record_tweet('tester', tweet)
          expect(a_request(:post, "#{endpoint}/tester")).not_to have_been_made
        end
      end

      context "when matched tweet is a retweet" do
        it "doesn't send" do
          subject.record_tweet('tester', retweet)
          expect(a_request(:post, "#{endpoint}/tester")).not_to have_been_made
        end
      end
    end

    describe "message option:" do
      let(:config) { base_config.merge("message" => '<%= tweet.id %> <%= tweet.user.id %> <%= tweet.text %> <%= tweet.user.screen_name %>') }

      it "allows customize message" do
        subject.record_tweet('tester', tweet)

        expect(a_request(:post, "#{endpoint}/tester").with(
          body: {message: '1 2 keyword user'}
        )).to have_been_made
      end
    end

    describe "handler option:" do
      let(:config) { base_config.merge("handler" => 'myapp://<%= tweet.id %>') }

      it "allows customize handler" do
        subject.record_tweet('tester', tweet)

        expect(a_request(:post, "#{endpoint}/tester").with(
          body: {message: '[tw] user: keyword', handler: 'myapp://1'}
        )).to have_been_made
      end
    end

    describe "secret option:" do
      let(:config) { base_config.merge("secret" => 'mysecret') }

      it "sends `sig` for authentication" do
        subject.record_tweet('tester', tweet)

        message = '[tw] user: keyword'
        expect(a_request(:post, "#{endpoint}/tester").with(
          body: {message: message, sig: Digest::SHA1.hexdigest(message + 'mysecret')}
        )).to have_been_made
      end
    end

    describe "password option:" do
      let(:config) { base_config.merge("password" => 'mypw') }

      it "sends `password` for authentication" do
        subject.record_tweet('tester', tweet)

        expect(a_request(:post, "#{endpoint}/tester").with(
          body: {message:  '[tw] user: keyword', password: 'mypw'}
        )).to have_been_made
      end
    end
  end
end
