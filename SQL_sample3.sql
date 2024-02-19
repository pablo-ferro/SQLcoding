-- Question: Find the Top 3 highest salaries by department


With cute as (
SELECT
CONCAT(e.first_name, ’ ‘, e.last_name) as emp_name,
d.name as department,
e.salary
ROW_NUMBER() OVER(PARTITION BY d.name ORDER BY e.salary DESC) as rank

FROM
employees as e
INNER JOIN departments as d
ON e.d_id = d.dept_id


) 

SELECT * FROM cute
WHERE rn<4
ORDER BY department ASC, salary DESC
