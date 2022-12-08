-- ASSETS Table (partner/platform specific)
select * from dictionary.public.powr_assets

-- wurl format title
  update wurl_viewership
  set formatted_title = standardize(title)
  where formatted_title is null and year = 2022 and quarter = 'q2'


--WURL update
    update wurl_viewership wv
    set wv.ref_id = q.asset_ref_id , wv.content_provider = q.content_provider, wv.series = q.series
    from (
      select 
        wv.id as viewership_id,
        wv.formatted_title as viewership_title, 
        a.formatted_title as asset_title, 
        soundex(wv.formatted_title) as sound_1, 
        soundex(a.formatted_title) as sound_2, 
        fuzzy_score(a.formatted_title, wv.formatted_title) as spell_score, 
        fuzzy_score(soundex(wv.formatted_title), soundex(a.formatted_title)) as sound_score , 
        ((spell_score * 1)+(sound_score * 2))/3 weighted_composite_score, 
        wv.id as viewership_record_id, 
        a.ref_id as asset_ref_id, 
        a.content_provider as content_provider,
        a.series as series
      from wurl_viewership wv
      cross join dictionary.public.assets  a
      where  year = 2022  and quarter = 'q2' and deal_parent = 44 and spell_score > .8 and weighted_composite_score > .6 and (wv.ref_id = 'externalId' or wv.ref_id is null)
      limit 1000
    ) q 
    where wv.id = q.viewership_id

-- wurl viewership
select count(deal_parent), deal_parent  from wurl_viewership where year = 2022 and quarter = 'q2'
group by deal_parent

-- wurl viewership
select title, series, ref_id, content_provider, partner, deal_parent from wurl_viewership 
where year = 2022 and quarter = 'q2' and content_provider is not null and series is not null 



--wurl matching (if series is null; using platform content name)
update wurl_viewership w 
set w.ref_id = q.a_ref_id, w.content_provider = q.cp_name, w.series = q.assets_series
from (
    select REPLACE(w.title, '"', '') as wurl_title, a.title as assets_title, w.series as wurl_series, a.series as assets_series, soundex(w.title) t1, soundex(a.title) t2, fuzzy_score(a.title, w.title) v3, fuzzy_score(soundex(w.title), soundex(a.title)) v4 , 
    ((v3*1)+(v4*2))/3 weighted_composite_score,
    w.id as p_id, a.ref_id as a_ref_id, a.content_provider as cp_name
    from wurl_viewership w
    cross join dictionary.public.powr_assets  a
    where quarter = 'q2' and year = 2022  and weighted_composite_score > .85
        and w.series is null and a.partner = 'Wurl' and w.ref_id = 'externalId'
    LIMIT 1000 
    ) q 
where q.p_id = w.id


select * from dictionary.public.powr_assets

-- wurl 2
update wurl_viewership wv
set wv.series = q.series_name, wv.content_provider = q.content_provider
from (
   select wv.id as qid, wv.title, a.title, a.content_provider as content_provider, wv.id as p_id, a.series as series_name, a.ref_id, wv.ref_id
   from wurl_viewership wv
   join dictionary.public.powr_assets a on (wv.ref_id = a.ref_id)
   where quarter = 'q2' and year = 2022 and wv.channel_id = 13 and (wv.content_provider is null or wv.series is null) and (wv.ref_id is not null and wv.ref_id != 'externalId')
) q 
where wv.id = q.qid

--wurl 3
update wurl_viewership wv
set wv.series = q.series_name, wv.content_provider = q.content_provider, wv.ref_id = q.aref_id
from (
   select wv.id as qid, wv.title, a.title, a.content_provider as content_provider, a.series as series_name, a.ref_id as aref_id
   from wurl_viewership wv
   join dictionary.public.powr_assets a on (REPLACE(wv.title, '"', '') = a.title)
   where quarter = 'q2' and year = 2022 and (wv.content_provider is null or wv.series is null)
) q 
where wv.id = q.qid

select REPLACE(title, '"', '') from wurl_viewership 
where quarter = 'q2' and year = 2022 and (content_provider is null or series is null) 

select * from wurl_viewership 
where quarter = 'q2' and year = 2022 and channel_id = 13 and (content_provider is null or series is null or ref_id is null) 