REM =======================
REM Oracle Database Indexes
REM =======================

-- 1. B-Tree Index Default  - SELECTIVE COLUMN
--      A. Normal default
--      B. Function-based
--      C. IOT 
-- 2. Bitmap                - NON-SELECTIVE COLUMN


REM TABLE ACCESS PATH

-- 1. Table access full FULL TABLE SCAN
-- 2. Tables access by ROWID - Uses address to get the data
-- 3. Sample Table SCAN  - Random ROWS

REM INDEX ACCESS PATH

-- 1. Index Unique Scan - UNIQUE INDEX SCAN, based on primay or unique key - returns one row
-- 2. Index Range SCAN - Returns more than one row
-- 3. Index Full SCAN - Group or order by
-- 4. Index FAST Full SCAN - Data available in Index Column
-- 5. Index SKIP SCAN - Skip the index key 
-- 6. Index Join SCAN - Join related index and returns data
-- 7. IOT 
-- 8. Bitmap Access Path


REM TABLE ACCESS FULL / FULL TABLE SCAN

-- Reads full table
-- If there is no suitable index
-- If selectivity is low
-- if the tables is versy small 
-- If full table scan hint is used


--- No selectivity or where clause
REM FULL Table ACCESS

w1goaodbdevg02@(ORCL-PRIMARY) > select * from sales;

Execution Plan
----------------------------------------------------------
Plan hash value: 1550251865

---------------------------------------------------------------------------------------------
| Id  | Operation           | Name  | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |       |   918K|    25M|   517   (2)| 00:00:01 |       |       |
|   1 |  PARTITION RANGE ALL|       |   918K|    25M|   517   (2)| 00:00:01 |     1 |    28 |
|   2 |   TABLE ACCESS FULL | SALES |   918K|    25M|   517   (2)| 00:00:01 |     1 |    28 |
---------------------------------------------------------------------------------------------

REM High selectivity
-- Hight selectivty but column don't have index

w1goaodbdevg02@(ORCL-PRIMARY) >  select * from sales where amount_sold > 1770;

Execution Plan
----------------------------------------------------------
Plan hash value: 1550251865

---------------------------------------------------------------------------------------------
| Id  | Operation           | Name  | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |       |   331 |  9599 |   518   (2)| 00:00:01 |       |       |
|   1 |  PARTITION RANGE ALL|       |   331 |  9599 |   518   (2)| 00:00:01 |     1 |    28 |
|*  2 |   TABLE ACCESS FULL | SALES |   331 |  9599 |   518   (2)| 00:00:01 |     1 |    28 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("AMOUNT_SOLD">1770)

w1goaodbdevg02@(ORCL-PRIMARY) >

REM Low selectivity

-- Low selectivity and employee_id has index, 
-- but table is small and optimizer choose full table scan over index range scan

NOT CONNECTED >  select * from employees where employee_id > 100;

Execution Plan
----------------------------------------------------------
Plan hash value: 1445457117

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |   106 |  7314 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |   106 |  7314 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("EMPLOYEE_ID">100)

NOT CONNECTED >


REM FULL table access 
-- where class don't have indexes

NOT CONNECTED >  select * from employees e, departments d
  2  where e.employee_id=d.manager_id;

Execution Plan
----------------------------------------------------------
Plan hash value: 2052257371

----------------------------------------------------------------------------------
| Id  | Operation          | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |             |    11 |   990 |     6   (0)| 00:00:01 |
|*  1 |  HASH JOIN         |             |    11 |   990 |     6   (0)| 00:00:01 |
|*  2 |   TABLE ACCESS FULL| DEPARTMENTS |    11 |   231 |     3   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| EMPLOYEES   |   107 |  7383 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("E"."EMPLOYEE_ID"="D"."MANAGER_ID")
   2 - filter("D"."MANAGER_ID" IS NOT NULL)

Note
-----
   - this is an adaptive plan

REM INDEX and FULL TABLE ACCESS

NOT CONNECTED > select * from employees e, departments d
  2  where e.department_id=d.department_id;

Execution Plan
----------------------------------------------------------
Plan hash value: 919050303

