DROP PROCEDURE [prcItmGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [prcItmGroup]
	@mGroup varchar(50),@@curtmp cursor varying output
as
declare @mCond varchar(1)
declare @mSql nvarchar(4000)
declare @mrow smallInt, @mStage smallInt, @mTotal smallInt
declare @mNewStage as varchar(100), @mPrevStage as varchar(100), @mTable as nvarchar(100)
set @mRow=0
set @mStage=1
set @mCond = 'T'
if exists(select name from tempdb.dbo.sysobjects where name = '##ItmGroup1' and xtype = 'U')
	drop table ##Itmgroup1
set @mSql = 'Select It_group_name, [Group] into ##ItmGroup' + ltrim(rtrim(str(@mStage))) + ' from Item_group where rTrim(UPPER(It_group_name))=''' + @mGroup + ''''

Exec sp_executeSql @mSql

while @mCond = 'T'
begin
	set @mStage = @mStage + 1
	set @mNewStage = '##ItmGroup' + ltrim(rtrim(str(@mStage)))
	set @mPrevStage = '##ItmGroup' + ltrim(rtrim(str(@mStage-1)))
	if exists(select name from tempdb.dbo.sysobjects where name = @mNewStage and xtype = 'U')
	begin
		set @mTable = 'drop table ' + @mNewStage
		Exec sp_executeSql @mTable
	end

	set @mSql = 'Select It_group_name, [Group] into ' + ltrim(rtrim(@mNewStage)) + ' from Item_group Where [GROUP] in '
	set @mSql = @mSql + '(Select It_group_name from ' + ltrim(rtrim(@mPrevStage)) + ')'
	set @mSql = @mSql + ' union '
	set @mSql = @mSql + 'Select * from ' + @mPrevStage
	Exec sp_executeSql @mSql
	set @mTotal = @@rowCount
	if @mRow=@mTotal
		set @mCond = 'F'
	set @mRow = @mTotal
end

set @mRow=1
while @mStage > @mRow
begin
	set @mPrevStage='##ItmGroup'+ ltrim(rtrim(str(@mRow)))
	if exists(select name from tempdb.dbo.sysobjects where name = @mPrevStage and xtype = 'U')
	Begin
		set @mTable = 'drop table ' + @mPrevStage
		Exec sp_executeSql @mTable
	End
	set @mRow = @mRow +1
end
set @mSql = 'Select * into tbltest from ' +  @mNewStage + ' order by it_group_name '
exec sp_executeSql @mSql
set @@curTmp = cursor --for
FORWARD_ONLY STATIC for
select * from tbltest
open @@curTmp
drop table tbltest
set @mSql='drop table '+ @mNewStage
exec sp_executeSql @mSql
GO
