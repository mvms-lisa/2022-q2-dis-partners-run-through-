-- Q1 Revenue
select * from revenue where year = 2022 and quarter = 'q1' and title like '%PlutoTV%'

-- Q2 Revenue Check
select * from revenue where year = 2022 and quarter = 'q2' and type like '%Pluto%'


--YouTube
select sum(estimated_revenue), sum(impressions), year_month_day from youtube_viewership where year = 2022 and quarter = 'q2'
group by year_month_day

--Create Insert Statement for YouTube

-- Revenue Upload
        copy into revenue (year_month_day, title, impressions, cpms, amount, territory_id, channel_id, deal_parent, type, department, year, quarter, filename)
        from (
            select 
            t.$1, 
            t.$2,
            to_number(REPLACE(t.$3, ','), 16, 2),  
            to_number(REPLACE(t.$4, '$'), 8, 2),
            to_number(REPLACE(REPLACE(t.$5, '$'), ','), 12, 2), 
            t.$6,
            t.$7,
            t.$8,
            t.$9,
            t.$10,
            2022,
            'q2',
            'dist_partners_revenue_q2_2022.csv'
        from @DISTRIBUTION_PARTNERS_REVENUE t) pattern='.*dist_partners_revenue_q2_2022.*' file_format = nosey_viewership 
        FORCE=TRUE ON_ERROR=SKIP_FILE;
        
        
        
-- 47 Samurai 
      copy into revenue (year_month_day, impressions, amount, cpms, department,deal_parent, title, label, type, territory_id, year, quarter, filename)
        from (select t.$1, 
            to_number(REPLACE(t.$2, ','), 16, 2),  
            to_number(REPLACE(REPLACE(t.$3, '$'), ','), 12, 2), 
            to_number(REPLACE(t.$4, '$'), 8, 2),
            t.$5,
            t.$6,
            t.$7,
            t.$8,
            t.$9,
            t.$10,
            t.$11,
            t.$12,
            '47_samurai_q2_2022.csv'
        from @DISTRIBUTION_PARTNERS_REVENUE t) pattern='.*47_samurai_q2_2022.*' file_format = nosey_viewership 
        FORCE=TRUE ON_ERROR=SKIP_FILE;
        
 -- Pluto Viewership
 select sum(revenue), year_month_day from pluto_viewership where year = 2022 and quarter = 'q2' and territory_id = 1
 group by year_month_day
 
  -- Pluto Viewership
 select * from pluto_viewership where year = 2022 and quarter = 'q2' and territory_id = 7

 
-- Pluto US insert
insert into revenue(amount, year, quarter, deal_parent, year_month_day, type, title, channel_id, channel, territory_id, territory, department, month, description, label)
select sum(revenue), year, quarter, deal_parent, year_month_day, 'PlutoTV Revenue' as type, 'PlutoTV' as title, 
channel_id, channel, territory_id, territory, 'PlutoTV' as department, month, 'Revenue' as description,  'Revenue' as label 
from pluto_viewership where year = 2022 and quarter = 'q2' and deal_parent = 29 
group by year_month_day, year, quarter, deal_parent, year_month_day, channel_id, channel, territory_id, territory, month

-- Pluto Brazil insert
insert into revenue(amount, year, quarter, deal_parent, year_month_day, type, title, channel_id, channel, territory_id, territory, department, month, description, label)
select sum(revenue), year, quarter, deal_parent, year_month_day, 'PlutoTV Brazil Revenue' as type, 'PlutoTV Brazil' as title, 
channel_id, channel, territory_id, territory, 'PlutoTV' as department, month, 'Revenue' as description,  'Revenue' as label 
from pluto_viewership where year = 2022 and quarter = 'q2' and deal_parent = 29 and territory_id = 7
group by year_month_day, year, quarter, deal_parent, year_month_day, channel_id, channel, territory_id, territory, month

-- Pluto LATAM insert
insert into revenue(amount, year, quarter, deal_parent, year_month_day, type, title, channel_id, channel, territory_id, territory, department, month, description, label)
select sum(revenue), year, quarter, deal_parent, year_month_day, 'PlutoTV LATAM Revenue' as type, 'PlutoTV LATAM' as title, 
channel_id, channel, territory_id, territory, 'PlutoTV' as department, month, 'Revenue' as description, 'Revenue' as label 
from pluto_viewership where year = 2022 and quarter = 'q2' and deal_parent = 29 and territory_id = 3
group by year_month_day, year, quarter, deal_parent, year_month_day, channel_id, channel, territory_id, territory, month


