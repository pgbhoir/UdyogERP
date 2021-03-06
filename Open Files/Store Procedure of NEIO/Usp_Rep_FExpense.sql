DROP PROCEDURE [Usp_Rep_FExpense]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Ajay Jaiswal
-- Create date: 22/12/2011
-- Description:	This Stored procedure is useful to Generate data for reports related to Foreign Expenses Document transaction.
-- =============================================

CREATE PROCEDURE    [Usp_Rep_FExpense]
@ENTRYCOND NVARCHAR(254)
	AS
DECLARE @SQLCOMMAND AS NVARCHAR(4000),@TBLCON AS NVARCHAR(4000)
	
	--->ENTRY_TY AND TRAN_CD SEPARATION
		DECLARE @ENT VARCHAR(2),@TRN INT,@POS1 INT,@POS2 INT,@POS3 INT
		
		PRINT @ENTRYCOND
		SET @POS1=CHARINDEX('''',@ENTRYCOND,1)+1
		SET @ENT= SUBSTRING(@ENTRYCOND,@POS1,2)
		SET @POS2=CHARINDEX('=',@ENTRYCOND,CHARINDEX('''',@ENTRYCOND,@POS1))+1
		SET @POS3=CHARINDEX('=',@ENTRYCOND,CHARINDEX('''',@ENTRYCOND,@POS2))+1
		SET @TRN= SUBSTRING(@ENTRYCOND,@POS2,@POS2-@POS3)
		SET @TBLCON=RTRIM(@ENTRYCOND)
PRINT @ENT
PRINT @TRN

SELECT 
EPMAIN.ENTRY_TY,EPMAIN.Tran_cd,EPMAIN.INV_NO,EPMAIN.CHEQ_NO,EPMAIN.INV_SR,EPMAIN.DATE,EPMAIN.USER_NAME,EPMAIN.NET_AMT
,EPMAIN.u_EXPENSE,EPMAIN.U_BANK,EPMAIN.U_VBANK,EPMAIN.U_BKADD,EPMAIN.U_IBANCODE,EPMAIN.U_SWIFTCOD
,EPMAIN.U_BK_AC_NO,EPMAIN.FCEXRATE,EPMAIN.U_DT_OF_RE,EPMAIN.U_16CLAU,EPMAIN.U_CANAME,EPMAIN.U_CAMEMNO
,EPMAIN1.PINVNO,EPMAIN1.PINVDT,CURR_MAST.CURRENCYCD as u_corren,EPMAIN.U_COMACNO,EPMAIN.U_FCPURP
,CONVERT(VARCHAR(254),CAST(EPMAIN.NARR AS VARCHAR(4000))) AS MNARR,EPMAIN.U_12AC,EPMAIN.U_CERTNO,EPMAIN.FCGRO_AMT
,EPITREF.rinv_no,IT_MAST.IT_NAME,EPITEM.GRO_AMT,EPITEM.ITEM_NO,EPMAIN.U_IDBEN,EPMAIN.U_IDBADD,EPMAIN.U_ITCHQ,EPMAIN.U_IFCNOT
,AC_MAST.AC_NAME AS AC_NAME1,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.PHONE,ac_mast.country,AC_MAST.EMAIL
,MAILNAME=(CASE WHEN ISNULL(AC_MAST.MAILNAME,'')='' THEN AC_MAST.AC_NAME ELSE AC_MAST.MAILNAME END) 
,AC_MAST1.ADD1 AS ADD11 ,AC_MAST1.ADD2 AS ADD12 ,AC_MAST1.CITY AS CITY1 ,AC_MAST1.ZIP AS ZIP1 ,AC_MAST1.COUNTRY AS BCOUNTRY
,AC_MAST1.ADD3 AS ADD13,AC_MAST1.CONTACT AS CONTACT1
FROM EPMAIN 
INNER JOIN EPITREF ON EPMAIN.TRAN_CD=EPITREF.TRAN_CD and EPMAIN.ENTRY_TY = EPITREF.ENTRY_TY 
INNER JOIN EPMAIN EPMAIN1 ON EPMAIN1.TRAN_CD=EPITREF.ITREF_TRAN
INNER JOIN EPITEM ON EPITEM.TRAN_CD=EPITREF.TRAN_CD and EPITEM.ITSERIAL = EPITREF.ITSERIAL
INNER JOIN AC_MAST ON (AC_MAST.AC_ID=EPMAIN.AC_ID)
INNER JOIN IT_MAST ON (IT_MAST.IT_CODE=EPITREF.IT_CODE)
INNER JOIN AC_MAST AC_MAST1 ON EPMAIN.U_BANK=AC_MAST1.AC_NAME
LEFT JOIN CURR_MAST ON (EPMAIN.FCID=CURR_MAST.CURRENCYID)
WHERE  EPMAIN.ENTRY_TY='FD' and EPMAIN.tran_cd=@TRN

--EXECUTE [Usp_Rep_FExpense] 'EPMAIN.ENTRY_TY=''FD'' AND EPMAIN.TRAN_CD=107'
GO
