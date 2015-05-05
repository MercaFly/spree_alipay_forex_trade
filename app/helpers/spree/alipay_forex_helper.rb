module Spree
  module AlipayForexHelper
    def image_link_to_forex_trade(payment_method)
      image = image_tag('alipay.png', :alt=> I18n.t('spree.alipay_forex.forex_trade'))
      link_to image, passthrough_forex_trade_path(payment_method.id) 
    end

    def forex_trade_url(payment_method)
      alipay_forex_trade_path(:payment_method_id => payment_method.id)
    end


    def passthrough_forex_trade_path(payment_method_id)
      passthrough_ali_pay_forex_path(payment_method_id)
    end
  end

end
