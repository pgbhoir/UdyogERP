DROP VIEW [Payment_vw]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create View [Payment_vw]
AS 
Select b.Entry_ty,b.Tran_cd,b.itserial,b.cgst_per,cgst_amt=b.cgsrt_amt,b.sgst_per,sgst_amt=b.sgsrt_amt,b.igst_per,igst_amt=b.igsrt_amt,b.ccessrate,compcess=b.comrpcess,a.Inv_no as RefNo,b.u_asseamt from BPMAIN	a
	Inner Join Bpitem b on (a.tran_cd=b.Tran_cd)
	Where a.tdspaytype=2 and (b.cgsrt_amt+b.sgsrt_amt+b.igsrt_amt+b.comrpcess )>0
union all
Select b.Entry_ty,b.Tran_cd,b.itserial,b.cgst_per,cgst_amt=b.cgsrt_amt,b.sgst_per,sgst_amt=b.sgsrt_amt,b.igst_per,igst_amt=b.igsrt_amt,b.ccessrate,compcess=b.comrpcess,a.Inv_no as RefNo,b.u_asseamt from CPMAIN	a
	Inner Join Cpitem b on (a.tran_cd=b.Tran_cd)
	Where a.tdspaytype=2 and (b.cgsrt_amt+b.sgsrt_amt+b.igsrt_amt+b.comrpcess )>0
union all
Select b.Entry_ty,b.Tran_cd,b.itserial,b.cgst_per,b.cgst_amt,b.sgst_per,b.sgst_amt,b.igst_per,b.igst_amt,b.ccessrate,b.compcess,a.Inv_no as RefNo,b.u_asseamt from Brmain	a
	Inner Join Britem b on (a.tran_cd=b.Tran_cd)
	Where a.tdspaytype=2
union all
Select b.Entry_ty,b.Tran_cd,b.itserial,b.cgst_per,b.cgst_amt,b.sgst_per,b.sgst_amt,b.igst_per,b.igst_amt,b.ccessrate,b.compcess,a.Inv_no as RefNo,b.u_asseamt from Crmain	a
	Inner Join Critem b on (a.tran_cd=b.Tran_cd)
	Where a.tdspaytype=2
GO
