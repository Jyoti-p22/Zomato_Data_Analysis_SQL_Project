
# project... zomato data analysis

create database zomato;
use zomato;
select * from zomatodata1;
select * from zomatodata2;

-- 1) datekey_opening ....repalce _ by / and convert data type

UPDATE zomatodata1 SET Datekey_Opening = REPLACE(Datekey_Opening, '_', '/') 
WHERE Datekey_Opening LIKE '%_%';

SELECT Datekey_Opening FROM zomatodata1;

alter table zomatodata1 modify column Datekey_Opening date;

DESC zomatodata1;

-- 2) check unique  value from categorical columns

select distinct countrycode from zomatodata1;
# data is available for 8 countries
select * from zomatodata1;

-- 3) Rename column country name

# by uning alter table
alter table zomatodata2 
change column 'country name' countryname text null default null ;

-- 4) 8 countries name

select countryname from zomatodata2 where 
countryID in (select distinct countrycode from zomatodata1);

# we have data for india canada uk usa brazil new zealand united arab em 
# singapore

-- 5) how many resturants are registered on zomato

select count(restaurantname) from zomatodata1;

# total 824 restaurant are registered on zomato

-- 6) count of restaurant from each country

select count(z1.restaurantid)*100/824,z2.countryname
from zomatodata1 z1
inner join zomatodata2 z2
on z1.countrycode=z2.countryid
group by z2.countryname;

# conclusion - most of restaurants 93% are from india country

-- 7) percentage of retaurants based on 'has online-delivery

-- # percentage
select has_online_delivery,
concat(round(count(has_online_delivery)*100/824,2),"%") as 'count' from zomatodata1
group by has_online_delivery;

# conclusion - just 6.67% of restaurant in our data has online delivery

-- 8) percentage of restaurants based on has_table_booking

select has_table_booking,
concat(round(count(has_table_booking)*100/824,2),"%") as 'count' from zomatodata1
group by has_table_booking;

# conclusion - just 3% of restaurant in our data has table booking system

-- 9) highest rating restaurants in each country

select * from zomatodata1; 

select max(z1.rating),z2.countryname 
from zomatodata1 z1
inner join zomatodata2 z2
on z1.countrycode=z2.countryid
group by z2.countryname ;

-- 10) top 5 restaurants who has more of votes

select restaurantname,votes from zomatodata1
order by votes desc;

-- 11) top restaurant with highest rating and votes from each country

select max(votes) as 'maxvote',z1.restaurantname,z2.countryname
from zomatodata1 z1
inner join zomatodata2 z2
on z1.countrycode = z2.countryid
order by maxvote desc limit 5;


-- 12) find most common cuisines in dataset

select cuisines,count(*) as 'count' from zomatodata1
group by cuisines
order by count desc limit 5;

-- 13) find the city with highest average cost for two people

select z2.countryname,city,max(average_cost_for_two) as 'max'
from zomatodata1 z1
inner join zomatodata2 z2
on z1.countrycode = z2.countryid
where countryname = 'india'
group by city
order by max desc;

-- 14) find restaurant that are currently delivering

select restaurantname,city
from zomatodata1
where is_delivering_now='yes';

-- 15) Highest rated restaurant in each country

SELECT z2.countryname, z1.RestaurantName AS HighestRatedRestaurant
FROM zomatodata1 z1
INNER JOIN zomatodata2 z2
ON z1.CountryCode = z2.countryID
WHERE (z2.countryname, z1.rating) IN (
    SELECT z2.countryname, MAX(z1.rating) AS MaxRating
    FROM zomatodata1 z1
    INNER JOIN zomatodata2 z2
    ON z1.CountryCode = z2.countryID
    GROUP BY z2.countryname
);

SELECT z2.countryname, z1.RestaurantName AS HighestRatedRestaurant
FROM zomatodata1 z1
INNER JOIN zomatodata2 z2
ON z1.CountryCode = z2.countryID
WHERE (z2.countryname, z1.rating) IN (
    SELECT z2.countryname, MAX(z1.rating) AS MaxRating
    FROM zomatodata1 z1
    INNER JOIN zomatodata2 z2
    ON z1.CountryCode = z2.countryID
    GROUP BY z2.countryname
)GROUP BY z2.countryname, z1.RestaurantName;

-- 16) top restaurants with highest rating and votes from each country

WITH RankedRestaurants AS (
    SELECT
        z2.countryname,
        z1.RestaurantName,
        z1.Rating,
        z1.Votes,
        ROW_NUMBER() OVER (PARTITION BY z2.countryname 
        ORDER BY z1.Rating DESC, z1.Votes DESC) AS Rank1
    FROM zomatodata1 z1
    INNER JOIN zomatodata2 z2 ON z1.CountryCode = z2.countryID
)
SELECT countryname, RestaurantName, Rating, Votes
FROM RankedRestaurants
WHERE Rank1 = 1;

-- 17) How many restaurants opened in each year?

SELECT
    EXTRACT(YEAR FROM Datekey_Opening) AS OpeningYear,
    COUNT(*) AS RestaurantCount
FROM zomatodata1
GROUP BY OpeningYear
ORDER BY OpeningYear;

-- 18) Number of restaurants opening based on Quarter

SELECT
    EXTRACT(YEAR FROM Datekey_Opening) AS OpeningYear,
    EXTRACT(QUARTER FROM Datekey_Opening) AS OpeningQuarter,
    COUNT(*) AS RestaurantCount
FROM zomatodata1
GROUP BY OpeningYear, OpeningQuarter
ORDER BY OpeningYear, OpeningQuarter;

-- 19) Number of restaurants opening based on Month

SELECT
    EXTRACT(YEAR FROM Datekey_Opening) AS OpeningYear,
    EXTRACT(MONTH FROM Datekey_Opening) AS OpeningMonth,
    COUNT(*) AS RestaurantCount
FROM zomatodata1
GROUP BY OpeningYear, OpeningMonth
ORDER BY OpeningYear, OpeningMonth;

-- 20) Find the top-rated restaurants in each city.

WITH RankedRestaurants AS ( SELECT RestaurantName, City, Rating, 
ROW_NUMBER() OVER (PARTITION BY City ORDER BY Rating DESC) AS 'Rank1'
FROM zomatodata1 ) 
SELECT RestaurantName, City, Rating FROM RankedRestaurants 
WHERE Rank1 = 1;

-- 21) Find the countries where the majority of restaurants 

#offer online delivery and table booking.

SELECT C.CountryName, COUNT(*) AS TotalRestaurants 
FROM zomatodata1 R 
INNER JOIN zomatodata2 C 
ON R.CountryCode = C.CountryID 
WHERE R.Has_Online_delivery = 'Yes' AND R.Has_Table_booking = 'Yes' 
GROUP BY C.CountryName 
HAVING COUNT(*) > 7;

