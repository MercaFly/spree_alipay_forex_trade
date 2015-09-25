module Spree
  class OrderAmountCalculator
    def initialize(order)
      @order = order
      
      @tax_adjustments = order.all_adjustments.tax.additional
      @promotion_line_item_adjustments = order.line_item_adjustments.promotion
      @shipping_adjustments = order.all_adjustments.shipping
      @promotion_order_adjustments = order.all_adjustments.promotion
    end

    def amount
      @order.amount 
    end

    def shipping_costs
      @order.shipments.to_a.sum(&:cost)      
    end


    def promotion_costs
      sum = 0.0

      @promotion_line_item_adjustments.each do |adjustment|
        next if (@tax_adjustments + @shipping_adjustments).include?(adjustment)
        sum += adjustment.amount
      end

      @promotion_order_adjustments.each do |adjustment|
        next if (@tax_adjustments).include?(adjustment)
        sum += adjustment.amount
      end
      sum
    end

    def adjustment_costs
      sum  = 0.0

      @order.all_adjustments.nonzero.eligible.each do |adjustment|
        next if (@tax_adjustments + @shipping_adjustments).include?(adjustment)
        sum += adjustment.amount
      end

      sum
    end

    def total
      amount + shipping_costs + promotion_costs
    end
  end
end
