require 'spec_helper'

describe InvisibleHand::API do
  # This file is not committed to this repository. You will have to create it
  # yourself if you wish to run tests.
  let(:api_config) { File.join(File.dirname(__FILE__), 'invisiblehand.yml') }

  before do
    unless File.exist?(api_config)
      puts "Your test config file does not exist. It should be at " +
        "#{api_config}."

      exit 1
    end
  end

  ["uk", "us", "ca", "de"].each do |region|
    describe "Region: #{region}" do
      let :api do
        conf = YAML.load_file(api_config)
        conf = conf.merge :region => region

        InvisibleHand::API.new(conf)
      end

      let(:product)    { api.products.results.first }
      let(:product_id) { product.id }
      let(:page)       { product.best_page }

      describe "#products" do
        subject       { api.products }
        it            { should be_a InvisibleHand::Response }
        its(:results) { should be_a Array }
        its(:info)    { should be_a Hash }
      end

      describe "#products :raw => true" do
        subject       { api.products :raw => true }
        it            { should be_a Hash }
        its(:keys)    { should include "results" }
        its(:keys)    { should include "info" }
      end

      describe "#product" do
        subject { product }
        it      { should_not be_nil }
      end

      describe "#live_price" do
        describe "with live price url" do
          subject { page.live_price }
          it      { should be_a Float }
        end

        describe "with vanilla page url" do
          subject { api.live_price(page.original_url) }
          it      { should be_a Float }
        end
      end

      describe "ad-hoc debug flag" do
        specify "the debug option to a single call should not break things" do
          expect do
            api.live_price(page.original_url, :debug => true)
          end.to_not raise_error
        end
      end

      describe "invalid config" do
        specify "no app_id or api_key should throw error" do
          expect do
            InvisibleHand::API.new
          end.to raise_error InvisibleHand::Error::InvalidConfig
        end
      end

      describe "invalid api calls" do
        describe "#product" do
          specify "should throw InvisibleHand::Error::APIError on invalid ID" do
            expect do
              api.product "not a real id at all, lol"
            end.to raise_error InvisibleHand::Error::APIError
          end
        end

        describe "#live_price" do
          specify "should throw InvisibleHand::Error::APIError on invalid URL" do
            expect do
              api.live_price "not a real url, rofl"
            end.to raise_error InvisibleHand::Error::APIError
          end
        end
      end

      describe "errors" do
        describe InvisibleHand::Error::APIError do
          subject do
            error = nil

            begin
              api.live_price "not a real url"
            rescue InvisibleHand::Error::APIError => e
              error = e
            end

            error
          end

          its(:url)          { should be_a String }
          its(:raw_response) { should be_a String }
          its(:message)      { should be_a String }
        end
      end
    end
  end
end
