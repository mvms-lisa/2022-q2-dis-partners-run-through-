-- PLUTO_VIEWERSHIP 
    -- pluto (download viewership from https://drive.google.com/drive/u/0/folders/1e6LqTWwMYQqZUrNNF5NjzyiM50vht5Uf)

        -- pluto us
        copy into PLUTO_VIEWERSHIP(year_month_day, series, title, platform_content_name, season_num, episode_num, tot_mov, sessions, revenue, deal_parent, territory_id, year,quarter,filename)
        from (select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, to_number(REPLACE(REPLACE(t.$7, '-', '0'), ','), 12, 0),  to_number(REPLACE(t.$8, ','), 12, 0), to_decimal(REPLACE(REPLACE(t.$9, '$'), ','), 12, 2), 29, 1, 2022, 'q2', 'only_US_pluto_q2_22.csv'
        from @distribution_partners t) pattern='.*only_US_pluto_q2_22.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;


        -- non-us grouped
            copy into PLUTO_VIEWERSHIP(platform_content_name, year_month_day, revenue, territory_id, year, quarter, channel_id, filename) 
            from (select t.$1, t.$2, to_number(REPLACE(REPLACE(REPLACE(t.$3, '-', 0), '$'), ','), 12,2), t.$4, 2022, 'q2', 8, 'non_US_pluto_q2_22' from @distribution_partners t) pattern='.*non_US_pluto_q2_22.*' file_format = nosey_viewership 
            ON_ERROR=SKIP_FILE FORCE=TRUE;
            
        -- need to add deal parent 

    -- Youtube (NEED TO PULL MONTHLY) (make Youtube table)
    copy into youtube_viewership(content_id, title, publish_date, views, tot_hov, subscribers_gained, estimated_revenue, impressions, click_through_rate, year_month_day, deal_parent, year, quarter, filename)
    from (select t.$1,t.$2, t.$3, to_number(t.$4, 12, 2), to_number(t.$5, 20,5), to_number(t.$6, 7,0), to_number(t.$7, 20, 4), to_number(t.$8, 12, 2),  to_number(t.$9, 3,0), t.$10, 42, 2022, 'q2', 'youtube_q2_22.csv'
    from @distribution_partners t) pattern='.*youtube_q2_22.csv.*' file_format = nosey_viewership 
    ON_ERROR=SKIP_FILE FORCe=TRUE;

--periscope
copy into periscope_viewership(channel, title, play_count, partner_formatted_time, asset_duration, avg_play_time, avg_playthrough_rate, asset_id, year_month_day, deal_parent, year, quarter, filename)
from (select t.$1, t.$2, to_number(t.$3, 7, 0), t.$4, t.$5, t.$6, to_number(t.$7, 11, 10), t.$8, t.$9, 17, 2022, 'q2', 'xumo_periscope_q2_22.csv'
from @distribution_partners t) pattern='.*xumo_periscope_q2_22.csv.*' file_format = nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE


copy into AMAGI_VIEWERSHIP(
view_date,
platform_channel_name,
platform_content_id,
platform_content_name,
series,
device,
country,
sessions,	
tot_mov,
unique_viewers,
avg_session_count,
avg_duration_per_session,
avg_duration_per_viewer,
year, 
quarter,
filename) 
from (
    select t.$1, t.$2, t.$3, t.$4, t.$5,t.$6, t.$7,
    to_number(t.$8, 12, 2),
    to_number(REPLACE(t.$9, ','), 12, 2),
    to_number(REPLACE(t.$10, ','), 12, 2),
    to_number(REPLACE(t.$11, ','), 8, 2),
    to_number(REPLACE(t.$12, ','), 8, 2),
    to_number(REPLACE(t.$13, ','), 8, 2), 
    2022, 'q2', 'amagi_q2_22.csv'  from @distribution_partners t) pattern='.*amagi_q2_22.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE;


       -- TRC VOD (data usually comes from the '20xx 1x TRC Nosey Baxter LLC Payout Report but might now include revenue from Roku dashboard)
        copy into wurl_viewership(title, revenue, deal_parent, territory_id, year, quarter, filename) 
        from (select t.$1, to_number(REPLACE(REPLACE(t.$2, ','), '$'), 9, 3), 25, 1, 2022, 'q2','trc_vod_q2_22.csv'
        from @distribution_partners t) pattern='.*trc_vod_q2_22.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;

select * from wurl_viewership where year = 2022 and quarter = 'q1'


--wurl
copy into wurl_viewership (date, title, ref_id, episode_number, genre, occurances, tot_hov, tot_sessions, mov_per_session, tot_completions, impressions, tot_airtime_min, channel, deal_parent, territory, year, quarter, filename)
from (select 
            t.$1, 
            t.$2,
            t.$3, 
            t.$4, 
            t.$5, 
            to_number(REPLACE(t.$6, ','), 5, 2), 
            to_number(REPLACE(t.$7, ','), 20, 5), 
            to_number(REPLACE(t.$8, ','), 9, 2),  
            to_number(REPLACE(t.$9, ','), 20, 8), 
            to_decimal(REPLACE(t.$10, ','), 10, 2),
            to_number(REPLACE(t.$12, ','),12, 2),
            to_number(REPLACE(t.$14, ','), 38, 0),
            t.$15,
            t.$16,
            t.$17,      
            2022, 'q2', 'wurl_q2_2022.csv'
        from @distribution_partners t) pattern='.*wurl_q2_2022.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;


-- Rlaxx (process invoice first)
copy into AMAGI_VIEWERSHIP(
channel,
content_name,
revenue_euro,	
year, 
quarter,
channel_id,
territory_id,
deal_parent,
filename) 
from (
    select t.$2, t.$3, 
    to_number(REPLACE(REPLACE(t.$4, ','), '$'), 15, 5),
    2022, 'q2',8, 1, 22, 'rlaxx_q2_2022.csv'  from @distribution_partners t) pattern='.*rlaxx_q2_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE;


--rlaxx q1 fix
copy into amagi_viewership(
CHANNEL,
PLATFORM_CONTENT_NAME,
TOT_HOV,
REF_ID,
DEAL_PARENT,
TERRITORY_ID,
QUARTER,
YEAR,
FILENAME,
SERIES,
CHANNEL_ID,
SHARE,
CONTENT_PROVIDER,
REVENUE,
TERRITORY,
PARTNER,
partner_formatted_time,
VIEWERSHIP_TYPE,
TOT_MOV,
REV_PER_MOV)
from (select t.$1, t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,t.$9,t.$10,t.$11,t.$12,t.$13,t.$14,t.$15,t.$16,t.$17,t.$18,t.$19,t.$20
from @distribution_partners t) pattern='.*rlaxx_q1_22_db_fix.*' file_format = nosey_viewership
ON_ERROR=SKIP_FILE FORCE=TRUE;

select CHANNEL,
PLATFORM_CONTENT_NAME,
TOT_HOV,
REF_ID,
DEAL_PARENT,
TERRITORY_ID,
QUARTER,
YEAR,
FILENAME,
SERIES,
CHANNEL_ID,
SHARE,
CONTENT_PROVIDER,
REVENUE,
TERRITORY,
PARTNER,
partner_formatted_time,
VIEWERSHIP_TYPE,
TOT_MOV,
REV_PER_MOV from amagi_viewership where deal_parent = 22

--rlaxx
copy into AMAGI_VIEWERSHIP(
channel,
platform_content_name,
revenue_euro,	
year, 
quarter,
channel_id,
territory_id,
deal_parent,
partner,
filename) 
from (
    select t.$2, t.$3, 
    to_number(REPLACE(REPLACE(t.$4, ','), '€'), 15, 5),
    2022, 'q2', 8, 1, 22, 'Rlaxx', 'rlaxx_q2_2022.csv'  from @distribution_partners t) pattern='.*rlaxx_q2_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE;

select * from amagi_viewership where year = 2022 and quarter = 'q2' and deal_parent = 39
select * from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 40

select * from dictionary.public.deals

--tubi vod
copy into wurl_viewership(title, partner, revenue, year_month_day, month, deal_parent, territory_id, viewership_type, year, quarter, filename)
from (select t.$1, t.$2, to_number(REPLACE(t.$3, '$'), 20, 4), t.$4, t.$5, 40, 1, 'VOD', 2022, 'q2', 'tubi_vod_q2_2022.csv'
from @distribution_partners t) pattern='.*tubi_vod_q2_2022.csv.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE FORCE=TRUE;


update 
    periscope_viewership p
set p.tot_hov = q.tot_hov
from (
    select 
        id,
        partner_formatted_time, 
        split_part(partner_formatted_time, ':', 1) as hrs, 
        split_part(partner_formatted_time, ':', 2) / 60 as min, 
        split_part(partner_formatted_time, ':', 3) / 3600 as sec,
        (hrs + min + sec) as tot_hov
    from 
        periscope_viewership 
    where 
        year = 2022 
        and 
        quarter = 'q2'
        and
        deal_parent = 17
) q 
where p.id = q.id 

select * from periscope_viewership where year = 2022 and quarter = 'q2'


-- Freevee Upload
copy into freevee_viewership(
view_date, 
channel, 
channel_id,
streamer,
platform_content_name,
platform_series_name,
platform_series_id,
tot_hov,
tot_sessions,
mov_per_session,
unique_users,
completions,
month,
year_month_day,
ref_id, 
content_provider, 
series, 
share, 
revenue,
viewership_by_episode,
quarter, 
year, 
deal_parent, 
platform, 
filename)
from (
select t.$1,
t.$2,
t.$3,
t.$4,
t.$5,
t.$6,
t.$7,
to_number(REPLACE(t.$8, ','), 20, 5),
to_number(REPLACE(t.$9, ','), 10, 2),
to_number(t.$10, 28, 8),
to_number(REPLACE(t.$11, ','), 10, 2),
to_number(REPLACE(t.$12, ','), 10, 2),
t.$13,
t.$14,
t.$15,
t.$16,
t.$17,
to_number(REPLACE(t.$18, '%'), 11, 8),
to_number(REPLACE(t.$19, '$'), 20, 5),
to_number(REPLACE(t.$20, ','), 10, 2),
'q2', 2022, 37, 'FreeVee', 'freevee_linear_q2_22.csv'
from @distribution_partners t) pattern='.*freevee_linear_q2_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE FORCE=TRUE;


-- Freevee Linear
select * from freevee_viewership where deal_parent = 37

update freevee_viewership
set partner = 'FreeVee Linear US'
where year = 2022 and quarter = 'q2' and deal_parent = 37


--  series id update
update freevee_viewership f 
set f.series_id = q.series_id
from (
  select f.id as id, f.series, s.term, f.content_provider, s.series_id as series_id
  from freevee_viewership f 
  join dictionary.public.series s on (s.entry = f.series)
  where year = 2022 and quarter = 'q2'
)q
where q.id = f.id

