-- explain plan  - Before exeucting query
-- Auto trace
-- v$sql_plan


-- explain plan [based on estimation]

explain plan for <query>;
explain plan set STATEMENT_ID= 'QUERY1' for <query>; -- using name /id for explain plan table
select * from table(dbms_xplan.display())
select* from plan_table;


NOT CONNECTED > explain plan for select * from employees;

Explained.

NOT CONNECTED > select * from table(dbms_xplan.display())
  2  ;

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------
Plan hash value: 1445457117

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |   107 |  7383 |     3   (0)| 00:00:01 |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   107 |  7383 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

8 rows selected.

NOT CONNECTED >


-- AUTO Trace 

SET AUTOTRACE ON;
SET AUTOTRACE ON [EXPLAIN|STATISTICS];

SET AUTOTRACE TRACE[ONLY] [EXPLAIN|STATISTICS];
show autotrace;
Set autotrace off;


-- SET AUTOTRACE TRACEONLY EXPLAIN

linux01@(ORCL-PRIMARY) > 1
  1* select * from sales s, customers c  where s.CUST_ID = c.cust_id and s.cust_id = 987
linux01@(ORCL-PRIMARY) > /

Execution Plan
----------------------------------------------------------
Plan hash value: 2376477005

------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                   | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                            |                |   130 | 28340 |    54   (0)| 00:00:01 |       |       |
|   1 |  NESTED LOOPS                               |                |   130 | 28340 |    54   (0)| 00:00:01 |       |       |
|   2 |   TABLE ACCESS BY INDEX ROWID               | CUSTOMERS      |     1 |   189 |     0   (0)| 00:00:01 |       |       |
|*  3 |    INDEX UNIQUE SCAN                        | CUSTOMERS_PK   |     1 |       |     0   (0)| 00:00:01 |       |       |
|   4 |   PARTITION RANGE ALL                       |                |   130 |  3770 |    54   (0)| 00:00:01 |     1 |    28 |
|   5 |    TABLE ACCESS BY LOCAL INDEX ROWID BATCHED| SALES          |   130 |  3770 |    54   (0)| 00:00:01 |     1 |    28 |
|   6 |     BITMAP CONVERSION TO ROWIDS             |                |       |       |            |          |       |       |
|*  7 |      BITMAP INDEX SINGLE VALUE              | SALES_CUST_BIX |       |       |            |          |     1 |    28 |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("C"."CUST_ID"=987)
   7 - access("S"."CUST_ID"=987)
       filter("S"."CUST_ID"="C"."CUST_ID")

linux01@(ORCL-PRIMARY) >
linux01@(ORCL-PRIMARY) > show autotrace;
autotrace TRACEONLY EXPLAIN
linux01@(ORCL-PRIMARY) >


-- SET AUTOTRACE TRACEONLY STATISTICS;

linux01@(ORCL-PRIMARY) >  set autotrace traceonly STATISTICS;
linux01@(ORCL-PRIMARY) > select * from sales s, customers c  where s.CUST_ID = c.cust_id and s.cust_id = 987;

180 rows selected.


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        181  consistent gets
        168  physical reads
          0  redo size
      12985  bytes sent via SQL*Net to client
        672  bytes received via SQL*Net from client
         13  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
        180  rows processed

linux01@(ORCL-PRIMARY) >  show autotrace;
autotrace TRACEONLY STATISTICS
linux01@(ORCL-PRIMARY) >


-- SET AUTOTRACE TRACEONLY;


linux01@(ORCL-PRIMARY) > set autotrace traceonly;
linux01@(ORCL-PRIMARY) > select * from sales s, customers c  where s.CUST_ID = c.cust_id and s.cust_id = 987;

180 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 2376477005

------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                   | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                            |                |   130 | 28340 |    54   (0)| 00:00:01 |       |       |
|   1 |  NESTED LOOPS                               |                |   130 | 28340 |    54   (0)| 00:00:01 |       |       |
|   2 |   TABLE ACCESS BY INDEX ROWID               | CUSTOMERS      |     1 |   189 |     0   (0)| 00:00:01 |       |       |
|*  3 |    INDEX UNIQUE SCAN                        | CUSTOMERS_PK   |     1 |       |     0   (0)| 00:00:01 |       |       |
|   4 |   PARTITION RANGE ALL                       |                |   130 |  3770 |    54   (0)| 00:00:01 |     1 |    28 |
|   5 |    TABLE ACCESS BY LOCAL INDEX ROWID BATCHED| SALES          |   130 |  3770 |    54   (0)| 00:00:01 |     1 |    28 |
|   6 |     BITMAP CONVERSION TO ROWIDS             |                |       |       |            |          |       |       |
|*  7 |      BITMAP INDEX SINGLE VALUE              | SALES_CUST_BIX |       |       |            |          |     1 |    28 |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("C"."CUST_ID"=987)
   7 - access("S"."CUST_ID"=987)
       filter("S"."CUST_ID"="C"."CUST_ID")


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        175  consistent gets
          0  physical reads
          0  redo size
      12969  bytes sent via SQL*Net to client
        672  bytes received via SQL*Net from client
         13  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
        180  rows processed

