with transactions as (
    select * from {{ ref('int_transactions_enriched') }}
)

select
    transaction_id,
    account_id,
    merchant_id,
    transaction_amount,
    transaction_date,
    transaction_month,
    transaction_week,
    transaction_day_of_week,
    transaction_hour,
    transaction_type,
    transaction_size,
    transaction_duration,
    transaction_to_balance_pct,
    minutes_since_last_transaction,
    location,
    channel,
    device_id,
    ip_address,
    customer_age,
    age_group,
    customer_occupation,
    login_attempts,
    account_balance,
    is_fraud_flagged,
    fraud_flag_reason,
    risk_tier
from transactions