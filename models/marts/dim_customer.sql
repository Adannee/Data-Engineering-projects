with customer as (
    select * from {{ref('stg_customer')}}
)
order_summary as(
    select
    customer_unique_id,
    count(order_id) as total_orders,
    sum(total_payment_value) as lifetime_value,
    avg(total_payment_value) as avg_order_value,
    min(order_purchased_at) as first_order_at,
    max(order_purchased_at) as last_order_at,
    avg(avg_review_score) as avg_review_score
    from {{ref('int_orders_enriched')}}
    group by customer_unique_id
)

select
c.customer_unique_id,
c.customer_city,
c.customer_state,
o.total_orders,
o.lifetime_value,
o.avg_order_value,
o.first_order_at,
o.last_order_at,
o.avg_review_score,
case
   when o.lifetime_value >= 1000 then 'High Value'
   when 0.lifetime_value >= 500 then 'Mid Value'
   else 'Low Value'
end as customer_segment
from customer c
left join order_summary o
      on c.customer_unique_id = o.customer_unique_id

select * from final