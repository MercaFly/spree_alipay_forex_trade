Spree::Core::Engine.add_routes do
  # Add your extension routes here
  #get '/alipay/confirm', :to => "alipay_notify#confirm", :as => :confirm_alipay
  post '/alipay-forex/passthrough_forex_trade', :to => "alipay_forex#passthrough_forex_trade", :as => :passthrough_ali_pay_forex
  post '/alipay-forex/forex_trade', :to => "alipay_forex#forex_trade", :as => :alipay_forex_trade
  get  '/alipay-forex/complete_forex_trade/:id/:token', to: "alipay_forex_notify#complete_forex_trade", as: :complete_forex_trade 
  post '/alipay-forex/complete_forex_trade/:id/:token', to: "alipay_forex_notify#complete_forex_trade"
  post '/alipay-forex/notify', :to => "alipay_forex_notify#notify_web", :as => :notify_alipay_forex
end
