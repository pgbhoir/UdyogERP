DROP PROCEDURE [USP_CHK_CURR_LCODE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [USP_CHK_CURR_LCODE]
@FC_ID AS INT,@FC_Date as datetime
AS
DECLARE @ENTRY_TY AS VARCHAR(2), @BCODE_NM AS VARCHAR(2),@SQLCOMMAND as NVARCHAR(4000),@flag as bit
DECLARE @RECCOUNT AS INT 
CREATE TABLE #TEMPCUR (ENTRY_TY VARCHAR(2), CENT INT) --Added By Amrendra for TKT-9723

DECLARE CurLcode CURSOR FOR 
SELECT ENTRY_TY = (CASE WHEN ISNULL(bcode_nm,'')='' THEN entry_ty ELSE bcode_nm END) FROM LCODE WHERE MULTI_CUR = 1
OPEN CurLcode
FETCH NEXT FROM CurLcode INTO @ENTRY_TY
WHILE @@Fetch_Status=0
BEGIN 
--CREATE TABLE #TEMPCUR (ENTRY_TY VARCHAR(2), CENT INT) --Commented By Amrendra for TKT-9723
--Added by Amrendra for Bug-56 on 14-10-2011 [Start]
set @flag=0
set @SQLCOMMAND='if exists(SELECT ENTRY_TY, COUNT(FCID) AS CENT FROM '+@ENTRY_TY+'MAIN WHERE FCID = '+CAST(@FC_ID AS VARCHAR (5))+' and date='+char(39)+cast(@FC_Date as varchar)+char(39)+' GROUP BY ENTRY_TY )
begin
select @flagOut=1
end'
print @SQLCOMMAND
execute sp_executesql @sqlcommand ,N'@flagOut bit output',@flagOut=@Flag output
if @flag=1
begin
--Added by Amrendra for Bug-56 on 14-10-2011 [End]
--set @SQLCOMMAND = 'INSERT INTO #TEMPCUR SELECT ENTRY_TY, COUNT(FCID) AS CENT FROM '+@ENTRY_TY+'MAIN WHERE FCID = '+CAST(@FC_ID AS VARCHAR (5))+' GROUP BY ENTRY_TY ' --Commented By Amrendra for Bug-56 on 14/10/2011
set @SQLCOMMAND = 'INSERT INTO #TEMPCUR SELECT ENTRY_TY, COUNT(FCID) AS CENT FROM '+@ENTRY_TY+'MAIN WHERE FCID = '+CAST(@FC_ID AS VARCHAR (5))+' and date='+char(39)+cast(@FC_Date as varchar)+char(39)+' GROUP BY ENTRY_TY ' --Added By Amrendra for Bug-56 on 14/10/2011
execute sp_executesql @sqlcommand
PRINT @sqlcommand
end 
FETCH NEXT FROM CurLcode INTO @ENTRY_TY
END
CLOSE CurLcode
DEALLOCATE CurLcode
SELECT TOP 1 @RECCOUNT = CENT FROM #TEMPCUR WHERE CENT > 0
SELECT FCIDCNT = ISNULL(@RECCOUNT,0)
DROP TABLE #TEMPCUR
GO
