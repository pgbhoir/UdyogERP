If Exists (Select [Name] From SysObjects Where [Name]='SERVICE_BILLS_DADOS' and xtype='P')
Begin
	Drop Procedure SERVICE_BILLS_DADOS
End
Go
-- =============================================
-- Author:		Lokesh.
-- Create date: 25/04/2012
-- Description:	This Stored procedure is useful to generate Service Tax Bill/Accrual Basis Invoices.
-- Created date: 12/06/2012
-- Modified By: Shrikant S. on 15/04/2013 for Bug-12698	
-- Modify date: 
-- Remark:
-- =============================================


Create PROCEDURE [dbo].[SERVICE_BILLS_DADOS]
@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
As
Begin
select [entry_ty], [date], [dept] as [Department], [cate] as [Category], [party_nm] as [Party Name], [inv_no] as [Invoice Number]
, [l_yn] as [Fin Year], [due_dt] as [Due Date], [gro_amt] as [Gross Amount], [tot_deduc] as [Total Diductiions]
, [tot_add] as [Total Additions], [examt] as [Excise Amt], [taxamt] as [Tax Amt], [tax_name] as [Tax Name]
, [tot_tax] as [Total Tax], [net_amt] as [Net Amt], [narr] as Narration, [tot_nontax] as [Total Non Taxable Amt]
, [tot_fdisc] as [Final Discount], [form_nm] as [Form Name], [form_no] as [Form Num], [salesman], [user_name] as [User Name]
, [addamt] as [Additional Amt], [u_plasr] as [PLA Sr. No.], [u_rg23cno] as [RG23C Num], [u_rg23no] as [RG23A Num]
, [roundoff], [round_off], [rule], [CTID], [AREID], [tot_examt] as [Total Excise Amt], [u_cessamt] as [Cess Amt]
, [u_cessamta] as [CessAmtA], [u_cessamtc] as [CessAmtC], [u_cessamtp] as [CessAmtP], [Tran_cd] as [Transaction ID]
, [Ac_id] AS [Account ID], [abtper], [CompId], [ctno], [areno], [ctdate], [aredate], [ctdesc], [aredesc], [drawn_on] AS [Drawn On]
, [cheq_no] as [Cheque No.], [U_CVDAMTC] as [CVDAmtC], [U_BLDT] as [Bill Date], [U_BLNO] as [Bill Num], [u_deliver] as [Deliver]
, [u_vehno] as [Vehicle Num], [U_Pinvno] as [Pivno], [U_Pinvdt] as [Pivndt], [BATCHNO], [MFGDT], [EXPDT], [serty] AS [Service Tax Type]
, [sabtper], [u_remarks] as [Remarks], [u_chaldt] as [Challan Date], [U_CVDAMTA] as [CVDAmtA], [u_cvdamt] as [CVD Amt]
, [bond_no] as [Bond Num], [bopbal], [scons_id] AS [Ship To Consignor ID], [cons_id] as [Consignor ID], [serrule] AS [Service Tax Rule]
, [seravail], [serbamt], [SERBPER], [SERCPER], [SERCAMT], [SERHPER], [SERHAMT], [U_BROKER] as [Broker], [U_BROK_AMT] as [Broker Amt]
, [SABTAMT], [due_days] as [Due Days], [u_chalno] as [Challan Num]
FROM SBMAIN
WHERE SBMAIN.DATE>=@SDATE AND SBMAIN.DATE<=@EDATE
End

