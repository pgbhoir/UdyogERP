DROP PROCEDURE [USP_REP_DAYBOOK]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Excise Duty Available Report.
-- Modify date: 16/05/2007
-- Modified By: Priyanka B for GST Bug-28248
-- Modified date: 22/06/2017
-- Remark:
-- =============================================

CREATE PROCEDURE [USP_REP_DAYBOOK]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
SET QUOTED_IDENTIFIER OFF
DECLARE @FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='a',@VITFILE='b',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN=@LYN
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000)




--SET @SQLCOMMAND='Select a.Date,a.Tran_Cd,a.Entry_ty,a.inv_no,a.inv_sr,a.net_amt,a.u_pinvno,b.qty,b.rate,b.gro_amt'  --Commented by Priyanka B on 22062017 for Bug-28248
SET @SQLCOMMAND='Select a.Date,a.Tran_Cd,a.Entry_ty,a.inv_no,a.inv_sr,a.net_amt,a.pinvno,b.qty,b.rate,b.gro_amt'  --Modified by Priyanka B on 22062017 for Bug-28248
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',b.it_code,b.itserial,convert(varchar(250),c.it_desc) as it_desc,c.it_name,c.rateUnit'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',d.ac_name,Ac_Name1=f.Ac_Name,e.Amount,e.Amt_Ty,g.code_nm'
--Birendra
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',a.Dept,a.cate' 
--Birendra
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'From Stkl_Vw_Main a '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'Left Join Stkl_Vw_Item b on (a.Tran_Cd=b.Tran_Cd and a.entry_ty=b.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'Left Join It_Mast c on (c.it_code=b.it_code)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'Inner Join Ac_Mast d on (a.Ac_Id=d.Ac_Id)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'Inner Join Lac_Vw e on (a.Entry_ty=e.Entry_ty and a.Tran_Cd=e.Tran_Cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'Inner Join Ac_Mast f on (e.Ac_Id=f.Ac_Id)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'Inner Join Lcode g on (g.ENTRY_TY=a.Entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ @FCON
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'Order by a.Date,a.Entry_Ty,a.Tran_Cd,a.Inv_No,b.itserial,(case when e.amt_ty=''DR'' Then ''A'' else ''B'' End)  '

PRINT @FCON
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
