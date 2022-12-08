-- check if anything is msising ref_id
    select * from pluto_viewership 
    where (ref_id = 'externalId' or ref_id is null) and  quarter = 'q2' and year = 2022
    
-- All pluto
select title, series, series_id, ref_id, content_provider from pluto_viewership where year = 2022 and quarter = 'q2' and ref_id is null and title = 'Steve¬†Over¬†the Edge'


select * from pluto_viewership where year = 2022 and quarter = 'q2' and title like '%Steve¬†Over¬†the Edge'

-- update
update pluto_viewership
set ref_id = 'SW-1786', content_provider = 'NBC', title = 'Steve Over the Edge', series = 'The Steve Wilkos Show'
where year = 2022 and quarter = 'q2' and title like '%Steve¬†Over¬†the Edge' and ref_id is null
   
-- series 
select * from dictionary.public.series 

-- powr_assets
select * from dictionary.public.powr_assets where partner = 'Pluto'


-- Update series
update pluto_viewership p
set p.series_id = q.series_id
from (
  select p.id as id,  p.series, d.term, d.series_id from pluto_viewership p
  join dictionary.public.series d on (d.entry = p.series)
  where p.series_id is null and quarter = 'q2' and year = 2022 
) q
where q.id = p.id
    
-- NOTES 11/18/22 i first used assets.public.metadata then used dictionary.public.assets

-- pluto 
update pluto_viewership pv
set pv.ref_id = q.refid , pv.content_provider = q.content_provider
from (
   select pv.id as qid, pv.title, a.title, soundex(pv.title) t1, soundex(a.title) t2, fuzzy_score(a.title, pv.title) v3, fuzzy_score(soundex(pv.title), soundex(a.title)) v4 , 
   ((v3*1)+(v4*2))/3 weighted_composite_score, a.content_provider as content_provider,
   pv.id as p_id, a.ref_id as refid, pv.series as p_series, a.series as a_series
   from pluto_viewership pv
   cross join dictionary.public.assets a
   where a.series_id = pv.series_id and quarter = 'q2' and year = 2022 and pv.title not like '%Part%' and (pv.ref_id = 'externalId' or pv.ref_id is null) 
  and (weighted_composite_score > .70) and
  LIMIT 1000
) q 
where pv.id = q.qid

-- pluto 2
update pluto_viewership pv
set pv.ref_id = q.refid , pv.content_provider = q.content_provider
from (
   select pv.id as qid, pv.title, a.title, soundex(pv.title) t1, soundex(a.title) t2, fuzzy_score(a.title, pv.title) v3, fuzzy_score(soundex(pv.title), soundex(a.title)) v4 , 
   ((v3*1)+(v4*2))/3 weighted_composite_score, a.content_provider as content_provider,
   pv.id as p_id, a.ref_id as refid
   from pluto_viewership pv
   cross join dictionary.public.assets a
   where pv.series_id = 32 and a.series_id = 32 and  quarter = 'q2' and year = 2022  and territory_id = 1 and (pv.ref_id = 'externalId' or pv.ref_id is null) and (weighted_composite_score > .8)
  LIMIT 1000
) q 
where pv.id = q.qid

-- pluto 2
update pluto_viewership pv
set pv.ref_id = q.refid, pv.content_provider = q.content_provider
from (
   select pv.id as qid, pv.title, a.title, a.content_provider as content_provider, pv.id as p_id, a.ref_id as refid
   from pluto_viewership pv
   join dictionary.public.assets a on (pv.series_id = a.series_id and pv.title = a.title)
   where quarter = 'q2' and year = 2022 and (pv.ref_id = 'externalId' or pv.ref_id is null) 
  LIMIT 1000
) q 
where pv.id = q.qid


--PLUTO LOAD 
copy into dictionary.public.powr_assets(title, ref_id, series, content_provider, filenam, partner)
from (select t.$1, t.$2, t.$3, t.$4, 'pluto_assets_q2_2022.csv', 'Pluto' from @nosey_assets t)
pattern='.*pluto_assets_q2_2022.*'
file_format=nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE;


--pluto matching (if series is null; using platform content name)
update pluto_viewership p 
set p.ref_id = q.a_ref_id, p.content_provider = q.cp_name, p.series = q.assets_series
from (
    select p.platform_content_name as pluto_title, a.title as assets_title, p.series as pluto_series, a.series as assets_series, soundex(p.title) t1, soundex(a.title) t2, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    p.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from pluto_viewership p
    cross join dictionary.public.powr_assets  a
    where quarter = 'q2' and year = 2022 and p.ref_id is null and weighted_composite_score > .95 and p.series is null
    LIMIT 1000 
    ) q 
where q.p_id = p.id

--pluto matching (if series is not null)
update pluto_viewership p 
set p.ref_id = q.a_ref_id, p.content_provider = q.cp_name
from (
    select p.platform_content_name as pluto_title, a.title as assets_title, p.series as pluto_series, a.series as assets_series, soundex(p.title) t1, soundex(a.title) t2, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    p.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from pluto_viewership p
    cross join dictionary.public.powr_assets a
    where quarter = 'q2' and year = 2022 and p.ref_id is null and weighted_composite_score > .95 and a.partner = 'Pluto'
    LIMIT 1000 
    ) q 
where q.p_id = p.id

--pluto matching (if series is not null)
update pluto_viewership p 
set p.ref_id = q.a_ref_id, p.content_provider = q.cp_name
from (
    select p.platform_content_name as pluto_title, a.title as assets_title, p.series as pluto_series, a.series as assets_series, soundex(p.title) t1, soundex(a.title) t2, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    p.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from pluto_viewership p
    cross join dictionary.public.powr_assets a
    where quarter = 'q2' and year = 2022 and p.ref_id is null and p.platform_content_name = a.title and a.partner = 'Pluto'
    LIMIT 1000 
    ) q 
where q.p_id = p.id

--pluto matching (if series is null; using platform content name)
update pluto_viewership p 
set p.ref_id = q.a_ref_id, p.content_provider = q.cp_name, p.series = q.assets_series
from (
    select p.platform_content_name as pluto_title, a.title as assets_title, p.series as pluto_series, a.series as assets_series, soundex(p.title) t1, soundex(a.title) t2, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    p.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from pluto_viewership p
    cross join dictionary.public.powr_assets  a
    where quarter = 'q2' and year = 2022 and p.ref_id is null and weighted_composite_score > .95 and p.series is null
    LIMIT 1000 
    ) q 
where q.p_id = p.id