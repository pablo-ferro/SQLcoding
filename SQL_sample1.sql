--Question: Find the third highest mountain name in each country and sort the countries by ASC order.


SELECT name, height, country
(SELECT
Name,
Height,
Country,
RANK() OVER( partition by country order by height DESC) as rn
) m
WHERE rn=3
ORDER BY country ASC