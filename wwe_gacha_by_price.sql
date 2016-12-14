select trans_type, trans_desc, item_id, quantity, count(*)
from biz.transaction_item
where product_id = 35
and trans_type = 'gacha'
and trans_date >= '2016-12-01'
and item_id = 'HardCurrency'
group by 1,2,3,4
order by 1,2,3,4
limit 9999
;