--------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |   106 |  9540 |     3   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                |             |   106 |  9540 |     3   (0)| 00:00:01 |
|   2 |   NESTED LOOPS               |             |   107 |  9540 |     3   (0)| 00:00:01 |
|   3 |    TABLE ACCESS FULL         | EMPLOYEES   |   107 |  7383 |     3   (0)| 00:00:01 |
|*  4 |    INDEX UNIQUE SCAN         | DEPT_ID_PK  |     1 |       |     0   (0)| 00:00:01 |
|   5 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |     1 |    21 |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")

NOT CONNECTED >


REM Access by INDEX ROW ID
---


w1goaodbdevg02@(ORCL-PRIMARY) > 1
  1* select * from sales where prod_id=116 and cust_id=100090
w1goaodbdevg02@(ORCL-PRIMARY) >
w1goaodbdevg02@(ORCL-PRIMARY) > /


Execution Plan
----------------------------------------------------------
Plan hash value: 698553563

-----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                           |                |     2 |    58 |    59   (2)| 00:00:01 |       |       |
|   1 |  PARTITION RANGE ALL                       |                |     2 |    58 |    59   (2)| 00:00:01 |     1 |    28 |
|   2 |   TABLE ACCESS BY LOCAL INDEX ROWID BATCHED| SALES          |     2 |    58 |    59   (2)| 00:00:01 |     1 |    28 |
|   3 |    BITMAP CONVERSION TO ROWIDS             |                |       |       |            |          |       |       |
|   4 |     BITMAP AND                             |                |       |       |            |          |       |       |
|*  5 |      BITMAP INDEX SINGLE VALUE             | SALES_CUST_BIX |       |       |            |          |     1 |    28 |
|*  6 |      BITMAP INDEX SINGLE VALUE             | SALES_PROD_BIX |       |       |            |          |     1 |    28 |
-----------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("CUST_ID"=100090)
   6 - access("PROD_ID"=116)


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         35  consistent gets
          0  physical reads
          0  redo size
        996  bytes sent via SQL*Net to client
        552  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

w1goaodbdevg02@(ORCL-PRIMARY) >


REM explict by ROW ID 
REM ----------------

w1goaodbdevg02@(ORCL-PRIMARY) > select * from sales where rowid='AAAWeZAAKAAABjcAAA';


Execution Plan
----------------------------------------------------------
Plan hash value: 85008936

----------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name  | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |       |     1 |    29 |     1   (0)| 00:00:01 |       |       |
|   1 |  TABLE ACCESS BY USER ROWID| SALES |     1 |    29 |     1   (0)| 00:00:01 | ROWID | ROWID |
----------------------------------------------------------------------------------------------------


Statistics
----------------------------------------------------------
          2  recursive calls
          0  db block gets
          3  consistent gets
          0  physical reads
          0  redo size
        996  bytes sent via SQL*Net to client
        552  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed



REM  INDEX UNIQUE SCAN
REM ---------------------
-- Query has equality operator 
-- Query All columes has primary or unique column

NOT CONNECTED >  select * from employees where employee_id=103;

Execution Plan
----------------------------------------------------------
Plan hash value: 1833546154

---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    69 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES     |     1 |    69 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | EMP_EMP_ID_PK |     1 |       |     0   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID"=103)

NOT CONNECTED >



REM INDEX RANGE SCAN
-- One side bounded searched
SELECT * FROM SALES WHERE time_id > to_date('01-NOV-01','DD-MON-RR');

Execution Plan
----------------------------------------------------------
Plan hash value: 4094420152

-----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                           |                | 37761 |  1069K|   490   (1)| 00:00:01 |       |       |
|   1 |  PARTITION RANGE ITERATOR                  |                | 37761 |  1069K|   490   (1)| 00:00:01 |   KEY |    28 |
|   2 |   TABLE ACCESS BY LOCAL INDEX ROWID BATCHED| SALES          | 37761 |  1069K|   490   (1)| 00:00:01 |   KEY |    28 |
|   3 |    BITMAP CONVERSION TO ROWIDS             |                |       |       |            |          |       |       |
|*  4 |     BITMAP INDEX RANGE SCAN                | SALES_TIME_BIX |       |       |            |          |   KEY |    28 |
-----------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("TIME_ID">TO_DATE('01-NOV-01','DD-MON-RR'))
       filter("TIME_ID">TO_DATE('01-NOV-01','DD-MON-RR'))

