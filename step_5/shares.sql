-- WURL MONTHLY_VIEWERSHIP
-- Wurl: decide whether to calc share by month only, month and channel, or month channel and territory (add all)
-- (We don't get monthly viewerhip data from TRC VOD or Tubi VOD) 
    -- wurl by month, channel, territory_id
        insert into monthly_viewership (channel, channel_id, year_month_day, month, tot_hov, year, quarter, partner, deal_parent, territory_id, territory, platform)
        select channel, channel_id, year_month_day, month, sum(tot_hov), year, quarter, partner, deal_parent, territory_id, territory, 'wurl' from wurl_viewership 
        where quarter = 'q2' and year = 2022 
        group by channel, channel_id, year_month_day, month, year, quarter, partner, deal_parent, territory_id, territory
        
-- Monthly Viewership
select * from monthly_viewership where year = 2022 and quarter = 'q2' and platform = 'wurl'


-- The Roku Channel (done quarterly) 
    insert into quarterly_viewership(deal_parent, tot_hov,year, quarter, channel, channel_id, territory, territory_id, partner)
    select deal_parent, sum(tot_hov), year, quarter, channel, channel_id, territory, territory_id, partner from wurl_viewership 
    where quarter = 'q2'  and  year = 2022 and deal_parent = 16 
    group by channel, channel_id, deal_parent,year, quarter, territory, territory_id, partner
        
-- quarterly_viewership
select * from quarterly_viewership where year = 2022 and quarter = 'q2'

 -- youtube by month
insert into monthly_viewership (channel, channel_id, year_month_day, month, tot_hov, year, quarter, deal_parent, territory, territory_id, partner, platform)
select channel, channel_id, year_month_day, month, sum(tot_hov), year, quarter, deal_parent,territory, territory_id, partner, 'youtube' from youtube_viewership 
where year = '2022' and quarter = 'q2'
group by channel, channel_id, year_month_day, month, year, quarter, deal_parent, territory, territory_id, partner

-- Monthly Viewership - YouTube
select * from monthly_viewership where year = 2022 and quarter = 'q2' and platform = 'youtube'


-- WURL Record Level Share (excluding TRC Linear and TRC VOD)
-- calculate record level share
select w.id, w.deal_parent,w.channel_id, w.year_month_day, w.tot_hov, mv.tot_hov, (w.tot_hov / mv.tot_hov)as share from wurl_viewership w
join monthly_viewership mv on 
(mv.deal_parent = w.deal_parent and mv.year_month_day = w.year_month_day and mv.channel_id = w.channel_id and mv.territory_id = w.territory_id)
where w.quarter = 'q2' and w.year = 2022  and w.tot_hov is not null  and w.deal_parent not in (16, 25)

-- update records with calulcated share 
update wurl_viewership w 
set w.share = q.share
from (
        select w.id, w.deal_parent,w.channel_id, w.year_month_day, w.tot_hov, mv.tot_hov, (w.tot_hov / mv.tot_hov)as share from wurl_viewership w
        join monthly_viewership mv on 
        (mv.deal_parent = w.deal_parent and mv.year_month_day = w.year_month_day and mv.channel_id = w.channel_id  and  mv.territory_id = w.territory_id)
        where w.quarter = 'q2' and w.year = 2022  and w.tot_hov is not null and w.deal_parent not in (16, 25)
        ) q
where w.id = q.id
        
-- WURL CHECK RECORD LEVEL SHARE
select sum(share), year_month_day, channel_id, territory_id from wurl_viewership where quarter = 'q2' and year = 2022 and deal_parent not in (16,25)
group by year_month_day, channel_id, deal_parent, territory_id


-- WURL Check
select deal_parent, channel_id, channel, share from wurl_viewership where deal_parent not in (16, 25) and year = 2022 and quarter = 'q2'
        

-- TRC VOD (uses quarterly revenue to calculate share)
UPDATE WURL_VIEWERSHIP w
SET w.share = q.calced_share 
FROM (
     SELECT w.id as id, w.deal_parent, w.revenue, w.revenue / qr.amount as calced_share 
     FROM WURL_VIEWERSHIP w
     JOIN quarterly_revenue qr ON (
       qr.deal_parent = w.deal_parent
       and qr.channel_id = w.channel_id
       and qr.year = w.year
       and qr.quarter = w.quarter
        )
     WHERE w.quarter = 'q2'  and w.year = 2022 and w.deal_parent = 25
      ) q
     WHERE w.id = q.id
     
-- check wurl
select * from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 25

-- TRC VOD - Check Share (should equal 1)
select sum(share), channel_id from wurl_viewership where quarter = 'q2' and year = 2022 and deal_parent = 25
group by channel_id


-- TRC Linear (uses quarterly revenue to calculate share)
--Quarterly Viewership Share
UPDATE WURL_VIEWERSHIP w
SET w.quarterly_share = q.quarterly_share 
FROM (
  SELECT w.id as id, w.deal_parent, w.year_month_day, w.tot_hov, share, w.tot_hov / q.tot_hov as quarterly_share 
  FROM WURL_VIEWERSHIP w
  JOIN quarterly_viewership q ON (
                                    q.deal_parent = w.deal_parent
                                    and q.channel_id = w.channel_id
                                    and q.year = w.year
                                    and q.quarter = w.quarter
                                    )
WHERE w.quarter = 'q2'  and w.year = 2022 and w.deal_parent = 16
) q
WHERE w.id = q.id

-- TRC LINEAR check the total share by channel, month, and deal_parent (should equal 1)
      -- viewership share check
          select sum(quarterly_share), channel_id from wurl_viewership where quarter = 'q2' and year = 2022 and deal_parent = 16
          group by channel_id, deal_parent

-- TRC Linear
select * from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 16 and channel_id = 11


-- youtube
        -- calculate record level share
        select y.id, y.deal_parent,y.channel_id, y.year_month_day, y.tot_hov, mv.tot_hov, (y.tot_hov / mv.tot_hov)as share from youtube_viewership y
        join monthly_viewership mv on (mv.deal_parent = y.deal_parent and mv.year_month_day = y.year_month_day and mv.channel_id = y.channel_id  and  mv.territory_id = y.territory_id)
        where  y.deal_parent in (42) and y.tot_hov is not null and y.year = 2022 and y.quarter = 'q2'

        -- update records with calulcated share 
        update  youtube_viewership y
        set y.share = q.share
        from (
          select y.id, y.deal_parent,y.channel_id, y.year_month_day, y.tot_hov, mv.tot_hov, (y.tot_hov / mv.tot_hov)as share from youtube_viewership y
          join monthly_viewership mv on (mv.deal_parent = y.deal_parent and mv.year_month_day = y.year_month_day and mv.channel_id = y.channel_id  and  mv.territory_id = y.territory_id)
          where  y.deal_parent in (42) and y.tot_hov is not null and y.year = 2022 and y.quarter = 'q2'
        ) q
        where y.id = q.id
        
-- CHECK YOUTUBE
select * from youtube_viewership where year = 2022 and quarter = 'q2'

-- CHECK YOUTUBE SHARE by Month
select sum(share), year_month_day from youtube_viewership
where year = 2022 and quarter = 'q2'
group by year_month_day
        


-- Update TRC Linear
update wurl_viewership w 
set w.revenue = q.rev_share
from (
    select w.id as id, w.quarterly_share * qr.amount as rev_share from wurl_viewership w 
    join quarterly_revenue qr on (qr.deal_parent = w.deal_parent and qr.channel_id = w.channel_id and w.year = qr.year and w.quarter = qr.quarter)
    where w.deal_parent = 16 and w.year = 2022 and w.quarter = 'q2' and w.channel_id = 11 and w.month not in (4,5)
) q
where w.id = q.id

-- Check Revenue Sum 
select sum(revenue), year_month_day, channel_id from wurl_viewership 
where year = 2022 and quarter = 'q2' and deal_parent = 16 and revenue is not null
group by year_month_day, channel_id
order by channel_id, year_month_day

-- Insert TRC Linear Revenue
select * from revenue where year = 2022 and quarter = 'q2'

insert into revenue(year, quarter, deal_parent, year_month_day, impressions, channel_id, territory_id, territory, amount, department, month, description, channel, label)
select year, quarter, deal_parent, year_month_day, sum(impressions), channel_id, territory_id, territory, sum(revenue), 'The Roku Channel' as department, month, 'Revenue' as description, channel, 'Revenue' as label
from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 16
group by year_month_day, channel_id, year, quarter, deal_parent, territory_id, territory, month, channel

-- NOSEY CASOS CHECK
select sum(tot_hov), channel from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 16 
group by channel


-- Revenue Check
Select * from revenue where year = 2022 and quarter = 'q2' and deal_parent = 16 

select * from giant_interactive_viewership where year = 2022 and quarter = 'q2'


-- NEW! Monthly Revenue Insert 
insert into MONTHLY_REVENUE(year_month_day, amount, deal_parent, year, quarter, channel_id, territory_id, month, channel, territory)
select year_month_day, sum(amount), deal_parent, year, quarter, channel_id, territory_id, month, channel, territory
from revenue where year = 2022 and quarter = 'q2' and deal_parent = 20 and channel_id != 9
group by year_month_day, deal_parent, year, quarter, channel_id, territory_id, month, channel, territory

-- update wurl revenue by partner
update wurl_viewership w 
set w.revenue = q.rev_share
from (
    select w.id as id, w.share * r.amount as rev_share from wurl_viewership w 
    join revenue r on (r.deal_parent = w.deal_parent and r.year_month_day = w.year_month_day and r.territory_id = w.territory_id and r.channel_id = w.channel_id)
    where w.year = 2022 and w.quarter = 'q2' and w.deal_parent = 20 and r.title != '47 Samurai'
) q
where w.id = q.id

-- monthly revenue 
update wurl_viewership w 
set w.revenue = q.rev_share
from (
    select w.id as id, w.share * r.amount as rev_share from wurl_viewership w 
    join monthly_revenue r on (r.deal_parent = w.deal_parent and r.year_month_day = w.year_month_day)
    where w.deal_parent = 20 and w.territory_id = 1 and w.channel_id = 8 and w.year = 2022 and w.quarter = 'q2'
) q
where w.id = q.id


-- monthly revenue plex
update wurl_viewership w 
set w.revenue = q.rev_share
from (
    select w.id as id, w.share * r.amount as rev_share from wurl_viewership w 
    join monthly_revenue r on (r.deal_parent = w.deal_parent and r.year_month_day = w.year_month_day)
    where w.deal_parent = 21 and w.channel_id != 13 and w.year = 2022 and w.quarter = 'q2'
) q
where w.id = q.id

select * from dictionary.public.deals

-- check revenue
select sum(revenue), year_month_day from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 20
group by year_month_day

-- revenue
select * from revenue where year = 2022 and quarter = 'q2' and deal_parent = 44

-- monthly_revenue
select * from monthly_revenue where year = 2022 and quarter = 'q2' and deal_parent = 21


-- WURL CHECKS
select share, revenue from wurl_viewership where year = 2022 and quarter = 'q2'  and deal_parent = 44

-- WURL CHECKS
select * from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 44

select * from dictionary.public.deals where partner = 'Samsung TV+'
select * from dictionary.public.territories


select sum(tot_hov), year_month_day, channel from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 20 
group by channel, year_month_day

select * from wurl_viewership where year = 2022 and quarter = 'q2' and deal_parent = 44

-- AMAGI RLAXX INVOICES - revenue update
-- update revenue from euro for rlaxx invoices
update amagi_viewership 
set revenue = (revenue_euro * .96) * 0.54
where revenue is null  and year = 2022 and quarter = 'q2' and deal_parent = 22

-- amagi rlaxx
select * from amagi_viewership where year = 2022 and quarter = 'q2' and deal_parent = 22 and ref_id = 'JS-1794'

-- Amagi query
select * from amagi_viewership where year = 2022 and quarter = 'q2' and deal_parent = 22

--  series id update
update amagi_viewership a 
set a.series_id = q.series_id
from (
  select a.id as id, a.platform_content_id, a.formatted_title, a.ref_id, a.series, s.term, a.content_provider, s.series_id as series_id
  from amagi_viewership a 
  join dictionary.public.series s on (s.entry = a.series)
  where year = 2022 and quarter = 'q2'
)q
where q.id = a.id

   -- Rlaxx (https://drive.google.com/drive/u/0/folders/15GY3xPEA0aCfnQLWlx8jdv9sKLZsXYeX)
        insert into quarterly_revenue(amount, deal_parent, year, quarter, channel, channel_id, department, territory, territory_id)
        select sum(revenue), deal_parent, year, quarter, channel, channel_id, partner, territory, territory_id from amagi_viewership 
        where deal_parent = 22 and quarter = 'q2' and year = 2022 
        group by deal_parent, year, quarter, channel, channel_id, partner, territory, territory_id

-- quarterly revenue
select * from quarterly_revenue where year = 2022 and quarter = 'q2' and deal_parent = 22

   -- rlaxx (uses quarterly revenue to calculate share)
update amagi_viewership a 
set a.share = q.share
from (
      select a.id, a.deal_parent, a.channel_id, (a.revenue/qr.amount) as share from amagi_viewership a
      join quarterly_revenue qr on (a.deal_parent = qr.deal_parent and qr.quarter = a.quarter and qr.year = a.year and qr.channel_id = a.channel_id)
      where a.quarter = 'q2' and a.year = 2022 and a.deal_parent = 22
) q
where a.id = q.id


-- Amagi
    -- amagi monthly_viewership (rlaxx-22 and freebie-27 don't have viewership data,)
    select channel_id, year_month_day, sum(tot_hov), territory_id, year, quarter, deal_parent from amagi_viewership 
    where year = 2022 and quarter = 'q1'and deal_parent not in (22,27) 
    group by year_month_day, deal_parent, channel_id,territory_id, year,quarter
    
    -- insert
    insert into monthly_viewership (channel, channel_id, year_month_day, month, tot_hov, territory, territory_id, year, quarter, deal_parent, platform, partner)
    select channel, channel_id, year_month_day, month,  sum(tot_hov), territory, territory_id, year, quarter, deal_parent, 'amagi', partner from amagi_viewership 
    where year = 2022 and quarter = 'q2'and deal_parent not in (22,27) 
    group by channel, channel_id, year_month_day, month, year, quarter, partner, deal_parent, territory_id, territory, partner

    
    -- monthly_viewership
    select * from monthly_viewership where year = 2022 and quarter = 'q2' and platform = 'amagi' and deal_parent = 30

    
    
    UPDATE amagi_viewership av
    SET av.share = q.v_share 
    FROM (
      select a.id as id, a.tot_hov, (a.tot_hov / mv.tot_hov) as v_share, a.deal_parent, a.month from amagi_viewership a
      join monthly_viewership mv on (mv.year_month_day = a.year_month_day and a.channel_id = mv.channel_id and a.deal_parent = mv.deal_parent and a.territory_id = mv.territory_id)
      where  a.year = 2022 and a.quarter = 'q2' and a.deal_parent not in (22, 27)
    ) q
    WHERE av.id = q.id
    
      -- Amagi viewership share check (should all equal 1)
    select sum(share), deal_parent, year_month_day, channel_id, territory_id 
    from amagi_viewership  where quarter = 'q2' and year = 2022 
    group by year_month_day, channel_id, deal_parent, territory_id
    
    select platform_channel_name, territory, channel 
    from amagi_viewership where year = 2022 and quarter = 'q2' and partner = 'LG'
    group by platform_channel_name, channel, territory
    
    
    
    update amagi_viewership 
    set territory = 'United Kingdom', territory_id = 5
    where year = 2022 and quarter = 'q2' and partner = 'LG' and platform_channel_name = 'Nosey LG GB'
    
    NoseyINTL1_LG_CA 4
    Nosey LG GB 5
    
    select * from amagi_viewership
    
    
       -- Monthly Viewership Insert for Xumo Linear
       insert into monthly_viewership (year_month_day, month, tot_hov, year, quarter, partner, deal_parent, territory_id, territory, platform)
       select year_month_day, month, sum(tot_hov), year, quarter, partner, deal_parent, territory_id, territory, 'wurl' from wurl_viewership 
       where quarter = 'q2' and year = 2022 and deal_parent = 44
       group by  year_month_day, month, year, quarter, partner, deal_parent, territory_id, territory
        
        
   -- WURL CPS insert for Xumo Linear
    -- insert by month, channel, territory 
    insert into content_provider_share(share, year_month_day, channel, channel_id, content_provider, deal_parent, partner, territory, territory_id, year, quarter)
    select sum(share), year_month_day, channel, channel_id, content_provider, deal_parent, partner, territory, territory_id, year, quarter from wurl_viewership 
    where  year = 2022 and quarter = 'q2' and deal_parent = 44
    group by year_month_day, channel, channel_id, content_provider, partner, deal_parent, territory, territory_id, year, quarter
