require 'spec_helper'

describe Spree::AlipayForexController, type: :controller do

  # Regression tests for #55
  context "when current_order is nil" do

    context "partner_trade" do
      it "raises ActiveRecord::RecordNotFound" do
        
        expect(lambda { get :partner_trade, :use_route => :spree}).to raise_error(ActiveRecord::RecordNotFound)
      end
    end


  end
end