w1goaodbdevg02@(ORCL-PRIMARY) >
-- Bounded by both sides
SELECT * FROM SALES WHERE time_id between to_date('01-NOV-00','DD-MON-RR') and to_date('05-NOV-00','DD-MON-RR'); 
w1goaodbdevg02@(ORCL-PRIMARY) > SELECT * FROM SALES WHERE time_id between to_date('01-NOV-00','DD-MON-RR') and to_date('05-NOV-00','DD-MON-RR');

Execution Plan
----------------------------------------------------------
Plan hash value: 3553812405

------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                   | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                            |                |  2572 | 77160 |    32   (0)| 00:00:01 |       |       |
|*  1 |  FILTER                                     |                |       |       |            |          |       |       |
|   2 |   PARTITION RANGE ITERATOR                  |                |  2572 | 77160 |    32   (0)| 00:00:01 |   KEY |   KEY |
|   3 |    TABLE ACCESS BY LOCAL INDEX ROWID BATCHED| SALES          |  2572 | 77160 |    32   (0)| 00:00:01 |   KEY |   KEY |
|   4 |     BITMAP CONVERSION TO ROWIDS             |                |       |       |            |          |       |       |
|*  5 |      BITMAP INDEX RANGE SCAN                | SALES_TIME_BIX |       |       |            |          |   KEY |   KEY |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(TO_DATE('05-NOV-00','DD-MON-RR')>=TO_DATE('01-NOV-00','DD-MON-RR'))
   5 - access("TIME_ID">=TO_DATE('01-NOV-00','DD-MON-RR') AND "TIME_ID"<=TO_DATE('05-NOV-00','DD-MON-RR'))

w1goaodbdevg02@(ORCL-PRIMARY) >
-- B-Tree index range scan
SELECT * FROM employees where employee_id > 190;
NOT CONNECTED > SELECT * FROM employees where employee_id > 190;

Execution Plan
----------------------------------------------------------
Plan hash value: 1781021061

-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |    16 |  1104 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEES     |    16 |  1104 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | EMP_EMP_ID_PK |    16 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID">190)


-- Index range scan on Non-Unique Index
SELECT * FROM employees where department_id > 80;

NOT CONNECTED > SELECT * FROM employees where department_id > 80;

Execution Plan
----------------------------------------------------------
Plan hash value: 235881476

---------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                   |    11 |   759 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEES         |    11 |   759 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | EMP_DEPARTMENT_IX |    11 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("DEPARTMENT_ID">80)


NOT CONNECTED > 
-- Order by with the indexed column -  sort is processed
SELECT * FROM employees where employee_id > 190 order by email;

NOT CONNECTED > SELECT * FROM employees where employee_id > 190 order by email;

Execution Plan
----------------------------------------------------------
Plan hash value: 4168245217

------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |               |    16 |  1104 |     3  (34)| 00:00:01 |
|   1 |  SORT ORDER BY                       |               |    16 |  1104 |     3  (34)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEES     |    16 |  1104 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN                  | EMP_EMP_ID_PK |    16 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("EMPLOYEE_ID">190)

-- Order by with the indexed column - no sort is processed
SELECT * FROM employees where employee_id > 190 order by employee_id;


NOT CONNECTED > SELECT * FROM employees where employee_id > 190 order by employee_id;

Execution Plan
----------------------------------------------------------
Plan hash value: 603312277

---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |    16 |  1104 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES     |    16 |  1104 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | EMP_EMP_ID_PK |    16 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID">190)


-- Index range scan descending
SELECT * FROM employees where department_id > 80 order by department_id desc;
NOT CONNECTED > SELECT * FROM employees where department_id > 80 order by department_id desc;

Execution Plan
----------------------------------------------------------
Plan hash value: 2241259804

