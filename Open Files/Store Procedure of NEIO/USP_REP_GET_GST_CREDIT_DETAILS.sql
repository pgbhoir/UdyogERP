
/****** Object:  StoredProcedure [dbo].[USP_REP_GET_GST_CREDIT_DETAILS]    Script Date: 05/11/2018 12:39:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[USP_REP_GET_GST_CREDIT_DETAILS]
@SDATE SMALLDATETIME,@EDATE SMALLDATETIME
As


/*		Creating Temporary  Table		*/
/* LineRule Column added by Suraj Kumawat date on 15-02-2018 for Bug-31248*/

SELECT Pinvno,pinvdt
	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=convert(varchar(2000),c.it_desc) 
	,a.Net_amt,a.net_amt as [Gross Amount]
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT
	,ep.ICGST_AMT   --Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,b.SGST_AMT
	,ep.ISGST_AMT  --Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,b.IGST_AMT
	,ep.IIGST_AMT  --Added by Prajakta B. on 11052018 for Installer
	,b.It_code,entry_ty= cast('' AS varchar(50)),a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
	,b.itserial-- added by Prajakta b on 30112017
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	,b.LineRule
	Into #tmptbl
	FROM PTMAIN a 
	--, Ptitem b ,It_mast c 
	inner join Ptitem b on (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)--Added by Prajakta B. on 11052018 for Installer
	inner join It_mast c on(b.it_code=c.it_code)--Added by Prajakta B. on 11052018 for Installer
	left JOIN Epayment EP ON(b.entry_ty=ep.entry_ty and b.Tran_cd=ep.tran_cd and b.itserial=ep.itserial)   --Added by Prajakta B. on 11052018 for Installer
	 Where 1=2
	
--added by Prajata B. on 30112017 start
/*	Inserting Goods Bills			*/

