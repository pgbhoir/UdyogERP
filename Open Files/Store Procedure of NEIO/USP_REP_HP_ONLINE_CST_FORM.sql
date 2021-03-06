IF EXISTS(SELECT NAME,XTYPE From SysObjects Where xtype ='P' AND Name='USP_REP_HP_ONLINE_CST_FORM')
Begin
	Drop Procedure USP_REP_HP_ONLINE_CST_FORM
End


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_REP_HP_ONLINE_CST_FORM]
@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
AS

BEGIN
DECLARE @SQLCOMMAND NVARCHAR(4000)
	SELECT D.QTY,D.TAX_NAME,D.gro_amt,FORMTYPE =STM.FORM_NM
	,M.INV_NO,M.DATE
	,SELLER =(CASE WHEN ISNULL(AC.AC_NAME,'')='' THEN AC.MAILNAME ELSE AC.AC_NAME END)
	,SELLER_ADD =RTRIM(ISNULL(AC.add1,''))+' '+RTRIM(ISNULL(AC.ADD2,''))+' '+RTRIM(ISNULL(AC.ADD3,''))
	,STATE =ISNULL(AC.state,'')
	,TINNO=AC.C_TAX,ITEM=IT.IT_NAME,UNIT=IT.P_UNIT
	,PONO=(CASE WHEN M.U_PONO ='' THEN ISNULL(PTITREF.rinv_no,'') ELSE  M.U_PONO END)
	 ,PODATE=(CASE WHEN M.U_PODT ='' THEN PTITREF.RDATE  ELSE  M.U_PODT END)
	 ,taxableamt= CASE WHEN Lc.STAX_ITEM=1 THEN round(d.u_asseamt+D.EXAMT+D.U_CESSAMT+D.U_HCESAMT+d.tot_add+D.TOT_DEDUC,2) else round(((M.gro_amt+M.tot_add+M.tot_tax)-M.tot_deduc),2) end
	 ,D.TAXAMT
	 ,TOTAL= CASE WHEN Lc.STAX_ITEM=1 THEN round(d.u_asseamt+D.EXAMT+D.U_CESSAMT+D.U_HCESAMT+d.tot_add+D.TOT_DEDUC,2) else round(((M.gro_amt+M.tot_add+M.tot_tax)-M.tot_deduc),2) end + D.TAXAMT
	 ,PURPOSE =M.U_NT
	 ,OTHERS=(CASE WHEN ISNULL(CAST(IT.it_desc AS VARCHAR(MAX)),'')='' THEN  IT.IT_NAME ELSE CAST(IT.it_desc AS VARCHAR(MAX)) END)
	 ,RAIL_STEAMER =M.U_CHKPST
	 ,RAIL_POSTAL =M.U_LRNO
	 ,AIRLINE_NM =M.U_DELI
	 ,delivery_dt =(CASE WHEN YEAR(M.U_DELIDATE)<=1900 THEN NULL ELSE M.U_DELIDATE END)
	 ,ex_type =M.U_NT
	 ,noofconsig = M.U_NOOFCN 
	 ,rail_rec_dt =(CASE WHEN YEAR(M.U_LRDT)<=1900 THEN NULL ELSE M.U_LRDT END)
	 ,ag_orderno = M.U_AGORNO
	 ,ag_orderdt = (CASE WHEN YEAR(M.U_AGORDT)<=1900 THEN NULL ELSE M.U_AGORDT END)
	  into #RPT_HPCSTFRM FROM PTITEM D INNER JOIN PTMAIN M ON (D.TRAN_CD=M.TRAN_CD AND D.ENTRY_TY=M.ENTRY_TY)
	 INNER JOIN AC_MAST AC ON (M.Ac_id =AC.Ac_id )
	 INNER JOIN IT_MAST IT ON (D.It_code =IT.it_CODE)
	 INNER JOIN STAX_MAS STM ON(D.tax_name=STM.tax_name AND M.entry_ty =STM.entry_ty)
	 LEFT OUTER JOIN PTITREF  ON (D.TRAN_CD=PTITREF.TRAN_CD AND M.entry_ty =PTITREF.entry_ty AND D.ITSERIAL=PTITREF.ITSERIAL)
	 INNER JOIN  LCODE LC ON (M.ENTRY_TY = LC.ENTRY_TY)
	 WHERE STM.FORM_NM LIKE'%FORM%' AND AC.C_TAX <> '' AND AC.ST_TYPE='OUT OF STATE'  AND (M.DATE BETWEEN @SDATE AND @EDATE)
END
SELECT FORMTYPE,INV_NO,DATE,TINNO,SELLER_ADD,SELLER,STATE,ITEM,TAXABLEAMT,TAXAMT,TOTAL,PONO,PODATE,PURPOSE
,QTY,UNIT,OTHERS,RAIL_STEAMER,RAIL_POSTAL,AIRLINE_NM,DELIVERY_DT,EX_TYPE,NOOFCONSIG,RAIL_REC_DT,AG_ORDERNO,AG_ORDERDT FROM #RPT_HPCSTFRM