--------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                   |    11 |   759 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID | EMPLOYEES         |    11 |   759 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN DESCENDING| EMP_DEPARTMENT_IX |    11 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("DEPARTMENT_ID">80)
-- Index range scan with wildcard
SELECT * FROM PRODUCTS WHERE PROD_SUBCATEGORY LIKE 'Accessories%';
SELECT * FROM PRODUCTS WHERE PROD_SUBCATEGORY LIKE '%Accessories';
SELECT * FROM PRODUCTS WHERE PROD_SUBCATEGORY LIKE '%Accessories%';

w1goaodbdevg02@(ORCL-PRIMARY) > SELECT * FROM PRODUCTS WHERE PROD_SUBCATEGORY LIKE 'Accessories%';

Execution Plan
----------------------------------------------------------
Plan hash value: 1826917512

---------------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name                    | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                         |     3 |   519 |     0   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PRODUCTS                |     3 |   519 |     0   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | PRODUCTS_PROD_SUBCAT_IX |     3 |       |     0   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("PROD_SUBCATEGORY" LIKE 'Accessories%')
       filter("PROD_SUBCATEGORY" LIKE 'Accessories%')

w1goaodbdevg02@(ORCL-PRIMARY) > SELECT * FROM PRODUCTS WHERE PROD_SUBCATEGORY LIKE '%Accessories';

Execution Plan
----------------------------------------------------------
Plan hash value: 1954719464

------------------------------------------------------------------------------
| Id  | Operation         | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |          |     4 |   692 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PRODUCTS |     4 |   692 |     3   (0)| 00:00:01 |
------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("PROD_SUBCATEGORY" LIKE '%Accessories')

w1goaodbdevg02@(ORCL-PRIMARY) > SELECT * FROM PRODUCTS WHERE PROD_SUBCATEGORY LIKE '%Accessories%';

Execution Plan
----------------------------------------------------------
Plan hash value: 1954719464

------------------------------------------------------------------------------
| Id  | Operation         | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |          |     4 |   692 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PRODUCTS |     4 |   692 |     3   (0)| 00:00:01 |
------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("PROD_SUBCATEGORY" LIKE '%Accessories%')

w1goaodbdevg02@(ORCL-PRIMARY) 



REM -----------------------
REM INDEX FULL SCAN
REM ----------------------

/* Index usage with order by */
SELECT * FROM departments ORDER BY department_id;
NOT CONNECTED > SELECT * FROM departments ORDER BY department_id;

Execution Plan
----------------------------------------------------------
Plan hash value: 3145200496

-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |    27 |   567 |     0   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |    27 |   567 |     0   (0)| 00:00:01 |
|   2 |   INDEX FULL SCAN           | DEPT_ID_PK  |    27 |       |     0   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

NOT CONNECTED >

/* Index usage with order by, one column of an index - causes index full scan*/
SELECT last_name,first_name FROM employees ORDER BY last_name;
NOT CONNECTED > SELECT last_name,first_name FROM employees ORDER BY last_name;

Execution Plan
----------------------------------------------------------
Plan hash value: 2228653197

--------------------------------------------------------------------------------
| Id  | Operation        | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |             |   107 |  1605 |     1   (0)| 00:00:01 |
|   1 |  INDEX FULL SCAN | EMP_NAME_IX |   107 |  1605 |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------

NOT CONNECTED >

/* Index usage with order by, one column of an index - causes unnecessary sort operation*/
SELECT last_name,first_name FROM employees ORDER BY first_name;
NOT CONNECTED > SELECT last_name,first_name FROM employees ORDER BY first_name;

Execution Plan
----------------------------------------------------------
Plan hash value: 1502791934

--------------------------------------------------------------------------------
| Id  | Operation        | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |             |   107 |  1605 |     2  (50)| 00:00:01 |
|   1 |  SORT ORDER BY   |             |   107 |  1605 |     2  (50)| 00:00:01 |
|   2 |   INDEX FULL SCAN| EMP_NAME_IX |   107 |  1605 |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------

NOT CONNECTED >

/* Index usage with order by, but with wrong order - causes unnecessary sort operation */
SELECT last_name,first_name FROM employees ORDER BY first_name,last_name;
NOT CONNECTED > SELECT last_name,first_name FROM employees ORDER BY first_name,last_name;

Execution Plan
----------------------------------------------------------
Plan hash value: 1502791934