;WITH ABCD AS (
SELECT Pinvno,pinvdt
	--,c.hsncode  --Commented by Prajakta B. on 11052018 for Installer 
	,hsncode=case when c.isService=0 then c.hsncode else c.ServTCode end  --Modified by Prajakta B. on 11052018 for Installer
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt,0 as [Gross Amount]
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.CGST_PER,cgst_amt=(b.CGST_AMT-isnull(ep.ICGST_AMT,0)),ICGST_AMT=isnull(ep.ICGST_AMT,0)--Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,sgst_amt=(b.SGST_AMT-isnull(ep.ISGST_AMT,0)),ISGST_AMT=isnull(ep.ISGST_AMT,0)--Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,igst_amt=(b.IGST_AMT-isnull(ep.IIGST_AMT,0)),IIGST_AMT=isnull(ep.IIGST_AMT,0)--Added by Prajakta B. on 11052018 for Installer
	,b.It_code
	--,a.entry_ty
	,entry_ty=case when a.entry_ty='PT' then 'Purchase' when a.entry_ty='P1' then 'Import Purchase' else '' end
	,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,b.itserial
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	,ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,b.LineRule
	FROM PTMAIN a 
	--, Ptitem b ,It_mast c
	inner join Ptitem b on (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)--Added by Prajakta B. on 11052018 for Installer
	inner join It_mast c on(b.it_code=c.it_code)--Added by Prajakta B. on 11052018 for Installer
	left JOIN Epayment EP ON(b.entry_ty=ep.entry_ty and b.Tran_cd=ep.tran_cd and b.itserial=ep.itserial)   --Added by Prajakta B. on 11052018 for Installer
	  Where --(a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		--and b.it_code=c.it_code and 
		a.Date between @SDATE and @EDATE
		and a.Entry_ty in ('PT','P1') 
		and (b.CGST_AMT+b.SGST_AMT+b.IGST_AMT) > 0  --Added by Prajakta B. on 11052018 for Installer
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
 from abcd 
 order by entry_ty,Tran_cd 
	
/*	Inserting Goods Bill RCM Entries    */
/* Added by Prajakta B. on 11052018 for Installer Start */
;WITH ABCD AS (
SELECT Pinvno,pinvdt
	--,c.hsncode --Commented by Prajakta B. on 11052018 for Installer
	,hsncode=case when c.isService=0 then c.hsncode else c.ServTCode end  --Modified by Prajakta B. on 11052018 for Installer
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt,0 as [Gross Amount]
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.CGST_PER,cgst_amt=(b.CGSRT_AMT-isnull(ep.ICGST_AMT,0)),ICGST_AMT=isnull(ep.ICGST_AMT,0)--Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,sgst_amt=(b.SGSRT_AMT-isnull(ep.ISGST_AMT,0)),ISGST_AMT=isnull(ep.ISGST_AMT,0)--Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,igst_amt=(b.IGSRT_AMT-isnull(ep.IIGST_AMT,0)),IIGST_AMT=isnull(ep.IIGST_AMT,0)--Added by Prajakta B. on 11052018 for Installer
	,b.It_code
	--,a.entry_ty
	,entry_ty=case when a.entry_ty='PT' then 'Purchase' when a.entry_ty='P1' then 'Import Purchase' else '' end
	,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,b.itserial
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	,ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,b.LineRule
	FROM PTMAIN a 
	--, Ptitem b ,It_mast c 
	--, Ptitem b ,It_mast c
	inner join Ptitem b on (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)--Added by Prajakta B. on 11052018 for Installer
	inner join It_mast c on(b.it_code=c.it_code)--Added by Prajakta B. on 11052018 for Installer
	left JOIN Epayment EP ON(b.entry_ty=ep.entry_ty and b.Tran_cd=ep.tran_cd and b.itserial=ep.itserial)   --Added by Prajakta B. on 11052018 for Installer 
	Where --(a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		--and b.it_code=c.it_code and 
		a.Date between @SDATE and @EDATE
		and a.Entry_ty in ('PT','P1')
		and (b.CGSRT_AMT+b.SGSRT_AMT+b.IGSRT_AMT) > 0  --Added by Prajakta B. on 11052018 for Installer
		and a.entry_ty+QUOTENAME(a.tran_cd) in (select entry_all+QUOTENAME(main_tran) from mainall_vw)  --Added by Prajakta B. on 11052018 for Installer
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
 from abcd 
 order by entry_ty,Tran_cd 	
/* Added by Prajakta B. on 11052018 for Installer End */

/*	Inserting Service Bill			*/

;WITH ABCD AS (
SELECT Pinvno,pinvdt
	--,c.hsncode  --Commented by Prajakta B. on 11052018 for Installer
	,hsncode=case when c.isService=0 then c.hsncode else c.ServTCode end  --Modified by Prajakta B. on 11052018 for Installer
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt,0 as [Gross Amount],b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT
	,ICGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,b.SGST_AMT
	,ISGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,b.IGST_AMT
	,IIGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.It_code
	--,a.entry_ty
	,entry_ty=case when a.entry_ty='E1' then 'Service Purchase Bill' else '' end
	,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,b.itserial
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus,
	ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,b.LineRule
	FROM EPMAIN a , Epitem b ,It_mast c  
	Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd) and b.it_code=c.it_code  
	and a.Entry_ty in ('E1') and a.Date between @SDATE and @EDATE
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
from abcd 
  
--/*	Inserting Credit Note Bills		*/
;WITH ABCD AS (
SELECT Pinvno=a.Inv_no,pinvdt=a.Date
	--,c.hsncode  --Commented by Prajakta B. on 11052018 for Installer
	,hsncode=case when c.isService=0 then c.hsncode else c.ServTCode end  --Modified by Prajakta B. on 11052018 for Installer
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt,0 as [Gross Amount]
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT
	,ICGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,b.SGST_AMT
	,ISGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,b.IGST_AMT
	,IIGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.It_code
	--,a.entry_ty
	,entry_ty=case when a.entry_ty='GC' then 'Credit Note for GST' when a.entry_ty='C6' then 'Credit Note for Services' else '' end
	,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,b.itserial
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	,ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,b.LineRule
	FROM CNMAIN a 
	, CNitem b ,It_mast c--,SpDiff d
	,#tmptbl e 
	 Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code 
		--and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty and d.Pentry_ty=e.entry_ty and d.Ptran_Cd=e.Tran_cd
		and a.Date between @SDATE and @EDATE
		and a.Entry_ty in ('GC','C6')
		and a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL')	
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
from abcd 


--/*	Inserting debit Note Bills		*/
;WITH ABCD AS (
SELECT Pinvno=a.Inv_no,pinvdt=a.Date
	--,c.hsncode  --Commented by Prajakta B. on 11052018 for Installer
	,hsncode=case when c.isService=0 then c.hsncode else c.ServTCode end  --Modified by Prajakta B. on 11052018 for Installer
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt,0 as [Gross Amount]
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT
	,ICGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,b.SGST_AMT
	,ISGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,b.IGST_AMT
	,IIGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.It_code
	,entry_ty=case when a.entry_ty='GD' then 'Debit Note for GST' when a.entry_ty='D6' then 'Debit Note for Services' else '' end
	,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,b.itserial
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	,ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,b.LineRule
	FROM DNMAIN a 
	, DNitem b ,It_mast c--,SpDiff d
	,#tmptbl e  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code 
		--and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty and d.Pentry_ty=e.entry_ty and d.Ptran_Cd=e.Tran_cd
		and a.Date between @SDATE and @EDATE
		and a.Entry_ty in ('GD','D6')
		and a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL')	
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
from abcd 

--/*	Inserting Purchase Return */
;WITH ABCD AS (
 SELECT Pinvno=a.Inv_no,pinvdt=a.Date
	--,c.hsncode  --Commented by Prajakta B. on 11052018 for Installer
	,hsncode=case when c.isService=0 then c.hsncode else c.ServTCode end  --Modified by Prajakta B. on 11052018 for Installer
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt,0 as [Gross Amount]
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT
	,ICGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,b.SGST_AMT
	,ISGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,b.IGST_AMT
	,IIGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.It_code
	--,a.entry_ty
	,entry_ty=case when a.entry_ty='PR' then 'Purchase Return' else '' end
	,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,b.itserial
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	,ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,b.LineRule
	FROM PRMAIN a 
	, PRitem b ,It_mast c--,SpDiff d
	,#tmptbl e  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code 
		--and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty and d.Pentry_ty=e.entry_ty and d.Ptran_Cd=e.Tran_cd
		and a.Date between @SDATE and @EDATE
		and a.Entry_ty ='PR'
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
from abcd 

--added by Prajakta B. on 09112017 start for Bug 30755	
;WITH ABCD AS (	
SELECT Pinvno=a.inv_no,pinvdt=a.date 
	,0 as hsncode,'' as SupplyType
	,'' as Descript
	,0 as Net_amt
	,0 as TaxableVal
	,0 as CGST_PER
	,case when ac_name='Central GST Provisional A/C' then a.amount end AS CGST_AMT
	,0 as ICGST_AMT   --Added by Prajakta B. on 11052018 for Installer
	,0 as SGST_PER
	,case when ac_name='State GST Provisional A/C' then a.amount end AS SGST_AMT
	,0 as ISGST_AMT   --Added by Prajakta B. on 11052018 for Installer
	,0 as IGST_PER
	,case when ac_name='Integrated GST Provisional A/C' then a.amount end AS IGST_AMT
	,0 as IIGST_AMT   --Added by Prajakta B. on 11052018 for Installer
	,0 as It_code,a.entry_ty,a.Tran_cd,a.Ac_id,'' as itserial
	,0 as sac_id,'' as TranStatus
	,ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,LineRule =''
	FROM OBACDET  a 
	Where a.Entry_ty ='OB' 	and a.Date between @SDATE and @EDATE 
	      and ac_name in('Central GST Provisional A/C','State GST Provisional A/C','Integrated GST Provisional A/C') 
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
from abcd 

--added by Prajakta B. on 09112017 end for Bug 30755

-- added by Prajakta B. on 28042018 for Installer Start
--/*	Inserting ISD Invoice Receipt & ISD Credit Note*/
;WITH ABCD AS (
 SELECT Pinvno=a.Inv_no,pinvdt=a.Date
	--,c.hsncode  --Commented by Prajakta B. on 11052018 for Installer
	,hsncode=case when c.isService=0 then c.hsncode else c.ServTCode end  --Modified by Prajakta B. on 11052018 for Installer
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt,0 as [Gross Amount]
	,0 as TaxableVal
	,b.CGST_PER,b.CGST_AMT
	,ICGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.SGST_PER,b.SGST_AMT
	,ISGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.IGST_PER,b.IGST_AMT
	,IIGST_AMT=0  --Added by Prajakta B. on 11052018 for Installer
	,b.It_code
	--,a.entry_ty
	,entry_ty=case when a.entry_ty='J6' then 'ISD Invoice Receipt' when a.entry_ty='J8' then 'ISD Credit Note' else '' end
	,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,b.itserial
	,'' as sac_id,'' as TranStatus
	,ROW_NUMBER() OVER (PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY a.Entry_ty,a.Tran_cd) AS rk
	,b.LineRule
	FROM JVMAIN a 
	, JVITEM b ,It_mast c--,SpDiff d
	Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code 
		and a.Date between @SDATE and @EDATE
		and a.Entry_ty  in ('J6','J8')
)
Insert Into #tmptbl
SELECT Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,(case when rk>1 then 0 else net_amt end) as [Gross Amount],TaxableVal
	,CGST_PER,CGST_AMT,ICGST_AMT,SGST_PER,SGST_AMT,ISGST_AMT,IGST_PER,IGST_AMT,IIGST_AMT,It_code,entry_ty,Tran_cd,Ac_id,itserial,sac_id,TranStatus,LineRule
from abcd 

-- added by Prajakta B. on 28042018 for Installer end

--	--Delete from #tmptbl Where TranStatus<>1	
	
/*	Fetching all records by summarizing GSTIN AND HSN/SAC,PARTY AND BILL NO.		*/
	select GSTIN=case when ISNULL(c.gstin,'')='' then b.gstin else c.gstin end,Party_nm=b.ac_name
	,Pinvno,pinvdt
	,StateCode=case when ISNULL(c.StateCode,'')='' then b.StateCode else c.StateCode end
	,[State]=case when ISNULL(c.[State],'')='' then b.[State] else c.[State] end
	,hsncode,SupplyType,Descript,Net_amt,[Gross Amount],TaxableVal=SUM(TaxableVal)
	,CGST_PER,CGST_AMT=sum(CGST_AMT)
	,ICGST_AMT=SUM(ICGST_AMT)
	,SGST_PER,SGST_AMT=sum(SGST_AMT)
	,ISGST_AMT=SUM(ISGST_AMT)
	,IGST_PER,IGST_AMT=sum(IGST_AMT)
	,IIGST_AMT=SUM(IIGST_AMT)
	,entry_ty,a.Tran_cd,a.Ac_id,a.itserial,a.sac_id
	,[Trans. Status]=Case When a.TranStatus=1 then 'Accepted' else 'Pending' End
	,LineRule 
	 from #tmptbl a
		Inner join AC_MAST b on (a.Ac_id=b.Ac_id)
		Left Join SHIPTO c on (a.sac_id=shipto_id and a.Ac_id=c.Ac_id)
	 Group by b.gstin,c.GSTIN,b.ac_name,Pinvno,pinvdt,hsncode,SupplyType,Descript,Net_amt,[Gross Amount],CGST_PER
			,SGST_PER,IGST_PER,entry_ty,a.Tran_cd,a.Ac_id,a.itserial,a.sac_id,c.[State],b.[State],c.statecode,b.statecode,a.TranStatus,a.LineRule
	 order by entry_ty,Tran_cd,itserial	

Drop Table #tmptbl


--Commented by prajakta B . on 30112017 start
--Insert Into #tmptbl
--SELECT Pinvno,pinvdt
--	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
--	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
--	,a.Net_amt
--	,b.U_ASSEAMT as TaxableVal
--	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
--	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
--	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
--	FROM PTMAIN a 
--	, Ptitem b ,It_mast c  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
--		and b.it_code=c.it_code and a.Date between @SDATE and @EDATE
--		and a.Entry_ty in ('PT','P1')
	
	
--/*		Inserting Service Bill			*/
--Insert Into #tmptbl
--SELECT Pinvno,pinvdt
--	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
--	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
--	,a.Net_amt
--	,b.U_ASSEAMT as TaxableVal
--	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
--	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
--	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
--	FROM EPMAIN a 
--	, Epitem b ,It_mast c  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
--		and b.it_code=c.it_code and a.Date between @SDATE and @EDATE
--		and a.Entry_ty in ('E1')

--/*		Inserting Credit Note Bills		*/
--Insert Into #tmptbl
--SELECT Pinvno=a.Inv_no,pinvdt=a.Date
--	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
--	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
--	,a.Net_amt
--	,b.U_ASSEAMT as TaxableVal
--	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
--	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
--	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
--	FROM CNMAIN a 
--	, CNitem b ,It_mast c,SpDiff d,#tmptbl e  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
--		and b.it_code=c.it_code 
--		and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty and d.Pentry_ty=e.entry_ty and d.Ptran_Cd=e.Tran_cd
--		and a.Date between @SDATE and @EDATE
--		and a.Entry_ty in ('GC','C6')
--		and a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL')		

--/*		Inserting debit Note Bills		*/
--Insert Into #tmptbl
--SELECT Pinvno=a.Inv_no,pinvdt=a.Date
--	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
--	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
--	,a.Net_amt
--	,b.U_ASSEAMT as TaxableVal
--	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
--	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
--	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
--	FROM DNMAIN a 
--	, DNitem b ,It_mast c,SpDiff d,#tmptbl e  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
--		and b.it_code=c.it_code 
--		and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty and d.Pentry_ty=e.entry_ty and d.Ptran_Cd=e.Tran_cd
--		and a.Date between @SDATE and @EDATE
--		and a.Entry_ty in ('GD','D6')
--		and a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL')		

--/*		Inserting Purchase Return */
--Insert Into #tmptbl
--SELECT Pinvno=a.Inv_no,pinvdt=a.Date
--	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
--	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
--	,a.Net_amt
--	,b.U_ASSEAMT as TaxableVal
--	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
--	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
--	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
--	FROM PRMAIN a 
--	, PRitem b ,It_mast c,SpDiff d,#tmptbl e  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
--		and b.it_code=c.it_code 
--		and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty and d.Pentry_ty=e.entry_ty and d.Ptran_Cd=e.Tran_cd
--		and a.Date between @SDATE and @EDATE
--		and a.Entry_ty ='PR'

--Commented by prajakta B . on 30112017 end
