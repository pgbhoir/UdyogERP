DROP PROCEDURE [USP_ENT_GSTR2_Download]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [USP_ENT_GSTR2_Download]
@SDATE SMALLDATETIME,@EDATE SMALLDATETIME
AS
Begin 
	DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(4000)

	Select m.Entry_TY,m.tran_cd,[Date]=m.[Date],[RefNo]=m.Inv_No,[PartyName]=acm.Ac_Name,MailName=acm.MailName 
	--,[GST Transaction Type]=m.LC_IS_IC
	,[Total GST]=m.tot_examt,[Total Non-Taxable Chg.]=m.tot_nontax,[Final Discount]=m.tot_fdisc,m.net_amt
	,[CGST ITC]=ac.Amount
	--,[C GST ITC Adjusted]=ac.Amount
	,[SGST ITC]=ac.Amount
	--,[S GST ITC Adjusted]=ac.Amount
	,[IGST ITC]=ac.Amount
	--,[I GST ITC Adjusted]=ac.Amount
	--,[C_GST_PAID]=ac.Amount
	--,[S_GST_PAID]=ac.Amount
	--,[I_GST_PAID]=ac.Amount
	,CGST=ac.Amount
	,SGST=ac.Amount
	,IGST=ac.Amount
	,l.Code_Nm
	,SRNO=CONVERT(INT,0)
	,[ACGST]=ac.Amount
	,[ASGST]=ac.Amount
	,[AIGST]=ac.Amount
	,RefDt=m.date
	,m.Inv_sr,acm.gstin
	Into #gstavail
	From  vw_GST_Ac_Det ac  
	Inner Join Ac_Mast acl on (ac.Ac_id=acl.Ac_id)
	Inner Join vw_GST_Main m on (m.Entry_ty=ac.Entry_ty and m.Tran_cd=ac.Tran_cd)
	Inner Join ac_mast acm on (m.Ac_id=acm.Ac_id)
	Inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)
	Inner Join ptItem GI on (m.Entry_ty=GI.Entry_ty and m.Tran_cd=GI.Tran_cd)
	where 1=2
	
	SET @SQLCOMMAND='Insert Into #gstavail Select m.Entry_TY,m.tran_cd,[Date]=m.date,[Invoice No]=isnull(m.u_pinvno,m.Inv_No),[Party Name]=acm.Ac_Name,MailName=(case when isnull(acm.MailName,'''')='''' then acm.Ac_Name else acm.MailName end)'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[GST Transaction Type]=m.LC_IS_IC'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[Total GST]=m.tot_examt,[Total Non-Taxable Chg.]=m.tot_nontax,[Final Discount]=m.tot_fdisc,m.net_amt'   
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[CGST ITC]=Sum(Case When acl.ac_name=''Central GST Provisional A/C''  and ac.Amt_Ty=''Dr'' Then  ac.Amount Else 0 end)'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C GST ITC Adjusted]=0'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[SGST ITC]=Sum(Case When acl.ac_name=''State GST Provisional A/C'' and ac.Amt_Ty=''Dr'' Then  ac.Amount Else 0 end)'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[S GST ITC Adjusted]=0'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[IGST ITC]=Sum(Case When acl.ac_name=''Integrated GST Provisional A/C'' and ac.Amt_Ty=''Dr'' Then  ac.Amount Else 0 end)'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[I GST ITC Adjusted]=0'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C_GST_PAID]=Sum(Case When acl.Typ=''CGST Payable'' and ac.Amt_Ty=''CR'' Then  ac.Amount Else 0 end)'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[S_GST_PAID]=Sum(Case When acl.Typ=''SGST Payable'' and ac.Amt_Ty=''CR'' Then  ac.Amount Else 0 end)'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[I_GST_PAID]=Sum(Case When acl.Typ=''IGST Payable'' and ac.Amt_Ty=''CR'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',CGST=0,SGST=0,IGST=0'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',l.Code_Nm'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SRNO=(case When m.Entry_TY in (''PT'',''P1'') then 0 Else 1 End)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[ACGST] = ISNULL(GAL.ACGST,0),[ASGST] = ISNULL(GAL.ASGST,0),[AIGST] = ISNULL(GAL.AIGST,0) ,Inv_dt=Isnull(m.u_pinvdt,m.Date)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',m.Inv_sr,acm.gstin'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'From  vw_GST_Ac_Det ac'  
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join Ac_Mast acl on (ac.Ac_id=acl.Ac_id)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join vw_GST_Main m on (m.Entry_ty=ac.Entry_ty and m.Tran_cd=ac.Tran_cd)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join ac_mast acm on (m.Ac_id=acm.Ac_id)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN (Select G.Entry_ty,G.Tran_cd,[ACGST]=Sum(G.ACGST),[ASGST]=Sum(G.ASGST),[AIGST]=Sum(G.AIGST)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' from GSTALLOC G inner join vw_GST_Item GI on (G.Entry_ty=GI.Entry_ty and G.Tran_cd=GI.Tran_cd)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' group by G.Entry_ty,G.Tran_cd) GAL on (m.Entry_ty=GAL.Entry_ty and m.Tran_cd=GAL.Tran_cd)'	
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' WHERE acl.Typ Like  (''%GST Provisional%'') '
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'and m.[date] Between '+char(39)+cast(@SDATE as varchar)+CHAR(39)+' and '+char(39)+cast(@EDATE as varchar)+CHAR(39)
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' Group By m.Entry_TY,m.tran_cd,m.[Date],m.Inv_No,acm.Ac_Name,'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' (case when isnull(acm.MailName,'''')='''' then acm.Ac_Name else acm.MailName end),m.tot_examt,m.taxamt,'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' m.tot_nontax,m.tot_fdisc,m.net_amt,l.code_nm,GAL.ACGST,GAL.ASGST,GAL.AIGST,m.u_pinvno,m.u_pinvdt,m.Inv_sr,acm.gstin'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' Order By SRNO,M.Date,M.Entry_Ty'
	Print @SQLCOMMAND
	--,m.GSTACCMETH,m.LC_IS_IC
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

	Select [PartyName],GSTIN,Inv_Sr,[Supp_Bill_No]=RefNo,[Supp_Bill_Dt]=RefDt,[Trans. Amt]=net_amt ,[SGST ITC],[CGST ITC],[IGST ITC],Approved_Date='',CGST,SGST,IGST,[GST Comment]='' From #gstavail order by SRNO	
end
GO
