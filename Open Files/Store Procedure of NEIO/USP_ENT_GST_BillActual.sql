DROP PROCEDURE [USP_ENT_GST_BillActual]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_ENT_GST_BillActual]
@EDATE SMALLDATETIME
AS
Begin 
	DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(4000)
print @EDATE
	Select m.Entry_TY,m.tran_cd,[Date]=m.[Date],[Invoice No]=m.Inv_No,[Party Name]=acm.Ac_Name,MailName=acm.MailName 
	--,[GST Transaction Type]=m.LC_IS_IC
	,[Total GST]=m.tot_examt,[Total Non-Taxable Chg.]=m.tot_nontax,[Final Discount]=m.tot_fdisc,m.net_amt
	,[C GST ITC]=ac.Amount
	,[C GST ITC Adjusted]=ac.Amount
	,[S GST ITC]=ac.Amount
	,[S GST ITC Adjusted]=ac.Amount
	,[I GST ITC]=ac.Amount
	,[I GST ITC Adjusted]=ac.Amount
	,[C_GST_PAID]=ac.Amount
	,[S_GST_PAID]=ac.Amount
	,[I_GST_PAID]=ac.Amount
	,l.Code_Nm
	,SRNO=CONVERT(INT,0)
	,[ACGST]=ac.Amount
	,[ASGST]=ac.Amount
	,[AIGST]=ac.Amount
	,[ACOMPCESS]=ac.amount
	,Inv_dt=m.date
	,m.inv_sr,acm.gstin
	,u_cldt=m.date
	,[C Cess ITC]=ac.amount
	,[C Cess Adjusted]=ac.Amount
	,[C_CESS_PAID]=ac.amount
	Into #gstavail
	From  vw_GST_Ac_Det ac  
	Inner Join Ac_Mast acl on (ac.Ac_id=acl.Ac_id)
	Inner Join vw_GST_Main m on (m.Entry_ty=ac.Entry_ty and m.Tran_cd=ac.Tran_cd)
	Inner Join ac_mast acm on (m.Ac_id=acm.Ac_id)
	Inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)
	Inner Join PTItem GI on (m.Entry_ty=GI.Entry_ty and m.Tran_cd=GI.Tran_cd)
	where 1=2
	
	SET @SQLCOMMAND='Insert Into #gstavail Select m.Entry_TY,m.tran_cd,[Date]=m.date,[Invoice No]=Isnull(m.pinvno,m.Inv_No),[Party Name]=acm.Ac_Name,MailName=(case when isnull(acm.MailName,'''')='''' then acm.Ac_Name else acm.MailName end)'
	--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[GST Transaction Type]=m.LC_IS_IC'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[Total GST]=m.tot_examt,[Total Non-Taxable Chg.]=m.tot_nontax,[Final Discount]=m.tot_fdisc,m.net_amt'   
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C GST ITC]=Sum(Case When acl.ac_name=''Central GST Provisional A/C'' and ac.Amt_Ty=''Dr'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C GST ITC Adjusted]=0'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[S GST ITC]=Sum(Case When acl.ac_name=''State GST Provisional A/C'' and ac.Amt_Ty=''Dr'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[S GST ITC Adjusted]=0'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[I GST ITC]=Sum(Case When acl.ac_name=''Integrated GST Provisional A/C'' and ac.Amt_Ty=''Dr'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[I GST ITC Adjusted]=0'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C_GST_PAID]=Sum(Case When acl.Ac_name=''Central GST Payable A/C'' and ac.Amt_Ty=''CR'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[S_GST_PAID]=Sum(Case When acl.Ac_name=''State GST Payable A/C'' and ac.Amt_Ty=''CR'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[I_GST_PAID]=Sum(Case When acl.Ac_name=''Integrated GST Payable A/C'' and ac.Amt_Ty=''CR'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',l.Code_Nm'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SRNO=(case When m.Entry_TY in (''GP'') then 0 Else 1 End)'
	---SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[ACGST] = ISNULL(GAL.ACGST,0),[ASGST] = ISNULL(GAL.ASGST,0),[AIGST] = ISNULL(GAL.AIGST,0) ,Inv_dt=Isnull(m.u_pinvdt,m.Date)' --- Commneted by suraj date on  02-12-2016 
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[ACGST] = ISNULL(GAL.ACGST,0),[ASGST] = ISNULL(GAL.ASGST,0),[AIGST] = ISNULL(GAL.AIGST,0) ,[ACOMPCESS]=ISNULL(GAL.ACOMPCESS,0) ,Inv_dt= (Case when year(isnull(m.pinvdt,1900)) <=1900 then  m.Date  else m.pinvdt end )' --- Added by suraj date on  02-12-2016 
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',m.Inv_sr,acm.gstin ,m.u_cldt'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C Cess ITC]=Sum(Case When acl.ac_name=''Compensation Cess Provisional A/C'' and ac.Amt_Ty=''Dr'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C Cess Adjusted]=0'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',[C_CESS_PAID]=Sum(Case When acl.Ac_name=''Compensation Cess Payable A/C'' and ac.Amt_Ty=''CR'' Then  ac.Amount Else 0 end)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'From  vw_GST_Ac_Det ac'  
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join Ac_Mast acl on (ac.Ac_id=acl.Ac_id)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join vw_GST_Main m on (m.Entry_ty=ac.Entry_ty and m.Tran_cd=ac.Tran_cd)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join ac_mast acm on (m.Ac_id=acm.Ac_id)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN (Select G.Entry_ty,G.Tran_cd,[ACGST]=Sum(G.ACGST),[ASGST]=Sum(G.ASGST),[AIGST]=Sum(G.AIGST),ACOMPCESS=sum(G.ACOMPCESS)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' from GSTALLOC G inner join vw_GST_main GI on (G.Entry_ty=GI.Entry_ty and G.Tran_cd=GI.Tran_cd)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' group by G.Entry_ty,G.Tran_cd) GAL on (m.Entry_ty=GAL.Entry_ty and m.Tran_cd=GAL.Tran_cd)'	
	---- SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' WHERE acl.Typ Like (''%GST Provisional%'') and m.[date] <= '+char(39)+cast(@EDATE as varchar)+CHAR(39)+' and m.entry_ty in (''BP'',''CP'',''PT'',''P1'',''E1'')'  --- Commented by Suraj Kumawat date on 24-03-2017 
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' WHERE (acl.Typ Like (''%GST Provisional%'') OR acl.Typ Like (''%Cess Provisional%'')) and m.u_cldt <= '+char(39)+cast(@EDATE as varchar)+CHAR(39)+'  and year(m.u_cldt) > 1900  and m.entry_ty in (''BP'',''CP'',''PT'',''P1'',''E1'')'  --- Added by Suraj Kumawat date on 24-03-2017 
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' Group By m.Entry_TY,m.tran_cd,m.[Date],m.Inv_No,acm.Ac_Name,'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' (case when isnull(acm.MailName,'''')='''' then acm.Ac_Name else acm.MailName end),m.tot_examt,m.taxamt,'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' m.tot_nontax,m.tot_fdisc,m.net_amt,l.code_nm,GAL.ACGST,GAL.ASGST,GAL.AIGST,GAL.ACOMPCESS,m.pinvdt,m.pinvno,m.Inv_sr,acm.gstin,m.u_cldt'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' Order By SRNO,M.Date,M.Entry_Ty'
	Print @SQLCOMMAND
	--,m.GSTACCMETH,m.LC_IS_IC
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

	Select * From #gstavail order by SRNO	
end
GO
