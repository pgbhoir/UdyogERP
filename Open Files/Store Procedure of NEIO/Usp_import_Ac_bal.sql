DROP PROCEDURE [Usp_import_Ac_bal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Birendra : Function has use to update automatic in it_bal and it_balw like  other table updation. 
CREATE procedure [Usp_import_Ac_bal]
@acdet_temp Varchar(100),@acdet_table Varchar(100)
as 
Begin
---------------------------Ac_Bal----------------------------------------Start


	declare @SqlCommand nvarchar(max),@compid int
	set @compid=isnull((select top 1 compid from vudyog..co_mast where dbname=db_name()),0)
--	set @SqlCommand ='select * into biru_acbal from '+@acdet_temp
--	execute sp_executesql @SqlCommand

	set @SqlCommand ='Update  a set a.Dr=isnull(a.dr,0)-isnull(case when b.amt_ty=''DR'' then cast(b.amount as numeric(30,2)) else 0 end,0)
					,a.Cr=isnull(a.Cr,0)-isnull(case when b.amt_ty=''CR'' then cast(b.amount as numeric(30,2))  else 0 end,0) 
						from ac_bal a inner join
					(select i.ac_name,i.amount,i.amt_ty,i.compid from '+ltrim(rtrim(@acdet_table))+' i  
					where i.dataimport in (select dataexport1 from '+ltrim(rtrim(@acdet_temp))+')) 
					 b on 
					(a.ac_name=b.ac_name and a.compid=b.compid)
					'
	execute sp_executesql @SqlCommand

print 'Biru1'

print @SqlCommand

	set @SqlCommand ='Update  a set a.Dr=isnull(a.dr,0)+isnull(case when b.amt_ty=''DR'' then cast(b.amount as numeric(30,2)) else 0 end,0)
					,a.Cr=isnull(a.Cr,0)+isnull(case when b.amt_ty=''CR'' then cast(b.amount as numeric(30,2)) else 0 end,0) 
						from ac_bal a inner join
					(select i.ac_name,i.amount,i.amt_ty from '+ltrim(rtrim(@acdet_temp))+' i) 
					 b on 
					(a.ac_name=b.ac_name)
					'
	execute sp_executesql @SqlCommand


	set @SqlCommand ='insert into ac_bal (ac_id,ac_name,Dr,CR,compid)
					select i.ac_id,i.ac_name,sum(cast(rtrim(ltrim(case when i.amt_ty=''DR'' then i.amount else ''0'' end)) as numeric(30,2)))
					,sum(cast(rtrim(ltrim(case when i.amt_ty=''CR'' then i.amount else ''0'' end)) as numeric(30,2)))
					, i.compid
					from '+ltrim(rtrim(@acdet_temp))+' i  
					where ltrim(rtrim(i.ac_name))+space(1)+ltrim(rtrim(cast(compid as varchar(10)))) not in 
					(select ac_name+space(1)+ltrim(rtrim(cast(compid as varchar(10)))) from ac_bal)
					group by i.ac_id,i.ac_name,i.compid
					'

	execute sp_executesql @SqlCommand



---------------------------Ac_bal----------------------------------------End
end
GO
