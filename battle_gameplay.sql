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

DAU AS (
SELECT 
   /*SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 1   THEN 1 ELSE 0 END) AS d1_app_opens
  ,SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 7   THEN 1 ELSE 0 END) AS d7_app_opens
  ,SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 14  THEN 1 ELSE 0 END) AS d14_app_opens
  ,SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 30  THEN 1 ELSE 0 END) AS d30_app_opens
  ,SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 60  THEN 1 ELSE 0 END) AS d60_app_opens
  ,SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 90  THEN 1 ELSE 0 END) AS d90_app_opens
  ,SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 180 THEN 1 ELSE 0 END) AS d180_app_opens
  ,SUM(CASE WHEN DATEDIFF(BA.activity_date, I.install_cohort) = 360 THEN 1 ELSE 0 END) AS d360_app_opens*/
  
   BA.activity_date
  ,I.build_version
  ,I.install_cohort
  ,I.country
  ,I.channel
  ,I.platform
  ,I.publisher
FROM biz.activity_daily BA
INNER JOIN INSTALL I  
        ON BA.device_token = I.device_token
       AND BA.product_id   = I.product_id
WHERE BA.product_id = 35
GROUP BY
    BA.activity_date 
   ,I.build_version
  ,I.install_cohort
  ,I.country
  ,I.channel
  ,I.platform
  ,I.publisher
),


--battles

BATTLES as (

select a._battle_type_s
        ,b.device_token
        ,b.install_cohort
        ,b.platform
        
        
        ,case when _chapter_s ilike 'League_Daily%' then 'League_Daily'
             when _chapter_s ilike 'League_Event%' then concat(split_part(_chapter_s, '_',1), split_part(_chapter_s, '_',2), split_part(_chapter_s, '_',3))
             when _chapter_s ilike 'League_Recurrent%' then _chapter_s
             when _chapter_s ilike 'FightCard%' then _chapter_s
             when _chapter_s ilike 'League_Title%' then _chapter_s
             when _chapter_s is null then _book_s
             else _chapter_s
             end as 'battle_mode'
        ,count(*) as 'battle_count'
             
from whiplash.battle a
join INSTALL b
        on a.device_token_s=b.device_token
where year = 2016
and month = 12
and day = 4
group by 1,2,3,4,5
order by 1,2,3,4,5
)

select battle_mode, count(distinct device_token) as 'players', sum(battle_count) as 'battles'
from BATTLES
group by 1
order by 1
;

