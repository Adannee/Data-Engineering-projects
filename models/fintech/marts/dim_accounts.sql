with transactions as (
    select * from {{ ref('int_transactions_enriched') }}
),

account_summary as (
    select
        account_id,
        mode(customer_occupation)               as customer_occupation,
        mode(age_group)                         as age_group,
        avg(customer_age)::int                  as customer_age,
        count(transaction_id)                   as total_transactions,
        sum(transaction_amount)                 as total_spend,
        avg(transaction_amount)                 as avg_transaction_amount,
        max(transaction_amount)                 as max_transaction_amount,
        avg(account_balance)                    as avg_account_balance,
        sum(case when is_fraud_flagged
            then 1 else 0 end)                  as fraud_flagged_count,
        round(sum(case when is_fraud_flagged
            then 1 else 0 end)
            / count(transaction_id) * 100, 2)   as fraud_flag_rate,
        min(transaction_date)                   as first_transaction_date,
        max(transaction_date)                   as last_transaction_date
    from transactions
    group by account_id
),

account_summary_final as (
    select
        account_id,
        customer_occupation,
        age_group,
        customer_age,
        total_transactions,
        total_spend,
        avg_transaction_amount,
        max_transaction_amount,
        avg_account_balance,
        fraud_flagged_count,
        fraud_flag_rate,
        first_transaction_date,
        last_transaction_date,
        case
            when fraud_flagged_count >= 3 then 'High Risk'
            when fraud_flagged_count >= 1 then 'Medium Risk'
            else 'Low Risk'
        end                                     as account_risk_tier
    from account_summary
)

select * from account_summary_final