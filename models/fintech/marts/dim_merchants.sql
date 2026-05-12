with transactions as (
    select * from {{ ref('int_transactions_enriched') }}
),

merchant_summary as (
    select
        merchant_id,
        count(transaction_id)                   as total_transactions,
        sum(transaction_amount)                 as total_revenue,
        avg(transaction_amount)                 as avg_transaction_amount,
        max(transaction_amount)                 as max_transaction_amount,
        count(distinct account_id)              as unique_customers,
        count(distinct location)                as unique_locations,
        sum(case when is_fraud_flagged
            then 1 else 0 end)                  as fraud_flagged_count,
        round(sum(case when is_fraud_flagged
            then 1 else 0 end)
            / count(transaction_id) * 100, 2)   as fraud_flag_rate,
        mode(channel)                           as most_used_channel,
        mode(transaction_type)                  as most_common_transaction_type
    from transactions
    group by merchant_id
)

select * from merchant_summary
