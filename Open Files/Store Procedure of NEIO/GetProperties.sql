DROP PROCEDURE [GetProperties]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procedure [GetProperties] 
@prmTable nvarchar(40)
as
--set nocount on
declare @tmpvar nvarchar(40),@tmpSql nvarchar(100),@prmId numeric
if @prmTable is not null
begin
	set @tmpvar = @prmtable
	declare tcursor cursor  for 
	select id from sysobjects where NAME=@tmpvar
	open tcursor
	fetch next from tcursor into @prmid
	
	Select a.Name,b.*,c.name as typ from syscolumns a,sysproperties b,systypes c 
	where a.id=b.id and a.colid=b.smallid and a.id=@prmid  and convert(char(30),b.value) <> '' 
	 and a.xtype=c.xtype order by a.name  
	
	close tcursor
	deallocate tcursor
       end
GO
