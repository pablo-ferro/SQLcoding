-- Question: We have a database with information about web pages visited by users. Code SQL: return the 3 users who have accessed the page continuously, and arrange the 3 users in descending order of length.

-- Step 1: let's add a new column whose value is each user's next visit (different from the current date). We'll use the lead function to do this:

SELECT DISTINCT 
user_id, 
date,
lead(date) over ( partition by user_id order by date) as next_date
FROM (select distinct * from visits) as t


-- Step 2: let's create another column whose purpose is to let us know when the visit stopped. This includes checking if the next date is different from the current date +1.

With 
next_dates
As
(
Select distinct 
user_id,
Date,
lead(date) over(partition by user_id order by date) as next_date
From
(Select distinct * from visits) as t)


SELECT
user_id,
Date,
Next_Date,
Case when next_date is null or next_date = date+1 then 1 else null end as streak
FROM next_date



-- Step 3: we will create a partition for each user, and each partition represents a continuous access. Conceptually what we're going to do is, for each user, take the most recent record (based on date) and assign a value of 0, then look for the record below, and assign a value of 0 if access has not stopped, and a value of 1 (if the streak column is empty), then continue doing this until each consecutive access is represented by a different partition. The code to implement this logic is as follows.

With 
next_dates
As
(
Select distinct 
user_id,
Date,
lead(date) over(partition by user_id order by date) as next_date
From
(Select distinct * from visits) as t),

Streaks as(
SELECT
user_id,
Date,
Next_Date,
Case when next_date is null or next_date = date+1 then 1 else null end as streak
FROM next_dates)

SELECT *,
sum(case when streak is null then 1 else 0 end) over( partition by user_id order by date) as partition from streaks



-- Step 4: Once we have this partition, the problem is easy, now we just need to count the number of records for each user and partition and find the user with the highest count. The complete query is as follows

With 
next_dates
As
(
Select distinct 
user_id,
Date,
lead(date) over(partition by user_id order by date) as next_date
From
(Select distinct * from visits) as t),

Streaks as(
SELECT
user_id,
Date,
Next_Date,
Case when next_date is null or next_date = date+1 then 1 else null end as streak
FROM next_dates),

Partitions as(
SELECT *,
sum(case when streak is null then 1 else 0 end) over( partition by user_id order by date) as partition from streaks),

count_partitions as(
Select 
user_id, 
partition, 
count(1) as streak_days
From partitions
Group by user_id, partition)

SELECT
user_id,
max(streak_days) as longest_streak
From count_partitions
Group by user_id
Order by 2 desc limit 3