-- Pluto UK insert
insert into revenue(amount, year, quarter, deal_parent, year_month_day, type, title, channel_id, channel, territory_id, territory, department, month, description, label)
select sum(revenue), year, quarter, deal_parent, year_month_day, 'PlutoTV UK Revenue' as type, 'PlutoTV UK' as title, 
channel_id, channel, territory_id, territory, 'PlutoTV' as department, month, 'Revenue' as description, 'Revenue' as label 
from pluto_viewership where year = 2022 and quarter = 'q2' and deal_parent = 29 and territory_id = 5
group by year_month_day, year, quarter, deal_parent, year_month_day, channel_id, channel, territory_id, territory, month

--Pluto Nordic
insert into revenue(amount, year, quarter, deal_parent, year_month_day, channel_id, channel, territory_id, territory, department, month, description, label)
select sum(revenue), year, quarter, deal_parent, year_month_day, 
channel_id, channel, territory_id, territory, 'PlutoTV' as department, month, 'Revenue' as description, 'Revenue' as label 
from pluto_viewership where year = 2022 and quarter = 'q2' and deal_parent = 29 and territory_id in (34, 67, 76)
group by year_month_day, year, quarter, deal_parent, year_month_day, channel_id, channel, territory_id, territory, month

-- update
update revenue
set title = 'PlutoTV SE', type = 'PlutoTV SE Revenue'
where year = 2022 and quarter = 'q2' and title is null and type is null and territory_id = 76

-- TRC VOD
insert into quarterly_revenue(deal_parent, quarter, amount, channel, channel_id, year, department)
select deal_parent, quarter, sum(revenue) as amount, channel, channel_id, year, 'TRC VOD' as department from wurl_viewership 
where deal_parent = 25 and quarter = 'q2' and year = 2022 
group by deal_parent, year_month_day, year, quarter, channel_id, channel

select * from wurl_viewership where year = 2022 and quarter = 'q1' and deal_parent = 25

select * from quarterly_revenue where year = 2022 and quarter = 'q2' and deal_parent = 16

-- TRC Totals insert (Nosey, Nosey Escandalos, Real Nosey)
insert into quarterly_revenue(deal_parent, quarter, amount, channel, channel_id, year, department)
values (16, 'q2', 354972.59, 'Nosey', 8, 2022, 'TRC'),
       (16, 'q2', 255078.29, 'Real Nosey', 9, 2022, 'TRC'),
       (16, 'q2', 14341.51, 'Nosey Escandalos', 13, 2022, 'TRC');
 
-- TRC TOTALS insert (Nosey Casos and NA)
insert into quarterly_revenue(deal_parent, quarter, amount, channel, channel_id, year, department)
values (16, 'q2', 4046.96, 'Nosey Casos', 11, 2022, 'TRC'),
       (16, 'q2', 5459.91, '#N/A (Title Not Identifiable)', NULL, 2022, 'TRC');

       
       
-- update trc vod and trc linear quarterly revenue 
select amount/3, channel_id from quarterly_revenue 
where year = 2022 and quarter = 'q2' and deal_parent = 25


-- trc vod
insert into revenue(year_month_day, month, year, quarter, deal_parent, amount, type, title, department, description, channel_id, channel, territory_id, territory)
values ('20220401', 4, 2022, 'q2', 25, 35216.91,'TRC VOD Revenue', 'The Roku Channel Revenue', 'The Roku Channel', 'Revenue', 8, 'Nosey', 1, 'United States'),
       ('20220501', 5, 2022, 'q2', 25, 35216.91,'TRC VOD Revenue', 'The Roku Channel Revenue', 'The Roku Channel', 'Revenue', 8, 'Nosey', 1, 'United States'),
       ('20220601', 6, 2022, 'q2', 25, 35216.91,'TRC VOD Revenue', 'The Roku Channel Revenue', 'The Roku Channel', 'Revenue', 8, 'Nosey', 1, 'United States')
       
       
-- plex 
select * from revenue where year = 2022 and quarter = 'q2' and gross_revenue is not null

copy into revenue(date_unformatted, year_month_day, channel, channel_id, cpms, gross_revenue, amount, impressions, type, title, year, quarter, deal_parent, department, description, territory, territory_id, label, filename)
from (select t.$1, 
             t.$2, 
             t.$5,
             t.$6, 
             to_number(REPLACE(REPLACE(t.$7, '$'), ','), 8, 2),
             to_number(REPLACE(REPLACE(t.$8, '$'), ','), 12, 2),
             to_number(REPLACE(REPLACE(t.$11, '$'), ','), 12, 2),
             to_number(REPLACE(t.$12, ','), 16, 2), 
             t.$13,
             t.$14,
             2022, 'q2', 21, 'Plex', 'Revenue', 'United States', 1, 'Revenue', 'plex_revenue_q2_2022.csv'
from @distribution_partners_revenue t) pattern='.*plex_revenue_q2_2022.*' file_format = nosey_viewership
FORCE=TRUE ON_ERROR=SKIP_FILE;


-- update month plex
update revenue
set month = 6
where year_month_day = 20220601 and month is null


       


