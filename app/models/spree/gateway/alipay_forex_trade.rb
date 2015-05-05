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

      amount = order.amount
      tax_adjustments = order.all_adjustments.tax.additional

      shipping_adjustments = order.all_adjustments.shipping

      adjustment_label = []
      adjustment_costs = 0.0

      order.all_adjustments.nonzero.eligible.each do |adjustment|
        next if (tax_adjustments + shipping_adjustments).include?(adjustment)
        adjustment_label << adjustment.label
        adjustment_costs += adjustment.amount
      end

      subject       = gateway_options[:subject] || order.number
      shipping_cost = order.shipments.to_a.sum(&:cost)

      options = {
        :out_trade_no      => out_trade_no,
        :subject           => subject,
        :currency          => "EUR",
        :total_fee         => amount + shipping_cost,
        :return_url        => return_url,
        :notify_url        => notify_url
      }

      binding.pry

      provider.create_forex_trade(options)
    end

    def refund(payment, amount)
      #noop
    end

    private

    def setup_alipay
      Alipay.pid = preferred_pid
      Alipay.key = preferred_key
      Alipay.seller_email = preferred_seller_email
    end
  end
end
