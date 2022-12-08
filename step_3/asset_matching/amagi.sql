
--AMAGI viewership
select * from amagi_viewership where year = 2022 and quarter = 'q2' and deal_parent = 22 and ref_id is null

--AMAGI viewership
select title, series, content_provider, ref_id, partner, channel from amagi_viewership where year = 2022 and quarter = 'q2' 
and content_provider is null and deal_parent = 30 

update amagi_viewership
set content_provider = 'NBC'
where year = 2022 and quarter = 'q2' 
and deal_parent = 30 and content_provider is null



select * from dictionary.public.powr_assets where partner = 'Samsung' and ref_id = 'SJ-0120'



-- TO DO COMBINE REF_ID, SERIES_ID UPDATES (ALSO CP UPDATE IF POSSIBLE, AND TOT_HOV?) THE MORE IN ONE THE BETTER
-- update ref_id
    update amagi_viewership av
    set av.ref_id = q.ref_id_b
    from(
    select get_ref_id_amagi(platform_content_id) as ref_id_b, * from amagi_viewership where year = 2022 and quarter = 'q2' and deal_parent = 30
    ) q
    where av.id = q.id
    
--AMAGI with ref_id 
update amagi_viewership av
set av.content_provider = q.content_provider
from (
   select av.id as qid, av.title, a.title, a.content_provider as content_provider, av.id as p_id, a.series as series_name, a.ref_id, av.ref_id
   from amagi_viewership av
   join dictionary.public.powr_assets a on (av.ref_id = a.ref_id)
   where quarter = 'q2' and year = 2022 and av.deal_parent = 30 and a.partner = 'Samsung' and av.content_provider is null and av.ref_id is not null
) q 
where av.id = q.qid

-- AMAGI weighted comp score
update amagi_viewership av 
set av.ref_id = q.a_ref_id, av.content_provider = q.cp_name, av.series = q.assets_series
from (
    select av.platform_content_name as amagi_title, a.title as assets_title, av.series as amagi_series, a.series as assets_series, soundex(av.title) t1, soundex(a.title) t2, fuzzy_score(a.title, av.title) v3, fuzzy_score(soundex(av.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    av.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from amagi_viewership av
    cross join dictionary.public.powr_assets  a
    where quarter = 'q2' and year = 2022 and av.ref_id is null and weighted_composite_score > .95 and av.series is null and av.deal_parent = 22
    LIMIT 1000 
    ) q 
where q.p_id = av.id

select * from dictionary.public.deals where id = 27

