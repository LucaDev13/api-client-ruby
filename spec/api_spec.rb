require 'spec_helper'

describe InvisibleHand::API do
  # This file is not committed to this repository. You will have to create it
  # yourself if you wish to run tests.
  let(:api_config) { File.join(File.dirname(__FILE__), 'invisiblehand.yml') }

  let(:api)        { InvisibleHand::API.new(api_config) }
  let(:product)    { api.products["results"].first }
  let(:product_id) { product["id"] }
  let(:page)       { product["best_page"] }

  describe "#products" do
    subject    { api.products }
    it         { should be_a Hash }
    its(:keys) { should include "results" }
    its(:keys) { should include "info" }
  end

  describe "#product" do
    subject { product }
    it      { should_not be_nil }
  end

  describe "#live_price" do
    describe "with live price url" do
      subject { api.live_price(page["live_price_url"]) }
      it      { should be_a Float }
    end

    describe "with vanilla page url" do
      subject { api.live_price(page["original_url"]) }
      it      { should be_a Float }
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
end
