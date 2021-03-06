module Spree
  class AlipayForexNotifyController < ApplicationController
    skip_before_action :verify_authenticity_token

    # Alipay workflow IPN
    # WAIT_BUYER_PAY(等待买家付款)
    # WAIT_SELLER_SEND_GOODS(买家已付款，等待卖家发货)
    # WAIT_BUYER_CONFIRM_GOODS(卖家已发货，等待买家收货)
    # TRADE_FINISHED(买家已收货，交易完成)
    #
    # Spree Order status
    # payment - The store is ready to receive the payment information for the order.
    # confirm - The order is ready for a final review by the customer before being processed.
    # complete
    def notify_web
      clean_params = filter_ipn_params(params)

      if Alipay::Notify.verify?(clean_params)
        puts "OK" * 50

        (_order_id, payment_identifier) = clean_params["out_trade_no"].split("-") #R31231999-WMCBRB7Y
        status       = clean_params["trade_status"] #TRADE_FINISHED

        payment      = Spree::Payment.find_by_identifier(payment_identifier) || raise(ActiveRecord::RecordNotFound)

        handle_status status, payment

        render text: 'success', status: 200
      else
        puts "!" * 100
        render text: 'error', status: 409
      end
    end

    # return url from alipay (gets IPN data as params)
    def complete_forex_trade
      clean_params = filter_ipn_params(params)

      order_id     = params[:id]
      (_order_id, payment_identifier) = clean_params["out_trade_no"].split("-") #R31231999-WMCBRB7Y
      status       = clean_params["trade_status"] #TRADE_FINISHED

      payment      = Spree::Payment.find_by_identifier(payment_identifier) || raise(ActiveRecord::RecordNotFound)
      order        = Spree::Order.find_by_number(order_id)

      handle_status status, payment

      redirect_to spree.order_url(order, token: order.guest_token)
    end

    # Alipay status
    # 1、已收货情况
    # WAIT_SELLER_AGRE(等待卖家同意退款)
    # WAIT_BUYER_RETURN_GOOD(卖家同意退款，等待买家退货)
    # WAIT_SELLER_CONFIRM_GOODS(买家退货，等待卖家收到退货)
    # REFUND_SUCCESS(买家收到退货，退款成功，交易关闭)
    # 2、未收货情况
    # WAIT_SELLER_AGREE(等待卖家同意退款)
    # REFUND_SUCCESS(卖家同意退款，退款成功，交易关闭)
    # 3、卖家未发货而退款成功，交易状态会变为TRADE_CLOSED
    # 4、卖家发货而退款成功后，交易状态变为TRADE_FINISHED
    def notify_refund
    end

    private

    def handle_status(status, payment)
      case status
      when 'WAIT_BUYER_PAY'
        logger.info "Waiting for the payment"
      when 'WAIT_SELLER_SEND_GOODS'
        logger.info "Waiting for the seller to send the goods"
      when 'TRADE_FINISHED'
        payment.complete! unless payment.completed?
        payment.order.next! unless payment.order.complete?
      when 'TRADE_CLOSED'
        logger.info "Trade closed"
      else
        logger.info "Received status signal: #{status}"
      end
    end

    def filter_ipn_params(params)
      # except :controller_name, :action_name, :host, etc.
      # FOREX PING:
      # {
      #   "notify_id"=>”73328d271c912ac24a576bcb5c9221943o",
      #   "notify_type"=>"trade_status_sync",
      #   "sign"=>"46e073aa3b5fa308ec7ac9aadc2459f6",
      #   "trade_no"=>"2015013000001000300042872300",
      #   "total_fee"=>"69.95",
      #   "out_trade_no"=>"LMK752NG",
      #   "currency"=>"EUR",
      #   "notify_time"=>"2015-01-30 10:53:30",
      #   "trade_status"=>"TRADE_FINISHED",
      #   "sign_type"=>"MD5"
      # }
      params.except(*request.path_parameters.keys).tap do |np|
        logger.info params.inspect
        logger.info np.inspect
      end
      #current_store_id get magically set by _our_ spree store
      params.delete("current_store_id")
      puts "::::::::::::::::::::::::::::::::::::::::"
      puts params.inspect
      puts "/:::::::::::::::::::::::::::::::::::::::"      
      params
    end

  end
end
