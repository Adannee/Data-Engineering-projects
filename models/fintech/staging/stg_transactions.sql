with source as (
    select * from {{source('fintech_raw', 'TRANSACTIONS')}}
),

renamed as (
    select
    TRANSACTION_ID as transaction_id,
    ACCOUNT_ID as account_id,
    TRANSACTION_AMOUNT::float as transaction_amount,
    TRANSACTION_DATE::timestamp as transaction_date,
    TRANSACTION_TYPE as transaction_type,
    LOCATION as location,
    DEVICE_ID as device_id,
    IP_ADDRESS as ip_address,
    MERCHANT_ID as merchant_id,
    CHANNEL as channel,
    CUSTOMER_AGE::int as customer_age,
    CUSTOMER_OCCUPATION as customer_occupation,
    TRANSACTION_DURATION::int as transaction_duration,
    LOGIN_ATTEMPTS::int as login_attempts,
    ACCOUNT_BALANCE::float as account_balance,
    PREVIOUS_TRANSACTION_DATE::timestamp as previous_transaction_date 
    from source

)

select * from renamed
