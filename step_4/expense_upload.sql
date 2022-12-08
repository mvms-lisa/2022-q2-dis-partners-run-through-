-- Expenses Query Q1
select * from expenses where year = 2022 and quarter = 'q1'

-- Expenses Query Q2
select * from expenses where year = 2022 and quarter = 'q2' and type = 'Wurl' and description like '%Active Connector%'


-- Expenses Update
update expenses
set title = 'CLOUDPORT: Platform Delivery Fee'
where year = 2022 and quarter = 'q2' and description = 'Amagi CLOUDPORT:' and title is null


-- AMAGI EXPENSES COPY INTO
copy into expenses(
    description,
    quantity,
    rate,
    amount,
    year_month_day,
    year,
    quarter,
    territory_id
    )
from (select t.$2, 
      to_number(REPLACE(REPLACE(t.$3, ','), '$'), 15, 4),  
      to_number(REPLACE(REPLACE(t.$5, ','), '$'), 10, 5),  
      to_number(REPLACE(REPLACE(t.$6, ','), '$'), 10, 2),  
       t.$10, 
       t.$11,
       t.$12,
from @DISTRIBUTION_PARTNERS_EXPENSES t) pattern='.*amagi_invoices_q4_21.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE;

-- AMAGI expeses copy (NEW)
copy into expenses(
    year_month_day,
    description,
    channel,
    channel_id,
    department,
    deal_parent,
    quantity,
    rate,
    amount,
    invoice_number,
    territory,
    territory_id,
    type,
    year,
    quarter,
    filename
    )
from (select t.$1,
      t.$2,
      t.$3,
      t.$4,
      t.$5,
      t.$6,
      to_number(REPLACE(REPLACE(t.$7, ','), '$'), 15, 4),  
      to_number(REPLACE(REPLACE(t.$8, ','), '$'), 10, 5),  
      to_number(REPLACE(REPLACE(t.$9, ','), '$'), 10, 2), 
      t.$10,
      t.$11,
      t.$12,
      'Amagi', 2022, 'q2', 'amagi_expenses_q2_2022.csv'
from @DISTRIBUTION_PARTNERS_EXPENSES t) pattern='.*amagi_expenses_q2_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE;

-- Wurl copy (original)
copy into expenses(
    title,
    rate,
    amount,
    month,
    quantity,
    year_month_day,
    deal_parent,
    channel_id,
    territory_id,
    description,
    type,
    department
    )
from (select t.$1, 
      to_number(REPLACE(REPLACE(t.$2, ','), '$'), 10, 5),  
      to_number(REPLACE(REPLACE(t.$3, ','), '$'), 10, 2),  
       t.$4, 
      to_number(REPLACE(REPLACE(t.$5, ','), '$'), 15, 4),  
       t.$6,
       t.$7,
       t.$8,
       t.$9,
       t.$10,
       t.$11,
       t.$12,
from @DISTRIBUTION_PARTNERS_EXPENSES t) pattern='.*wurl_invoices_q4_21.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE;

-- WURL Copy into (NEW)
copy into expenses(
    year_month_day,
    description,
    quantity,
    rate,
    amount,
    title,
    deal_parent,
    department,
    channel,
    channel_id,
    territory,
    territory_id,
    type,
    year,
    quarter,
    filename
    )
from (select t.$1,
      t.$2,
      to_number(REPLACE(REPLACE(t.$3, ','), '$'), 15, 4),  
      to_number(REPLACE(REPLACE(t.$4, ','), '$'), 10, 5),  
      to_number(REPLACE(REPLACE(t.$5, ','), '$'), 20, 5),  
       t.$6,
       t.$7,
       t.$8,
       t.$9,
       t.$10,
       t.$11,
       t.$12,
      'Wurl', 2022, 'q2', 'wurl_expenses_q2_2022.csv'
from @DISTRIBUTION_PARTNERS_EXPENSES t) pattern='.*wurl_expenses_q2_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE;

-- Revenue 
select * from revenue where year = 2022 and quarter = 'q2' and department like '%Fetch%'

update revenue
set department = 'FetchTV', type = 'FetchTV Revenue', territory_id = 10, territory = 'Australia'
where year = 2022 and quarter = 'q2' and department like '%Fetch%'`