--------------------------------------------------------------------------------
| Id  | Operation        | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |             |   107 |  1605 |     2  (50)| 00:00:01 |
|   1 |  SORT ORDER BY   |             |   107 |  1605 |     2  (50)| 00:00:01 |
|   2 |   INDEX FULL SCAN| EMP_NAME_IX |   107 |  1605 |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------

NOT CONNECTED >

/* Index usage with order by, with right order of the index - there is no unncessary sort */
SELECT last_name,first_name FROM employees ORDER BY last_name,first_name;
NOT CONNECTED > SELECT last_name,first_name FROM employees ORDER BY last_name,first_name;

Execution Plan
----------------------------------------------------------
Plan hash value: 2228653197

--------------------------------------------------------------------------------
| Id  | Operation        | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |             |   107 |  1605 |     1   (0)| 00:00:01 |
|   1 |  INDEX FULL SCAN | EMP_NAME_IX |   107 |  1605 |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------

NOT CONNECTED >

/* Index usage with order by, wit unindexed column - there is no unncessary sort */
SELECT last_name,first_name FROM employees ORDER BY last_name,salary;
NOT CONNECTED > SELECT last_name,first_name FROM employees ORDER BY last_name,salary;

Execution Plan
----------------------------------------------------------
Plan hash value: 3447538987

--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |   107 |  2033 |     4  (25)| 00:00:01 |
|   1 |  SORT ORDER BY     |           |   107 |  2033 |     4  (25)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| EMPLOYEES |   107 |  2033 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------

NOT CONNECTED >

/* Index usage order by - when use * , it performed full table scan */
SELECT * FROM employees ORDER BY last_name,first_name;
NOT CONNECTED > SELECT * FROM employees ORDER BY last_name,first_name;

Execution Plan
----------------------------------------------------------
Plan hash value: 3447538987

--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |   107 |  7383 |     4  (25)| 00:00:01 |
|   1 |  SORT ORDER BY     |           |   107 |  7383 |     4  (25)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| EMPLOYEES |   107 |  7383 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------

NOT CONNECTED >

/* Index usage with group by - using a column with no index leads a full table scan */
SELECT salary,count(*) FROM employees e 
WHERE salary IS NOT NULL
GROUP BY salary;

NOT CONNECTED > SELECT salary,count(*) FROM employees e
WHERE salary IS NOT NULL
GROUP BY salary;  2    3

Execution Plan
----------------------------------------------------------
Plan hash value: 1192169904

--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |    58 |   232 |     4  (25)| 00:00:01 |
|   1 |  HASH GROUP BY     |           |    58 |   232 |     4  (25)| 00:00:01 |
|*  2 |   TABLE ACCESS FULL| EMPLOYEES |   107 |   428 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("SALARY" IS NOT NULL)

NOT CONNECTED >

/* Index usage with group by - using indexed columns may lead to a index full scan */
SELECT department_id,count(*) FROM employees e 
WHERE department_id IS NOT NULL
GROUP BY department_id;
NOT CONNECTED > SELECT department_id,count(*) FROM employees e
WHERE department_id IS NOT NULL
GROUP BY department_id;  2    3

Execution Plan
----------------------------------------------------------
Plan hash value: 3199213807

------------------------------------------------------------------------------------------
| Id  | Operation            | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |                   |    11 |    33 |     1   (0)| 00:00:01 |
|   1 |  SORT GROUP BY NOSORT|                   |    11 |    33 |     1   (0)| 00:00:01 |
|*  2 |   INDEX FULL SCAN    | EMP_DEPARTMENT_IX |   106 |   318 |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("DEPARTMENT_ID" IS NOT NULL)

NOT CONNECTED >

/* Index usage with group by - using more columns than ONE index has may prevent index full scan */ 
SELECT department_id,manager_id,count(*) FROM employees e 
WHERE department_id IS NOT NULL
GROUP BY department_id, manager_id;

NOT CONNECTED > SELECT department_id,manager_id,count(*) FROM employees e
WHERE department_id IS NOT NULL
GROUP BY department_id, manager_id;  2    3

Execution Plan
----------------------------------------------------------
Plan hash value: 1192169904

