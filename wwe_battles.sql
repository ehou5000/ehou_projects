drop view if exists ehou.wwe_battles;
create view ehou.wwe_battles as


select
    to_date(from_unixtime(cast(ba.collector_date_t/1000 as bigint))) as battle_date
    ,ba._battle_type_s
    ,case when _chapter_s ilike 'League_Daily%' then 'League_Daily'
             when _chapter_s ilike 'League_Event%' then concat(split_part(_chapter_s, '_',1), split_part(_chapter_s, '_',2), split_part(_chapter_s, '_',3))
             when _chapter_s ilike 'League_Recurrent%' then _chapter_s
             when _chapter_s ilike 'FightCard%' then _chapter_s
             when _chapter_s ilike 'League_Title%' then _chapter_s
             when _chapter_s is null then _book_s
             else _chapter_s
             end as battle_mode
    ,ds.is_customer
    ,sum(1) as battles
    ,count(distinct ba.device_token_s) as cnt_devices
from
    whiplash.battle ba
    left join biz.device_summary ds
        on ba.device_token_s = ds.device_token
        --and ti.product_id = ds.product_id
where
     nvl(ds.device_quality, 'good') in ('good', 'suspect cheater')

group by
    1,2,3,4;


select battle_date, battle_mode, sum(battles), sum(cnt_devices)
from ehou.wwe_battles
where battle_date >= '2016-12-01'
group by 1,2
order by 1.2
;



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

 BATTLE_DATA as (
  
  SELECT ba.device_token_s AS device_token
         ,ba.`_battle_type_s` AS battle_type
         ,ba.`_chapter_s` AS chapter
         ,CASE WHEN concat(split(ba.`_chapter_s`,'[\_]')[0],split(ba.`_chapter_s`,'[\_]')[1]) is NULL THEN split(ba.`_chapter_s`,'[\_]')[0]
          ELSE concat(split(ba.`_chapter_s`,'[\_]')[0],split(ba.`_chapter_s`,'[\_]')[1]) END AS chapter_part
          ,I.build_version
          ,I.install_cohort
          ,I.country
          ,I.channel
          ,I.platform
          ,I.publisher

         ,count(*) AS cnt
  FROM whiplash.battle ba
    INNER JOIN INSTALL I
        ON I.device_token = ba.device_token_s
  WHERE
     ba.year = 2016
     and ba.month = 12
     and ba.day = 20
  GROUP BY ba.device_token_s ,ba.`_battle_type_s`,ba.`_chapter_s`,split(ba.`_chapter_s`,'[\_]')[1],I.build_version
          ,I.install_cohort
          ,I.country
          ,I.channel
          ,I.platform
          ,I.publisher
  )

 SELECT build_version, count(distinct device_token)
 from BATTLE_DATA
 GROUP BY build_version ORDER BY build_version;