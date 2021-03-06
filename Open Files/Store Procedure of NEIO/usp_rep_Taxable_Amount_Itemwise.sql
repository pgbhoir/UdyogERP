DROP PROCEDURE [usp_rep_Taxable_Amount_Itemwise]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hetal Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Itemwise Discount and Charges Field string.
-- Modify date: 16/10/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================

CREATE procedure [usp_rep_Taxable_Amount_Itemwise]
@entry_ty varchar(2)
,@table_nm varchar(30)
,@fld_list  NVARCHAR(2000) OUTPUT
as
declare @code varchar(2),@fld_nm varchar(20),@a_s varchar(1)
set @fld_list=''

declare cur_Taxable_Amount cursor for
select 
fld_nm=(case when (code='D') or (a_s='-') then '-' else '+' end)+rtrim(@table_nm)+'.'+rtrim(fld_nm)
from dcmast where entry_ty=@entry_ty and code in ('D','T','E','A') and att_file=0 and excl_gross <>''
open cur_Taxable_Amount
fetch next from cur_Taxable_Amount into @fld_nm
while (@@fetch_status=0)
begin
	set @fld_list=@fld_list+@fld_nm
	fetch next from cur_Taxable_Amount into @fld_nm
end
close cur_Taxable_Amount
deallocate cur_Taxable_Amount
print @fld_list
GO
