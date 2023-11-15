
-- System Statistics
EXEC dbms_stats.gather_system_stats('Start');
--Verify the stats 
select * from sys.aux_stats$;

-- Optimizer statistics
-- Can be gathered automatically or manually 