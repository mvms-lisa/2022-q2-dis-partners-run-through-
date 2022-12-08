-- check if anything is msising ref_id
    select * from periscope_viewership 
    where (ref_id = 'externalId' or ref_id is null) and  quarter = 'q2' and year = 2022 
    order by title
    
--periscope
select * from periscope_viewership where year = 2022 and quarter = 'q2' and series_id is null

-- periscope specific columns
select title, series, series_id, ref_id, content_provider from periscope_viewership where year = 2022 and quarter = 'q2'
    
--XUMO LOAD 
copy into dictionary.public.powr_assets(title, ref_id, series, content_provider, filename, partner)
from (select t.$1, t.$2, t.$3, t.$4, 'xumo.csv', 'Xumo' from @nosey_assets t)
pattern='.*xumo_assets_q2_2022.*'
file_format=nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE;

--xumo matching (if series is not null)
update periscope_viewership p 
set p.ref_id = q.a_ref_id, p.content_provider = q.cp_name, p.series = q.assets_series
from (
    select p.title as pluto_title, a.title as assets_title, p.series as xumo_series, a.series as assets_series, soundex(p.title) t1, soundex(a.title) t2, fuzzy_score(a.title, p.title) v3, fuzzy_score(soundex(p.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    p.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from periscope_viewership p
    cross join dictionary.public.powr_assets a
    where quarter = 'q2' and year = 2022 and p.ref_id is null and weighted_composite_score > .95 and a.partner = 'Xumo'
    LIMIT 1000 
    ) q 
where q.p_id = p.id


-- Update series
update periscope_viewership p
set p.series_id = q.series_id
from (
  select p.id as id,  p.series, d.term, d.series_id from periscope_viewership p
  join dictionary.public.series d on (d.entry = p.series)
  where p.series_id is null and quarter = 'q2' and year = 2022 
) q
where q.id = p.id

----- TRC VOD ------

-- check if anything is msising ref_id
    select * from wurl_viewership
    where deal_parent = 25 and (ref_id = 'externalId' or ref_id is null) and  quarter = 'q2' and year = 2022 
    order by title
    
--trc vod
select * from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 25

-- Trc specific columns
select title, series, series_id, ref_id, content_provider from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 25

--TRC VOD LOAD 
copy into dictionary.public.powr_assets(title, ref_id, series, content_provider, filename, partner)
from (select t.$1, t.$2, t.$3, t.$4, 'trc_vod_assets_q2_2022.csv', 'TRC VOD' from @nosey_assets t)
pattern='.*trc_vod_assets_q2_2022.*'
file_format=nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE;

--TRC Asset Matching
update wurl_viewership w 
set w.ref_id = q.a_ref_id, w.content_provider = q.cp_name, w.series = q.assets_series
from (
    select w.title as trc_title, a.title as assets_title, w.series as xumo_series, a.series as assets_series, soundex(w.title) t1, soundex(a.title) t2, fuzzy_score(a.title, w.title) v3, fuzzy_score(soundex(w.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    w.id as w_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from wurl_viewership w 
    cross join dictionary.public.powr_assets a
    where quarter = 'q2' and year = 2022 and w.ref_id is null and weighted_composite_score > .95 and a.partner = 'TRC VOD' and w.deal_parent = 29
    LIMIT 1000 
    ) q 
where q.w_id = w.id

-- Update series TRC VOD
update wurl_viewership w
set w.series_id = q.series_id
from (
  select w.id as id,  w.series, d.term, d.series_id from wurl_viewership w
  join dictionary.public.series d on (d.entry = w.series)
  where w.series_id is null and quarter = 'q2' and year = 2022 and deal_parent = 25
) q
where q.id = w.id


---- YOUTUBE---

--Samsung/YouTube LOAD 
copy into dictionary.public.powr_assets(title, ref_id, series, content_provider, filename, partner)
from (select t.$1, t.$2, t.$3, t.$4, 'samsung_assets_q2_2022.csv', 'Samsung' from @nosey_assets t)
pattern='.*samsung_assets_q2_2022.*'
file_format=nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE;

-- YouTube Asset Matching
update youtube_viewership y 
set y.ref_id = q.a_ref_id, y.content_provider = q.cp_name, y.series = q.assets_series
from (
    select y.title as trc_title, a.title as assets_title, y.series as xumo_series, a.series as assets_series, soundex(y.title) t1, soundex(a.title) t2, fuzzy_score(a.title, y.title) v3, fuzzy_score(soundex(y.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    y.id as y_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from youtube_viewership y 
    cross join dictionary.public.powr_assets a
    where quarter = 'q2' and year = 2022 and y.ref_id is null and weighted_composite_score > .95 and a.partner = 'Samsung'
    LIMIT 1000 
    ) q 
where q.y_id = y.id

-- check if anything is msising ref_id - YOUTUBE
    select * from youtube_viewership
    where (ref_id = 'externalId' or ref_id is null) and  quarter = 'q2' and year = 2022 
    order by title
    
-- YouTube Select All
select * from youtube_viewership where year = 2022 and quarter = 'q2'

-- YouTube specific columns
select title, series, series_id, ref_id, content_provider from youtube_viewership where year = 2022 and quarter = 'q2'

select * from register where year = 2022 and quarter = 'q1' and label = 'Expense'

---- TUBI VOD ----

--- WURL LOAD for Tubi VOD
--TRC VOD LOAD 
copy into dictionary.public.powr_assets(title, ref_id, series, content_provider, filename, partner)
from (select t.$1, t.$2, t.$3, t.$4, 'wurl_assets_q2_2022.csv', 'Wurl' from @nosey_assets t)
pattern='.*wurl_assets_q2_2022.*'
file_format=nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE;

--Tubi VOD Asset Matching
update giant_interactive_viewership g 
set g.ref_id = q.a_ref_id, g.content_provider = q.cp_name, g.series = q.assets_series
from (
    select g.title as trc_title, a.title as assets_title, g.series as xumo_series, a.series as assets_series, soundex(g.title) t1, soundex(a.title) t2, fuzzy_score(a.title, g.title) v3, fuzzy_score(soundex(g.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    g.id as w_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from giant_interactive_viewership g 
    cross join dictionary.public.powr_assets a
    where quarter = 'q2' and year = 2022 and g.ref_id is null and weighted_composite_score > .95 and a.partner = 'Wurl' and g.deal_parent = 40
    LIMIT 1000 
    ) q 
where q.w_id = g.id

-- tubi vod
select * from giant_interactive_viewership where year = 2022 and quarter = 'q2' 


