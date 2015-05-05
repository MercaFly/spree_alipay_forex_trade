module Spree
  class AlipayForexController < StoreController
    ssl_allowed

    def passthrough_forex_trade
      order = load_order

      payment = Spree::Payment.create order_id: order.id, amount: order.amount, payment_method_id: payment_method.id
      payment.started_processing!

      # FIXME: this should be handled by spree
      # save reg token so the order is accessible via the alipay return_url
      session["registration"] = order.guest_token

      order.next

      # redirect to confirm page
      redirect_to spree.checkout_path
    end


    # this initiates the redirect to Alipay
    # POST /alipay/forex_trade?payment_method_id=4
    def forex_trade
      order = load_order

      payment   = payment_from_order(order)
      pm_method = payment.payment_method

      forex_trade_url = pm_method.set_forex_trade payment.identifier,
                                                  order,
                                                  spree.order_url(order, token: order.guest_token), 
                                                  notify_alipay_forex_url,
                                                  { subject: transaction_subject(order) }
      redirect_to forex_trade_url
    end


    private

    def load_order
      order = current_order || raise(ActiveRecord::RecordNotFound)
    end

    def payment_from_order(order)
      order.payments.processing.first
    end

    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def provider
      payment_method.provider
    end

    def transaction_subject(order)
      fallback    = current_store.name
      store_name  = I18n.t("spree.alipay_forex.store.#{current_store.name.downcase}", default: fallback) 

      "#{store_name}, ##{order.number}"
    end
  end
end
