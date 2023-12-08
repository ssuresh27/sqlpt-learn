select /*+ HINT NAME */ from emp;
/* A query without a hint. It performs a range scan*/
SELECT employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'A%';
/* Using a hint to command the optimizer to use FULL TABLE SCAN*/  
SELECT /*+ FULL(e) */ employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'A%';
/* Using the hint with the table name as the parameter*/
SELECT /*+ FULL(employees) */ employee_id, last_name
  FROM employees 
  WHERE last_name LIKE 'A%';
/* Using the hint with the table name while we aliased it*/  
SELECT /*+ FULL(employees) */ employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'A%';
/* Using an unreasonable hint. The optimizer will not consider this hint */
SELECT /*+ INDEX(EMP_DEPARTMENT_IX) */ employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'A%';
/* Using multiple hints. But they aim for the same area. So unreasonable. 
   Optimizer picked full table scan as the best choice */
SELECT /*+ INDEX(EMP_NAME_IX) FULL(e)  */ employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'A%';
/* When we change the order of the hints. But it did not change the Optimizer's decision*/
SELECT /*+ FULL(e) INDEX(EMP_NAME_IX)   */ employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'A%';
/* There is no hint. To see the execution plan to compare with the next one */  
SELECT  
  e.department_id, d.department_name, 
  MAX(salary), AVG(salary)
FROM employees e, departments d
WHERE e.department_id=e.department_id
GROUP BY e.department_id, d.department_name;
/* Using multiple hints to change the execution plan */
SELECT /*+ LEADING(e d)  INDEX(d DEPT_ID_PK) INDEX(e EMP_DEPARTMENT_IX)*/ 
  e.department_id, d.department_name, 
  MAX(salary), AVG(salary)
FROM employees e, departments d
WHERE e.department_id=e.department_id
GROUP BY e.department_id, d.department_name;
/* Using hints when there are two access paths.*/  
SELECT /*+ INDEX(EMP_DEPARTMENT_IX) */ employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'A%'
  and department_id > 120;
/* When we change the selectivity of last_name search, it did not consider our hint.*/
SELECT /*+ INDEX(EMP_DEPARTMENT_IX) */ employee_id, last_name
  FROM employees e 
  WHERE last_name LIKE 'Al%'
  and department_id > 120;
/* Another example with multiple joins, groups etc. But with no hint*/
SELECT customers.cust_first_name, customers.cust_last_name, 
  MAX(QUANTITY_SOLD), AVG(QUANTITY_SOLD)
FROM sales, customers
WHERE sales.cust_id=customers.cust_id
GROUP BY customers.cust_first_name, customers.cust_last_name;
/* Performance increase when performing parallel execution hint*/
SELECT /*+ PARALLEL(4) */ customers.cust_first_name, customers.cust_last_name, 
  MAX(QUANTITY_SOLD), AVG(QUANTITY_SOLD)
FROM sales, customers
WHERE sales.cust_id=customers.cust_id
GROUP BY customers.cust_first_name, customers.cust_last_name;