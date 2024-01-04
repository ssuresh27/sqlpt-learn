/* Nested loop join example */
SELECT * FROM employees e JOIN departments d
ON d.department_id = e.department_id
WHERE d.department_id = 60;
 
/* Even if we change the join order and on clause order, the plan did not change */
SELECT * FROM departments d JOIN employees e 
ON e.department_id = d.department_id
WHERE d.department_id = 60;
 
/* We can use leading hint to change the driving table */
SELECT /*+ leading(e) */ * FROM employees e JOIN departments d
ON d.department_id = e.department_id
WHERE d.department_id = 60;
 
/* Does not use nested loop without hint */
SELECT * FROM employees e JOIN departments d
ON d.department_id = e.department_id;
 
/* Using nested loop hint */
SELECT /*+ use_nl(d e) */ * FROM employees e JOIN departments d
ON d.department_id = e.department_id;
 
/* Nested loop prefetching and double nested loops example */
SELECT e.employee_id,e.last_name,d.department_id,d.department_name 
FROM employees e JOIN departments d
ON d.department_id = e.department_id
WHERE d.department_name LIKE 'A%';