--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |   106 |   742 |     4  (25)| 00:00:01 |
|   1 |  HASH GROUP BY     |           |   106 |   742 |     4  (25)| 00:00:01 |
|*  2 |   TABLE ACCESS FULL| EMPLOYEES |   106 |   742 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("DEPARTMENT_ID" IS NOT NULL)

NOT CONNECTED >

/* Index usage with merge join */
SELECT e.employee_id, e.last_name, e.first_name, e.department_id, 
       d.department_name
FROM   employees e, departments d
WHERE  e.department_id = d.department_id;

NOT CONNECTED > SELECT e.employee_id, e.last_name, e.first_name, e.department_id,
       d.department_name
FROM   employees e, departments d
WHERE  e.department_id = d.department_id;  2    3    4

Execution Plan
----------------------------------------------------------
Plan hash value: 919050303

--------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |   106 |  4028 |     3   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                |             |   106 |  4028 |     3   (0)| 00:00:01 |
|   2 |   NESTED LOOPS               |             |   107 |  4028 |     3   (0)| 00:00:01 |
|   3 |    TABLE ACCESS FULL         | EMPLOYEES   |   107 |  2354 |     3   (0)| 00:00:01 |
|*  4 |    INDEX UNIQUE SCAN         | DEPT_ID_PK  |     1 |       |     0   (0)| 00:00:01 |
|   5 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |     1 |    16 |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")

NOT CONNECTED >




REM INDEX FAST FULL SCAN
REM ---------------------

/* Index Fast Full Scan Usage - Adding a different column 
    than index has will prevent the Index Fast Full Scan */
SELECT e.employee_id, d.department_id, e.first_name,
       d.department_name
FROM   employees e, departments d
WHERE  e.department_id = d.department_id;

NOT CONNECTED > SELECT e.employee_id, d.department_id, e.first_name,
       d.department_name
FROM   employees e, departments d
WHERE  e.department_id = d.department_id;  2    3    4

Execution Plan
----------------------------------------------------------
Plan hash value: 919050303

--------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |   106 |  3180 |     3   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                |             |   106 |  3180 |     3   (0)| 00:00:01 |
|   2 |   NESTED LOOPS               |             |   107 |  3180 |     3   (0)| 00:00:01 |
|   3 |    TABLE ACCESS FULL         | EMPLOYEES   |   107 |  1498 |     3   (0)| 00:00:01 |
|*  4 |    INDEX UNIQUE SCAN         | DEPT_ID_PK  |     1 |       |     0   (0)| 00:00:01 |
|   5 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |     1 |    16 |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")


/* If all the columns are in the index, it may perform
   an Index Fast Full Scan */
SELECT e.employee_id, d.department_id,
       d.department_name
FROM   employees e, departments d
WHERE  e.department_id = d.department_id;

NOT CONNECTED > SELECT e.employee_id, d.department_id,
       d.department_name
FROM   employees e, departments d
WHERE  e.department_id = d.department_id;  2    3    4

Execution Plan
----------------------------------------------------------
Plan hash value: 3182260114

--------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                   |   106 |  2438 |     2   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                |                   |   106 |  2438 |     2   (0)| 00:00:01 |
|   2 |   NESTED LOOPS               |                   |   107 |  2438 |     2   (0)| 00:00:01 |
|   3 |    VIEW                      | index$_join$_001  |   107 |   749 |     2   (0)| 00:00:01 |
|*  4 |     HASH JOIN                |                   |       |       |            |          |
|   5 |      INDEX FAST FULL SCAN    | EMP_DEPARTMENT_IX |   107 |   749 |     1   (0)| 00:00:01 |
|   6 |      INDEX FAST FULL SCAN    | EMP_EMP_ID_PK     |   107 |   749 |     1   (0)| 00:00:01 |
|*  7 |    INDEX UNIQUE SCAN         | DEPT_ID_PK        |     1 |       |     0   (0)| 00:00:01 |
|   8 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS       |     1 |    16 |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access(ROWID=ROWID)
   7 - access("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")


/*Index Fast Full Scan can be applied to b-tree indexes, too 
  Even if there is an order by here, it used IFF Scan */
