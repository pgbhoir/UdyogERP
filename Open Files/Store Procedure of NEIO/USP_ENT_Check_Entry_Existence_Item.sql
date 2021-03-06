DROP PROCEDURE [USP_ENT_Check_Entry_Existence_Item]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [USP_ENT_Check_Entry_Existence_Item]
@It_code Numeric(10,0)
As

Declare @table Varchar(10),@Sqlcmd NVarchar(4000),@ans Int
DECLARE @ParmDefinition nvarchar(500)

set @ans=0

Declare curentry cursor for 
	Select Distinct Entry_tbl=Case when bcode_nm<>'' then Bcode_nm else (Case when ext_vou=1 then '' else Entry_ty end) end+'Item'   From Lcode Where v_item=1

Open curentry	
Fetch next From curentry Into @table
While @@fetch_Status=0
Begin
	set @Sqlcmd='if Exists(Select Top 1 It_code From '+@table+' Where It_code='+convert(varchar(10),@It_code)+') Select @retvalOUT=Convert(Int,1) else Select @retvalOUT=Convert(Int,0) '
	
	SET @ParmDefinition = N'@retvalOUT int OUTPUT';
	EXEC sp_executesql @Sqlcmd, @ParmDefinition, @retvalOUT=@ans OUTPUT;
	
	if  @ans=1
		break
	Fetch next From curentry Into @table
End
Close curentry
Deallocate curentry

Select ans=@ans
GO
