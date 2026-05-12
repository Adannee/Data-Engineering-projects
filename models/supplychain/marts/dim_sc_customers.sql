with orders as (
    select * from {{ ref('int_supply_chain_enriched') }}
),

customer_summary as (
    select
        customer_id,
        customer_segment,
        customer_city,
        customer_state,
        customer_country,
        count(distinct order_id)                as total_orders,
        sum(order_quantity)                     as total_units_purchased,
        sum(sales)                              as total_spend,
        avg(sales)                              as avg_order_value,
        sum(order_profit)                       as total_profit_generated,
        avg(item_discount_rate)                 as avg_discount_rate,
        sum(case when is_late
            then 1 else 0 end)                  as late_deliveries_received,
        min(order_date)                         as first_order_date,
        max(order_date)                         as last_order_date,
        case
            when sum(sales) >= 10000 then 'High Value'
            when sum(sales) >= 5000 then 'Mid Value'
            else 'Low Value'
        end                                     as customer_value_tier
    from orders
    group by
        customer_id,
        customer_segment,
        customer_city,
        customer_state,
        customer_country
)

select * from customer_summary