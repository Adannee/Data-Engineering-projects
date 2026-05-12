with orders as (
    select * from {{ ref('int_supply_chain_enriched') }}
),

product_summary as (
    select
        product_id,
        product_name,
        category_name,
        department_name,
        avg(product_price)                      as avg_product_price,
        count(order_item_id)                    as total_orders,
        sum(order_quantity)                     as total_units_sold,
        sum(sales)                              as total_revenue,
        sum(order_profit)                       as total_profit,
        avg(item_profit_ratio)                  as avg_profit_margin,
        avg(item_discount_rate)                 as avg_discount_rate,
        sum(case when is_late
            then 1 else 0 end)                  as late_deliveries,
        round(sum(case when is_late
            then 1 else 0 end)
            / count(order_item_id) * 100, 2)    as late_delivery_rate
    from orders
    group by
        product_id,
        product_name,
        category_name,
        department_name
)

select * from product_summary