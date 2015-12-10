require 'alipay'

module Spree
  class Gateway::AlipayForexTrade < Gateway
    preference :pid, :string
    preference :key, :string
    preference :seller_email, :string

    def supports?(source)
      true
    end

    def provider_class
      ::Alipay::Service
    end

    def provider
      setup_alipay
      ::Alipay::Service
    end

    def cancel(response)
    end

    def auto_capture?
      true
    end

    def source_required?
      false
    end

    def method_type
      'alipay_forex_trade'
    end

    def purchase(money, source, gateway_options)
      nil
    end


    def set_forex_trade(out_trade_no, order, return_url, notify_url, gateway_options={})
      raise unless preferred_pid && preferred_key && preferred_seller_email

      subject      = gateway_options[:subject] || order.number
      total_amount = Spree::OrderAmountCalculator.new(order).total

      options = {
        :out_trade_no      => out_trade_no,
        :subject           => subject,
        :currency          => "EUR",
        :total_fee         => total_amount,
        :return_url        => return_url,
        :notify_url        => notify_url
      }

      provider.create_forex_trade_url(options)
    end

    def refund(payment, amount)
      #noop
    end

    private

    def setup_alipay
      Alipay.pid = preferred_pid
      Alipay.key = preferred_key
    end
  end
end
