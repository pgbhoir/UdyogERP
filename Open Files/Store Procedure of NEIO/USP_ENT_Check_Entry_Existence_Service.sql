DROP PROCEDURE [USP_ENT_Check_Entry_Existence_Service]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [USP_ENT_Check_Entry_Existence_Service]
@sac Varchar(10)
As

Declare @table Varchar(10),@Sqlcmd NVarchar(4000),@ans Int
DECLARE @ParmDefinition nvarchar(500)

Select It_code as itemcode Into #itmast From It_mast 
Where 
ServTCode=@sac --Modified by Priyanka B on 24082017
--hsncode=@sac --Commented by Priyanka B on 24082017
and Isservice=1
set @ans=0

Declare curentry cursor for 
	Select Distinct Entry_tbl=Case when bcode_nm<>'' then Bcode_nm else (Case when ext_vou=1 then '' else Entry_ty end) end+'Item'   From Lcode Where v_item=1

Open curentry	
Fetch next From curentry Into @table
While @@fetch_Status=0
Begin
	set @Sqlcmd='if Exists(Select Top 1 It_code From '+@table+' Inner Join #itmast On (#itmast.itemcode='+@table+'.It_code) ) Select @retvalOUT=Convert(Int,1) else Select @retvalOUT=Convert(Int,0) '
	
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
