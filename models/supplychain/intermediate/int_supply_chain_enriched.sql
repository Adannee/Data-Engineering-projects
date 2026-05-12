with orders as (
    select * from {{ ref('stg_supply_chain') }}
),

final as (
    select
        order_id,
        order_item_id,
        customer_id,
        customer_account_id,
        customer_segment,
        customer_city,
        customer_state,
        customer_country,
        order_date,
        shipping_date,
        days_shipping_actual,
        days_shipping_scheduled,
        late_delivery_risk,
        delivery_status,
        shipping_mode,
        order_status,
        order_city,
        order_state,
        order_country,
        order_region,
        market,
        category_id,
        category_name,
        department_id,
        department_name,
        product_id,
        product_name,
        product_price,
        product_status,
        payment_type,
        order_quantity,
        item_price,
        item_discount,
        item_discount_rate,
        item_total,
        sales,
        benefit_per_order,
        sales_per_customer,
        item_profit_ratio,
        order_profit,

        -- Shipping variance
        days_shipping_actual - days_shipping_scheduled  as shipping_delay_days,

        -- Late delivery flag
        case
            when days_shipping_actual > days_shipping_scheduled then true
            else false
        end                                             as is_late,

        -- Shipping performance tier
        case
            when days_shipping_actual <= days_shipping_scheduled then 'On Time'
            when days_shipping_actual <= days_shipping_scheduled + 2 then 'Slightly Late'
            else 'Significantly Late'
        end                                             as shipping_performance,

        -- Order size tier
        case
            when sales >= 500 then 'Large Order'
            when sales >= 200 then 'Medium Order'
            else 'Small Order'
        end                                             as order_size_tier,

        -- Profitability tier
        case
            when item_profit_ratio >= 0.2 then 'High Margin'
            when item_profit_ratio >= 0.1 then 'Mid Margin'
            when item_profit_ratio >= 0 then 'Low Margin'
            else 'Loss Making'
        end                                             as profitability_tier,

        -- Discount tier
        case
            when item_discount_rate >= 0.2 then 'High Discount'
            when item_discount_rate >= 0.1 then 'Mid Discount'
            else 'Low Discount'
        end                                             as discount_tier,

        -- Date dimensions
        date_trunc('month', order_date)                 as order_month,
        date_trunc('quarter', order_date)               as order_quarter,
        year(order_date)                                as order_year,
        dayname(order_date)                             as order_day_of_week

    from orders
)

select * from final