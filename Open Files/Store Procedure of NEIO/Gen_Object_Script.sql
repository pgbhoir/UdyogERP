DROP PROCEDURE [Gen_Object_Script]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Gen_Object_Script] 
@ObjName Varchar(200)
as 
Set Nocount On
Declare @SqlCmd NVarchar(max)
Create Table #tmpScript1(ObjectScript Varchar(8000) )
Set @SqlCmd ='Insert Into #tmpScript1 Execute Sp_HelpText '+rtrim(@ObjName)
Execute sp_ExecuteSql @SqlCmd 


select * from #tmpScript1
GO
