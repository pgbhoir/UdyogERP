DROP PROCEDURE [USP_STKRESRV_GOODSINSTOCK]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- PROCEDURE NAME		   : USP_STKRESRV_GOODSINSTOCK
-- PROCEDURE DESCRIPTION   : USED TO GET GOODS IN STOCK DETAILS IN STOCK RESERVATION MODULE
-- MODIFIED DATE/BY/REASON : Sachin N. S. on 27/02/2014 for Bug-21381
-- REMARK				   : 
-- ==========================================================
CREATE PROCEDURE [USP_STKRESRV_GOODSINSTOCK]
@SPCond VARCHAR(4000)
AS
Declare @SQLCOMMAND as NVARCHAR(4000)
Declare @TMPTBLSO as VARCHAR(50),@TMPTBLOP as VARCHAR(50),@TRANTY as VARCHAR(50)
Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50),@TBLNAME2 as VARCHAR(50),@TBLNAME3 as VARCHAR(50)

Select * Into #Tmp1 from USP_ENT_SPLITCOND(@SPCond)
Select Top 1 @TMPTBLSO = SVal From #Tmp1 Where SCond = 'TMPTBLSO'
Select Top 1 @TMPTBLOP = SVal From #Tmp1 Where SCond = 'TMPTBLOP'
Select Top 1 @TRANTY = SVal From #Tmp1 Where SCond = 'TRANTY'


Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM
Set @TBLNAME2 = '##TMP2'+@TBLNM
Set @TBLNAME3 = '##TMP3'+@TBLNM

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT It_code Into '+@TBLNAME1+' From '+@TMPTBLSO+' Group by It_code' 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT a.Entry_ty,a.Tran_cd,a.ItSerial,a.It_code,b.Inv_no,b.Date,a.BatchNo,a.MfgDt,a.ExpDt
	,a.Qty,a.Qty as TotAlloc,a.Qty as BalQty,a.Qty as Allocate,c.Code_nm,a.Ware_nm,a.Dc_No
	INTO '+@TBLNAME2+' FROM STKL_VW_ITEM a
	Inner Join STKL_VW_MAIN b on a.Entry_ty = b.Entry_ty And a.Tran_cd = b.Tran_cd 
	Inner Join Lcode c on a.Entry_ty = c.Entry_ty And c.Inv_Stk = ''+'' 
	Inner Join '+@TBLNAME1+' d on a.It_code = d.It_code'
--,a.Qty,a.Qty as TotAlloc,a.Qty as BalQty,a.Qty as Allocate,c.Code_nm	-- Changed by Sachin N. S. on 27/02/2104 for Bug-21381
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set TotAlloc = 0,BalQty = 0,Allocate = 0'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select *  INTO '+@TMPTBLOP+
	' From StkResrvDet Where It_code in (Select It_code From '+@TMPTBLSO+') 
	and Entry_ty not in (select entry_ty from lcode where entry_ty in (''PO'',''WK'') or bcode_nm in (''PO'',''WK'') )'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select Entry_ty,Tran_cd,Itserial,Sum(AllocQty) As TotAlloc INTO '+@TBLNAME3+
	' From '+@TMPTBLOP+' Group by Entry_ty,Tran_cd,Itserial'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set TotAlloc = b.TotAlloc From '+@TBLNAME2+' a,'+@TBLNAME3+' b 
	Where  a.Entry_ty = b.Entry_ty and a.Tran_cd = b.Tran_cd and a.ItSerial = b.ItSerial'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set BalQty = Qty - (TotAlloc + Allocate)'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Drop Table  '+@TBLNAME3
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select * From  '+@TBLNAME2+' order by date,itserial'
EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
