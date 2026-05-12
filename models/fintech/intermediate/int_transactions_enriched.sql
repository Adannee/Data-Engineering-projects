with transactions as (
    select * from {{ ref('stg_transactions') }}
),

final as (
    select
        transaction_id,
        account_id,
        transaction_amount,
        transaction_date,
        transaction_type,
        location,
        device_id,
        ip_address,
        merchant_id,
        channel,
        customer_age,
        customer_occupation,
        transaction_duration,
        login_attempts,
        account_balance,
        previous_transaction_date,

        -- Time between transactions in minutes
        datediff('minute',
            previous_transaction_date,
            transaction_date)                       as minutes_since_last_transaction,

        -- Transaction to balance ratio
        round(transaction_amount / nullif(account_balance, 0) * 100, 2) as transaction_to_balance_pct,

        -- Fraud flag logic
        case
            when login_attempts >= 3 then true
            when transaction_amount > 9000 then true
            when transaction_duration > 1000 then true
            when datediff('minute',
                previous_transaction_date,
                transaction_date) < 2 then true
            else false
        end                                         as is_fraud_flagged,

        -- Fraud reason
        case
            when login_attempts >= 3 then 'High Login Attempts'
            when transaction_amount > 9000 then 'Large Transaction Amount'
            when transaction_duration > 1000 then 'High Transaction Duration'
            when datediff('minute',
                previous_transaction_date,
                transaction_date) < 2 then 'Rapid Successive Transaction'
            else 'Clean'
        end                                         as fraud_flag_reason,

        -- Risk tier
        case
            when login_attempts >= 3
                or transaction_amount > 9000 then 'High Risk'
            when transaction_duration > 500
                or transaction_to_balance_pct > 50 then 'Medium Risk'
            else 'Low Risk'
        end                                         as risk_tier,

        -- Age group
        case
            when customer_age < 25 then 'Gen Z'
            when customer_age < 40 then 'Millennial'
            when customer_age < 55 then 'Gen X'
            else 'Boomer'
        end                                         as age_group,

        -- Transaction size tier
        case
            when transaction_amount >= 5000 then 'Large'
            when transaction_amount >= 1000 then 'Medium'
            else 'Small'
        end                                         as transaction_size,

        -- Date dimensions
        date_trunc('month', transaction_date)       as transaction_month,
        date_trunc('week', transaction_date)        as transaction_week,
        dayname(transaction_date)                   as transaction_day_of_week,
        hour(transaction_date)                      as transaction_hour

    from transactions
)

select * from final