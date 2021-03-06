DROP PROCEDURE [Add_Idx]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [Add_Idx] 
@tblnm as varchar(100),
@ColumnDefination varchar(1000),
@IdxDefination varchar(100)
as
declare @name varchar(30),@sqlcommand nvarchar(1000),@fld_exists bit,@id int
declare cur_name cursor for select [name],id from sysobjects where [type]='U' and [name] like @tblnm --'%acdet'
open cur_name
fetch next from cur_name into @name,@id
while (@@fetch_status=0)
begin
	set @sqlcommand=' '
	IF  EXISTS (SELECT a.name FROM sys.indexes a,sys.objects b where a.object_id = b.object_id and b.name = @name AND a.name = @IdxDefination)
	begin
		set @sqlcommand='DROP INDEX '+@IdxDefination+' ON '+@name+' WITH ( ONLINE = OFF )'
		execute sp_executesql @sqlcommand
	end

	set @sqlcommand=' '
	set @sqlcommand='CREATE NONCLUSTERED INDEX '+@IdxDefination+' ON '+@name+' ('
	set @sqlcommand=@sqlcommand+@ColumnDefination
	set @sqlcommand=@sqlcommand+') WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]'
	execute sp_executesql @sqlcommand

	fetch next from cur_name into @name,@id
end
close cur_name
deallocate cur_name
GO
