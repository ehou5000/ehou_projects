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