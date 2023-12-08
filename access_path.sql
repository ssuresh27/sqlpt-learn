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
