USE [Verpakt_DW]
GO
/****** Object:  StoredProcedure [dbo].[p_Util_SearchAllDBObjectsForString]    Script Date: 2019-04-08 9:38:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_Util_SearchAllDBObjectsForString

ALTER PROC [dbo].[p_Util_SearchAllDBObjectsForString]
	( @SearchString VARCHAR(127)
	)
 AS

--* Example      : EXEC Verpakt_DW.dbo.p_Util_SearchAllDBObjectsForString 'staging.dbo.Work_Withdrawal_iGC_Full'
SET NOCOUNT ON;

DECLARE @Command VARCHAR(4000);

SET @SearchString = '%' + @SearchString + '%';

SELECT @Command = 'USE ?; 
SELECT DISTINCT ''?'' AS DBName, CASE so.[Type] WHEN ''P'' THEN ''Stored Proc'' WHEN ''FN'' THEN ''Scalar Function''
	WHEN ''V'' THEN ''View'' WHEN ''TF'' THEN ''Table-valued Function'' ELSE so.[Type] END AS ObjectType
	, so.Name AS ObjectName--, sc.[Text]
FROM sysobjects AS so WITH (NOLOCK)
	INNER JOIN syscomments AS sc WITH (NOLOCK) ON so.Id = sc.Id
		AND sc.[Text] LIKE ''' + @SearchString + '''
;';
--print @Command;


CREATE TABLE #Results (DBName SYSNAME NOT NULL, ObjectType SYSNAME NOT NULL, ObjectName SYSNAME NOT NULL);

-- This query will run the script on all databases on a SQL instance
INSERT INTO #Results (DBName, ObjectType, ObjectName)
EXEC sp_MSforeachdb @command;

SELECT DBName, ObjectType, ObjectName
FROM #Results WITH (NOLOCK)
ORDER BY DBName, ObjectName
;

DROP TABLE #Results;

--Drop table #Results
