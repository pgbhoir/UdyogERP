DROP PROCEDURE [USP_REP_GET_OUTPUT_TAX_LIABILITY_PENDING]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [USP_REP_GET_OUTPUT_TAX_LIABILITY_PENDING]
@SDATE SMALLDATETIME,@EDATE SMALLDATETIME
As

/*		Creating Temporary  Table		*/
SELECT a.Inv_No,a.Date
	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=convert(varchar(2000),c.it_desc) 
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	Into #tmptbl
	FROM STMAIN a 
	, Stitem b ,It_mast c  Where 1=2

/*		Inserting Goods Invoices			*/
Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	FROM STMAIN a 
	, stitem b ,It_mast c  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and a.Entry_ty in ('ST')
	
	
/*		Inserting Service Invoices			*/
Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.staxamt as TaxableVal
	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	FROM sbMAIN a 
	, SBitem b ,It_mast c  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and a.Entry_ty in ('S1')

/*		Inserting Credit Note Bills		*/
Insert Into #tmptbl
SELECT a.Inv_no,a.Date
	,c.hsncode,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,case when a.Entry_ty='D6' then b.staxamt else b.U_ASSEAMT end  as TaxableVal
	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.It_code,a.entry_ty,a.Tran_cd,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end
	,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end,a.TranStatus
	FROM DNMAIN a 
	, DNitem b ,It_mast c,SpDiff d,#tmptbl e  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code 
		and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty and d.Pentry_ty=e.entry_ty and d.Ptran_Cd=e.Tran_cd
		and a.pinvdt between @SDATE and @EDATE
		and a.Entry_ty in ('GD','D6')
		
	Delete from #tmptbl Where TranStatus=1	
	
		
	
/*		Fetching all records by summarizing GSTIN AND HSN/SAC,PARTY AND BILL NO.		*/		
	select GSTIN=case when ISNULL(c.gstin,'')='' then b.gstin else c.gstin end,Party_nm=b.ac_name
	,a.inv_no,a.date
	,StateCode=case when ISNULL(c.StateCode,'')='' then b.StateCode else c.StateCode end
	,[State]=case when ISNULL(c.[State],'')='' then b.[State] else c.[State] end
	,hsncode,SupplyType,Descript,Net_amt,TaxableVal=SUM(TaxableVal),CGST_PER,CGST_AMT=sum(CGST_AMT)
	,SGST_PER,SGST_AMT=sum(SGST_AMT),IGST_PER,IGST_AMT=sum(IGST_AMT),a.entry_ty,a.Tran_cd,a.Ac_id,a.sac_id
	 from #tmptbl a
		Inner join AC_MAST b on (a.Ac_id=b.Ac_id)
		Left Join SHIPTO c on (a.sac_id=shipto_id and a.Ac_id=c.Ac_id)
		Group by b.gstin,c.GSTIN,b.ac_name,a.inv_no,a.date,hsncode,SupplyType,Descript,Net_amt,CGST_PER
			,SGST_PER,IGST_PER,a.entry_ty,a.Tran_cd,a.Ac_id,a.sac_id,c.[State],b.[State],c.statecode,b.statecode

Drop Table #tmptbl
GO