linux01@(ORCL-PRIMARY) >

-- SET AUTOTRACE ON;

linux01@(ORCL-PRIMARY) > set autotrace on ;
linux01@(ORCL-PRIMARY) >  select * from sales s, customers c  where s.CUST_ID = c.cust_id and s.cust_id = 987;

   PROD_ID    CUST_ID TIME_ID   CHANNEL_ID   PROMO_ID QUANTITY_SOLD AMOUNT_SOLD    CUST_ID CUST_FIRST_NAME      CUST_LAST_NAME                           C CUST_YEAR_OF_BIRTH CUST_MARITAL_STATUS
---------- ---------- --------- ---------- ---------- ------------- ----------- ---------- -------------------- ---------------------------------------- - ------------------ --------------------
CUST_STREET_ADDRESS                      CUST_POSTA CUST_CITY                      CUST_CITY_ID CUST_STATE_PROVINCE                      CUST_STATE_PROVINCE_ID COUNTRY_ID CUST_MAIN_PHONE_NUMBER
---------------------------------------- ---------- ------------------------------ ------------ ---------------------------------------- ---------------------- ---------- -------------------------
CUST_INCOME_LEVEL              CUST_CREDIT_LIMIT CUST_EMAIL                                         CUST_TOTAL     CUST_TOTAL_ID CUST_SRC_ID CUST_EFF_ CUST_EFF_ C
------------------------------ ----------------- -------------------------------------------------- -------------- ------------- ----------- --------- --------- -
        13        987 10-JAN-98          3        999             1     1232.16        987 York                 Raimey                                   M      1973 single
897 Freshened Street                     46274      Adelaide                              51045 South Australia                                           52741      52774 (341) 841-7590
K: 250,000 - 299,999                       11000 york.raimey@company2.example.com                   Customer total         52772             01-JAN-98          A

        13        987 10-MAR-98          3        999             1     1232.99        987 York                 Raimey                                   M      1973 single
897 Freshened Street                     46274      Adelaide                              51045 South Australia                                           52741      52774 (341) 841-7590

..
..

180 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 2376477005

------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                   | Name           | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                            |                |   130 | 28340 |    54   (0)| 00:00:01 |       |       |
|   1 |  NESTED LOOPS                               |                |   130 | 28340 |    54   (0)| 00:00:01 |       |       |
|   2 |   TABLE ACCESS BY INDEX ROWID               | CUSTOMERS      |     1 |   189 |     0   (0)| 00:00:01 |       |       |
|*  3 |    INDEX UNIQUE SCAN                        | CUSTOMERS_PK   |     1 |       |     0   (0)| 00:00:01 |       |       |
|   4 |   PARTITION RANGE ALL                       |                |   130 |  3770 |    54   (0)| 00:00:01 |     1 |    28 |
|   5 |    TABLE ACCESS BY LOCAL INDEX ROWID BATCHED| SALES          |   130 |  3770 |    54   (0)| 00:00:01 |     1 |    28 |
|   6 |     BITMAP CONVERSION TO ROWIDS             |                |       |       |            |          |       |       |
|*  7 |      BITMAP INDEX SINGLE VALUE              | SALES_CUST_BIX |       |       |            |          |     1 |    28 |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("C"."CUST_ID"=987)
   7 - access("S"."CUST_ID"=987)
       filter("S"."CUST_ID"="C"."CUST_ID")


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
        175  consistent gets
          0  physical reads
          0  redo size
      12969  bytes sent via SQL*Net to client
        672  bytes received via SQL*Net from client
         13  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
        180  rows processed


-- AUTOTRACE OFF

linux01@(ORCL-PRIMARY) > show autotrace
autotrace ON EXPLAIN STATISTICS
linux01@(ORCL-PRIMARY) > set autotrace off;
linux01@(ORCL-PRIMARY) > show autotrace
autotrace OFF
linux01@(ORCL-PRIMARY) >


--
-- V$SQL_PLAN VIEW
v$SQLAREA
V$SQLWORKAREA
V$SQL 
V$SQL_PLAN
V$SQL_PLAN_STATISTICS
V$SQL_PLAN_STATISTICS_ALL


select /* MYQUERY */ from employees where emp_id=100;

select * fom v$sql where sql_text like '%MYQUERY%';

select * from v$sql_plan where sql_id='';
select * from table(dbms_xplan.display_cursor('sql_id'))