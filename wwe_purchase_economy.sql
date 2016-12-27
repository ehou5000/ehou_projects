with installs as (
  select device_summary.device_token, to_date(install_time) as install_date, platform_name
  , is_customer
  , install_app_version
  , device_summary.product_id
  from biz.device_summary device_summary
  left join biz.dim_publisher dim_publisher
  on device_summary.publisher_id = dim_publisher.publisher_id
  where device_summary.device_quality in ('suspect cheater','good') 
  and device_summary.product_id = 35
),

payments as (

        select  device_token_s as device_token
                ,from_unixtime(cast(collector_date_t/1000 as bigint)) as payment_ts
                ,to_date(from_unixtime(cast(collector_date_t/1000 as bigint))) as payment_date
                ,_amount_us_n/100 as amount
                , _game_sku_s as package 
                ,_player_level_n as playerlevel
                ,_hc_balance_n as hcbalance
                ,_sc_balance_n as scbalance
                ,_roster_count_n as rostersize
        from whiplash.sys_payment
        where to_date(from_unixtime(cast(collector_date_t/1000 as bigint))) >= '2016-10-01'
        and cast(_success_b as string) = '1'
        --and _success_b = true
        group by 1,2,3,4,5,6,7,8,9
)

select package, payment_date, count(distinct device_token) as buyers
from (
select device_token
        ,package
        ,payment_date
        ,row_number() over(partition by device_token order by payment_ts) as rn
from payments
order by device_token, rn
)
where rn = 1
group by 1,2
order by 1,2
;

select payment_date
        ,package
        ,count(distinct a.device_token) as buyers
        ,sum(amount) as amount_usd
        ,count(*) as txns
from payments a
join installs b 
on a.device_token = b.device_token
group by 1,2
order by 1,2
;

refresh whiplash.sys_payment;