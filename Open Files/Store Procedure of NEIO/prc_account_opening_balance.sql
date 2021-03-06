DROP PROCEDURE [prc_account_opening_balance]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procedure [prc_account_opening_balance]
@acnm char(50),@sdate smalldatetime,@@opbal decimal(13,2) output
as
begin
	declare @opbal decimal(14,2)
	declare @ety char(2),@qry nvarchar(4000),@entry_ty char(15),@bcode char(2),@amt decimal(12,2),@amttype char(2)
	set @@opbal = 0
	set @amt = 0
	set @amttype =''
	select lac_vw.* into opbalval from lac_vw,lmain_vw where lac_vw.entry_ty = lmain_vw.entry_ty and 
		lac_vw.date = lmain_vw.date and lac_vw.doc_no = lmain_vw.doc_no 
			and rtrim(lac_vw.ac_name) =rtrim( @acnm) and lmain_vw.[date]<@sdate
	declare opBalance cursor for
		select amount,amt_ty from opbalval
	open opBalance
	fetch next from opBalance into @amt,@amttype
	while @@fetch_status = 0
	begin
		if @amttype='CR'
		begin	
			set @@opbal = @@opbal + @amt
		end
		else
		begin
			set @@opbal = @@opbal - @amt
		end
		fetch next from opBalance into @amt,@amttype
	end
	close opBalance
	deallocate opBalance
	drop table opbalval
	return @@opbal
end
GO
