with source as (
    select * from {{ source('supplychain_raw', 'SUPPLY_CHAIN') }}
),

renamed as (
    select
        ORDER_ID::integer                       as order_id,
        ORDER_ITEM_ID::integer                  as order_item_id,
        ORDER_CUSTOMER_ID::integer              as customer_id,
        CUSTOMER_ID::integer                    as customer_account_id,
        CUSTOMER_SEGMENT                        as customer_segment,
        CUSTOMER_CITY                           as customer_city,
        CUSTOMER_STATE                          as customer_state,
        CUSTOMER_COUNTRY                        as customer_country,
        CUSTOMER_ZIPCODE::integer               as customer_zipcode,
       TRY_TO_TIMESTAMP(ORDER_DATE_DATEORDERS, 'MM/DD/YYYY HH24:MI')   as order_date,
       TRY_TO_TIMESTAMP(SHIPPING_DATE_DATEORDERS, 'MM/DD/YYYY HH24:MI') as shipping_date,
        DAYS_FOR_SHIPPING_REAL::integer         as days_shipping_actual,
        DAYS_FOR_SHIPMENT_SCHEDULED::integer    as days_shipping_scheduled,
        LATE_DELIVERY_RISK::integer             as late_delivery_risk,
        DELIVERY_STATUS                         as delivery_status,
        SHIPPING_MODE                           as shipping_mode,
        ORDER_STATUS                            as order_status,
        ORDER_CITY                              as order_city,
        ORDER_STATE                             as order_state,
        ORDER_COUNTRY                           as order_country,
        ORDER_REGION                            as order_region,
        MARKET                                  as market,
        CATEGORY_ID::integer                    as category_id,
        CATEGORY_NAME                           as category_name,
        DEPARTMENT_ID::integer                  as department_id,
        DEPARTMENT_NAME                         as department_name,
        PRODUCT_CARD_ID::integer                as product_id,
        PRODUCT_NAME                            as product_name,
        PRODUCT_PRICE::float                    as product_price,
        PRODUCT_STATUS::integer                 as product_status,
        TYPE                                    as payment_type,
        ORDER_ITEM_QUANTITY::integer            as order_quantity,
        ORDER_ITEM_PRODUCT_PRICE::float         as item_price,
        ORDER_ITEM_DISCOUNT::float              as item_discount,
        ORDER_ITEM_DISCOUNT_RATE::float         as item_discount_rate,
        ORDER_ITEM_TOTAL::float                 as item_total,
        SALES::float                            as sales,
        BENEFIT_PER_ORDER::float                as benefit_per_order,
        SALES_PER_CUSTOMER::float               as sales_per_customer,
        ORDER_ITEM_PROFIT_RATIO::float          as item_profit_ratio,
        ORDER_PROFIT_PER_ORDER::float           as order_profit
    from source
)

select * from renamed