SELECT prod_id from sales order by prod_id;
w1goaodbdevg02@(ORCL-PRIMARY) > SELECT prod_id from sales order by prod_id;

Execution Plan
----------------------------------------------------------
Plan hash value: 1072633995

-------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |   918K|  3589K|       |  2656   (1)| 00:00:01 |       |       |
|   1 |  SORT ORDER BY                 |                |   918K|  3589K|    10M|  2656   (1)| 00:00:01 |       |       |
|   2 |   PARTITION RANGE ALL          |                |   918K|  3589K|       |    29   (0)| 00:00:01 |     1 |    28 |
|   3 |    BITMAP CONVERSION TO ROWIDS |                |   918K|  3589K|       |    29   (0)| 00:00:01 |       |       |
|   4 |     BITMAP INDEX FAST FULL SCAN| SALES_PROD_BIX |       |       |       |            |          |     1 |    28 |
-------------------------------------------------------------------------------------------------------------------------

w1goaodbdevg02@(ORCL-PRIMARY) >
/* Optimizer thinks Index Full Scan is better here*/
SELECT time_id from sales order by time_id;
w1goaodbdevg02@(ORCL-PRIMARY) > SELECT time_id from sales order by time_id;

Execution Plan
----------------------------------------------------------
Plan hash value: 2923538954

---------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                |   918K|  7178K|    58   (0)| 00:00:01 |       |       |
|   1 |  PARTITION RANGE ALL         |                |   918K|  7178K|    58   (0)| 00:00:01 |     1 |    28 |
|   2 |   BITMAP CONVERSION TO ROWIDS|                |   918K|  7178K|    58   (0)| 00:00:01 |       |       |
|   3 |    BITMAP INDEX FULL SCAN    | SALES_TIME_BIX |       |       |            |          |     1 |    28 |
---------------------------------------------------------------------------------------------------------------

w1goaodbdevg02@(ORCL-PRIMARY) > 
/* Optimizer uses inded Fast Full Scan*/
SELECT time_id from sales;
 
 w1goaodbdevg02@(ORCL-PRIMARY) > SELECT time_id from sales;

Execution Plan
----------------------------------------------------------
Plan hash value: 2247529634

----------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                |   918K|  7178K|    51   (0)| 00:00:01 |       |       |
|   1 |  PARTITION RANGE ALL          |                |   918K|  7178K|    51   (0)| 00:00:01 |     1 |    28 |
|   2 |   BITMAP CONVERSION TO ROWIDS |                |   918K|  7178K|    51   (0)| 00:00:01 |       |       |
|   3 |    BITMAP INDEX FAST FULL SCAN| SALES_TIME_BIX |       |       |            |          |     1 |    28 |
----------------------------------------------------------------------------------------------------------------

w1goaodbdevg02@(ORCL-PRIMARY) >

 
REM INDEX SKIP SCAN
REM ---------------
/*Index skip scan usage with equality operator*/
SELECT * FROM employees WHERE first_name = 'Alex';
/* Index range scan occurs if we use the first column of the index */
SELECT * FROM employees WHERE last_name = 'King';
/* Using index skip scan with adding a new index */
SELECT * FROM employees WHERE salary BETWEEN 6000 AND 7000;
CREATE INDEX dept_sal_ix ON employees (department_id,salary);
DROP INDEX dept_sal_ix;
/* Using index skip scan with adding a new index
   This time the cost increases significantly */
ALTER INDEX customers_yob_bix invisible;
SELECT * FROM customers WHERE cust_year_of_birth BETWEEN 1989 AND 1990;
CREATE INDEX customers_gen_dob_ix ON customers (cust_gender,cust_year_of_birth);
DROP INDEX customers_gen_dob_ix;
ALTER INDEX customers_yob_bix visible;


REM INDEX JOIN SCAN
REM -----------------

/* Index join scan with two indexes */
SELECT employee_id,email FROM employees;
/* Index join scan with two indexes, but with range scan included*/
SELECT last_name,email FROM employees WHERE last_name LIKE 'B%';
/* Index join scan is not performed when we add rowid to the select clause */
SELECT rowid,employee_id,email FROM employees;
 