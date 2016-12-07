WITH INSTALL AS (
SELECT 
   BD.device_token
  ,BD.product_id
  ,to_date(install_time)              AS install_cohort
  ,platform_name                      AS platform
  ,country
  ,LOWER(pub.channel_name)            AS channel
  ,install_app_version                AS build_version
  ,CASE 
      WHEN  LOWER(PUB.publisher_name) LIKE "%unmatched%" 
       AND  LOWER(PUB.channel_name)   LIKE "%organic%"
      THEN "organic"
      ELSE LOWER(PUB.publisher_name)
   END                                AS publisher
FROM biz.device_SUMmary BD
LEFT JOIN biz.dim_publisher PUB  ON BD.publisher_id = PUB.publisher_id
WHERE (device_quality = 'good' OR device_quality = 'suspect cheater')
  AND BD.product_id  = 35
  AND platform_name IN ('ios', 'android')
  AND LOWER(install_app_version) NOT LIKE '%dev%'
  AND country IN ('AU','NZ','SE','IE','NL','CA')
  AND to_date(install_time) >= '2016-12-01'
),


--Gacha
 lt_gacha as (

select  a._item_id_s as 'currency'
        , a._context_s as 'item'
        , -a._quantity_n as 'amount_spent'
        , a.device_token_s as 'device_token'
        , a._transaction_id_s as 'transaction_id'
        , a._trans_desc_s as 'trans_desc'
from whiplash.sys_game_transaction a
join INSTALL b
        on a.device_token_s=b.device_token
        
where year = 2016
and month  = 12
and _trans_type_s = 'gacha'
--and _trans_desc_s = 'Limited Time'
and _quantity_n < 0 

)

select  trans_desc, currency, item, amount_spent, count(distinct device_token)
from lt_gacha
group by 1,2,3,4
order by 1,2,3,4
;

/*
select _trans_desc_s, _item_id_s, count(*)
from whiplash.sys_game_transaction
where year = 2016
and month  = 12
and _trans_type_s = 'gacha'
--and _trans_desc_s = 'Limited Time'
group by 1,2
order by 1,2
;

select _trans_type_s, count(*)
from whiplash.sys_game_transaction
where year = 2016
and month  = 12
group by 1
order by 1
;*/