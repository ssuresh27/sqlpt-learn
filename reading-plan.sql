-- reading the explain plan

select prod_category, avg(amount_sold)
from sales s, products p
where p.prod_id = s.prod_id
group by prod_category;

------------------------------------------
 Id   Operation              Name   
------------------------------------------
   0  SELECT STATEMENT              
   1   HASH GROUP BY                
   2    HASH JOIN                   
   3     TABLE ACCESS FULL   PRODUCTS
   4     PARTITION RANGE ALL        
   5      TABLE ACCESS FULL  SALES  
------------------------------------------

GROUP BY
      |
     JOIN
 _____|_______
 |            |
ACCESS     ACCESS
(PRODUCTS) (SALES)