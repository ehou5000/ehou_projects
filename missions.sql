
select _condition_s, _action_s, count(*), count(distinct _sys_user_id_s)
from whiplash.mission
where year = 2016
and month = 12
group by 1,2
order by 1,2
;