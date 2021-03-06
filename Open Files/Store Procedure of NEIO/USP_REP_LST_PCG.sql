DROP PROCEDURE [USP_REP_LST_PCG]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate MONTHLY STATEMENT-STOCK LIST-CHAPTER-GROUP-ITEM WISE (Finished   goods) Report.
-- Modify date: 16/05/2007

-- Modified By: Dinesh S
-- Modify date: 15/09/2012
-- Remark: Resolve Joins and Added HCESAMT
--Modified By Kishor A. for Bug-26495 on 23/07/2015
-- =============================================

CREATE PROCEDURE [USP_REP_LST_PCG]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= null
AS
Set NoCount On

Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL
 ,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='STKL_VW_MAIN',@VITFILE='STKL_VW_ITEM',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SFLDNM VARCHAR(10)
DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(4000)

-->> Dinesh S. Correction : Added HCESAMT
--SELECT  STKL_VW_ITEM.ENTRY_TY,BEH=(CASE WHEN LCODE.BCODE_NM IS NOT NULL AND LCODE.BCODE_NM<>' ' THEN LCODE.BCODE_NM ELSE STKL_VW_ITEM.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.DOC_NO,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,STKL_VW_MAIN.[RULE] ,STITEM.U_ASSEAMT,STITEM.EXAMT,STITEM.U_CESSAMT
SELECT  STKL_VW_ITEM.ENTRY_TY,BEH=(CASE WHEN LCODE.BCODE_NM IS NOT NULL AND LCODE.BCODE_NM<>' ' THEN LCODE.BCODE_NM ELSE STKL_VW_ITEM.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.DOC_NO,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.dc_no,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,STKL_VW_MAIN.[RULE] ,STITEM.U_ASSEAMT
,STITEM.CGST_AMT,STITEM.SGST_AMT,STITEM.IGST_AMT			--Added by Shrikant S. on 26/04/2017 for GST
--,STITEM.EXAMT,STITEM.U_CESSAMT,STITEM.U_HCESAMT			--Commented by Shrikant S. on 26/04/2017 for GST
--<< Dinesh S. Correction : Added HCESAMT
INTO #TITEM FROM STKL_VW_ITEM 
INNER JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY)
INNER JOIN STITEM  ON (STKL_VW_ITEM.TRAN_CD=STITEM.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=STITEM.ENTRY_TY AND STKL_VW_ITEM.ITSERIAL=STITEM.ITSERIAL)
INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE)
INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_MAIN.AC_ID)
INNER JOIN LCODE  ON (STKL_VW_ITEM.ENTRY_TY=LCODE.ENTRY_TY)
WHERE 1=2

-->> Dinesh S. Correction : Added HCESAMT
--SET @SQLCOMMAND='INSERT INTO  #TITEM SELECT  STKL_VW_ITEM.ENTRY_TY,BEH=(CASE WHEN LCODE.BCODE_NM IS NOT NULL AND LCODE.BCODE_NM<>'+ CHAR(39)+' '+CHAR(39)+' THEN LCODE.BCODE_NM ELSE STKL_VW_ITEM.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.DOC_NO,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,STKL_VW_MAIN.[RULE],STITEM.U_ASSEAMT,STITEM.EXAMT,STITEM.U_CESSAMT '
SET @SQLCOMMAND='INSERT INTO  #TITEM SELECT  STKL_VW_ITEM.ENTRY_TY,BEH=(CASE WHEN LCODE.BCODE_NM IS NOT NULL AND LCODE.BCODE_NM<>'+ CHAR(39)+' '+CHAR(39)+' THEN LCODE.BCODE_NM ELSE STKL_VW_ITEM.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.DOC_NO,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.dc_no,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,STKL_VW_MAIN.[RULE],STITEM.U_ASSEAMT,STITEM.CGST_AMT,STITEM.SGST_AMT,STITEM.IGST_AMT'  
--,STITEM.EXAMT,STITEM.U_CESSAMT,STITEM.U_HCESAMT '
--<< Dinesh S. Correction : Added HCESAMT
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  FROM STKL_VW_ITEM '
-->> Dinesh S. Correction : Wrong joint between views
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' LEFT JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' LEFT JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY)'
--<< Dinesh S. Correction : Wrong joint between views
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' LEFT JOIN STITEM  ON (STKL_VW_ITEM.TRAN_CD=STITEM.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=STITEM.ENTRY_TY AND STKL_VW_ITEM.ITSERIAL=STITEM.ITSERIAL)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_MAIN.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  INNER JOIN LCODE  ON (STKL_VW_ITEM.ENTRY_TY=LCODE.ENTRY_TY)'

SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)

PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SELECT A.RATEUNIT,[GROUP],CHAPNO,
--OPBAL =sum(CASE WHEN A.BEH ='OS' AND  A.DATE<=@SDATE THEN A.QTY ELSE 0 END)+sum(CASE WHEN A.BEH NOT IN('OB') AND (A.PMKEY='+')AND  A.DATE<@SDATE THEN A.QTY ELSE 0 END)-sum(CASE WHEN A.BEH NOT IN('OB') AND (A.PMKEY='-')AND  A.DATE<@SDATE THEN A.QTY ELSE 0 END), Commented By Kishor A. for Bug-26495 on 23/07/2015
OPBAL =sum(CASE WHEN A.BEH ='OS' AND  A.DATE<=@SDATE THEN A.QTY ELSE 0 END)+sum(CASE WHEN A.BEH IN('OP') AND (A.PMKEY='+')AND  A.DATE<@SDATE THEN A.QTY ELSE 0 END)-sum(CASE WHEN A.BEH NOT IN('OP') AND (A.PMKEY='-')AND  A.DATE<@SDATE THEN A.QTY ELSE 0 END), --Added By Kishor A. for Bug-26495 on 23/07/2015
RQTY_OP=sum(CASE WHEN A.BEH ='OP' AND A.PMKEY='+' AND A.DATE>=@SDATE THEN A.QTY ELSE 0 END),
RQTY_OT=sum(CASE WHEN A.BEH<>'OP' AND A.PMKEY='+' AND A.DATE>=@SDATE THEN A.QTY ELSE 0 END),
IQTY_ST =sum(CASE WHEN A.BEH ='ST' AND (CGST_AMT+SGST_AMT+IGST_AMT)<>0 AND A.PMKEY='-'  AND A.DATE>=@SDATE  THEN A.QTY ELSE 0 END),
IAMT_ST =sum(CASE WHEN (A.BEH ='ST' AND (CGST_AMT+SGST_AMT+IGST_AMT)<>0 AND A.PMKEY='-' AND A.DATE>=@SDATE) THEN A.U_ASSEAMT ELSE 0 END),

-->> Dinesh S. Correction : To add HCES Amt
--EXAMT_ST =sum(CASE WHEN (A.BEH ='ST' AND A.[RULE] IN('MODVATABLE') AND EXAMT<>0 AND A.PMKEY='-' AND A.DATE>=@SDATE) THEN EXAMT+U_CESSAMT ELSE 0 END),
EXAMT_ST =sum(CASE WHEN (A.BEH ='ST'  AND (CGST_AMT+SGST_AMT+IGST_AMT)<>0 AND A.PMKEY='-' AND A.DATE>=@SDATE) THEN (CGST_AMT+SGST_AMT+IGST_AMT) ELSE 0 END),
-->> Dinesh S. Correction : To add HCES Amt

IQTY_STE =sum(CASE WHEN A.BEH ='ST' AND A.[RULE] IN('CT-1','CT-3','EOU EXPORT')   AND A.PMKEY='-'  AND A.DATE>=@SDATE  THEN A.QTY ELSE 0 END),
IAMT_STE =sum(CASE WHEN (A.BEH ='ST' AND A.[RULE] IN('CT-1','CT-3','EOU EXPORT')  AND A.PMKEY='-' AND A.DATE>=@SDATE) THEN A.U_ASSEAMT ELSE 0 END),
EXAMT_STE =sum(CASE WHEN (A.BEH ='ST' AND A.[RULE] IN('CT-1','CT-3','EOU EXPORT')  AND A.PMKEY='-' AND A.DATE>=@SDATE) THEN (A.CGST_AMT+A.SGST_AMT+A.IGST_AMT) ELSE 0 END),
IQTY_OT =sum(CASE WHEN  (A.CGST_AMT+A.SGST_AMT+A.IGST_AMT)=0 AND  A.PMKEY='-' AND  A.DATE>=@SDATE THEN A.QTY ELSE 0 END),
CLBAL =sum(CASE WHEN  A.PMKEY='+' THEN A.QTY ELSE 0 END)-sum(CASE WHEN  A.PMKEY='-'  and a.dc_no='' THEN A.QTY ELSE 0 END)
FROM #TITEM A
GROUP BY A.CHAPNO,A.[GROUP],A.RATEUNIT
ORDER BY A.CHAPNO,A.[GROUP],A.RATEUNIT

DROP TABLE #TITEM
Set NoCount OFF
GO
