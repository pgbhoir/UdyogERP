DROP PROCEDURE [Usp_Ent_AccountFoundFromGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 
-- Description:	This Stored procedure is useful in Account Selection in uereport.app.
-- Modify By/Date/Reason: Rupesh Prajapati. 19/02/2010 to Add It_Desc Column. TKT-110.
-- Remark:
-- =============================================
CREATE procedure [Usp_Ent_AccountFoundFromGroup]
@accGroup varchar(50)
as
declare @grop varchar(50),@grp varchar(50),@mgrp varchar(50),@acc varchar(50),@MailName varchar(200)
set @grp=''
set @grop=''
set @mgrp=''
set @acc=''
select ac_name as acname,[group],MailName into #accounts from ac_mast where 1=2
declare @@sqlqry cursor
exec prcAccGroup @accgroup,@@curtmp = @@sqlqry output
fetch next from @@sqlqry into @grp,@mgrp
while @@fetch_status=0
begin
	declare curacMast cursor for
	select ac_name,[group],MailName=(case when ISNULL(MailName,'')='' then ac_name else mailname end) from ac_mast where [group]=@grp
	open curacMast
	fetch next from curacMast into @acc,@grop,@MailName
	while @@fetch_status=0
	begin
		insert into #accounts (acname,[group],MailName) values(@acc,@grop,@MailName)
		fetch next from curAcMast into @acc,@grop,@MailName
	end
	close curacMast
	deallocate curacMast
	fetch next from @@sqlqry into @grp,@mgrp
end
close @@sqlqry
deallocate @@sqlqry
select acname,[group],MailName from #accounts
drop table #accounts
GO
