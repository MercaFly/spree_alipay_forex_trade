module Spree
  class AlipayForexController < StoreController
    ssl_allowed

    # step from payment to confirm page
    def passthrough_forex_trade
      order = load_order

      payment_method = Spree::PaymentMethod.find(params[:payment_method_id])

      amount  = Spree::OrderAmountCalculator.new(order).total
      payment = Spree::Payment.create order_id: order.id, amount: amount, payment_method_id: payment_method.id
      payment.started_processing!

      # FIXME: this should be handled by spree
      # save reg token so the order is accessible via the alipay return_url
      session["registration"] = order.guest_token

      puts ">>>"
      puts order.state
      if order.next 
        puts "New state: #{order.state}"
      else 
        puts order.errors.inspect
      end
      puts "<<<"

      # redirect to confirm page
      redirect_to spree.checkout_path
    end


    # this initiates the redirect to Alipay
    # POST /alipay/forex_trade?payment_method_id=4
    def forex_trade
      alipay    = Spree::PaymentMethod.find(params[:payment_method_id])

      order     = load_order
      subject   = transaction_subject(order)

      payment     = order.payments.processing.first
      
      # this is displayed in the alipay transaction list -> easier to find
      # the matching transaction in spree
      identifier  = "#{order.number}-#{payment.identifier}"

      return_path = alipay.auto_capture? ? 
                      complete_forex_trade_url(order, token: order.guest_token) :
                      spree.order_url(order, token: order.guest_token)
        
      logger.info "#" * 100
      logger.info alipay.auto_capture?
      logger.info return_path 
      logger.info "#" * 100

      url = alipay.set_forex_trade identifier,
                            order,
                            return_path,
                            notify_alipay_forex_url,
                            {subject:  subject}
      
      # set payment state to checkout to complete the order (completion is otherwise not possible)
      payment.state = "checkout"
      payment.save
      order.next! unless order.complete?

      redirect_to url
    end

    private

    def load_order
      current_order || raise(ActiveRecord::RecordNotFound)
    end

    def return_path(order, payment_method)

    end

    def transaction_subject(order)
      fallback    = current_store.name
      store_name  = I18n.t("spree.alipay_forex.store.#{current_store.name.downcase}", default: fallback) 

      "#{store_name}, ##{order.number}"
    end
  end
end
