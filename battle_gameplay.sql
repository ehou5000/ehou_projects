select _battle_type_s
        , _stage_id_1_s
        , split_part(_stage_id_1_s, '_',3)
        , concat(split_part(_stage_id_1_s, '_',1), split_part(_stage_id_1_s, '_',2), split_part(_stage_id_1_s, '_',3))
        , count(distinct device_token_s)
from whiplash.battle
where year = 2016
group by 1,2,3
order by 1,2,3
limit 5000
;


select *
from whiplash.battle
where _battle_type_s = 'Limited Time Quest'
and year = 2016
and month = 12
limit 1000
;

select _battle_type_s,_book_s, _chapter_s,_stage_id_1_s, count(*)
from whiplash.battle
where year= 2016
and month = 12
group by 1,2,3,4
order by 1,2,3,4
;