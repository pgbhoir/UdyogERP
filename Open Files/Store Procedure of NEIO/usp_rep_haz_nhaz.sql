DROP PROCEDURE [usp_rep_haz_nhaz]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Priyanka Himane
-- Create date: 14/12/2011
-- Description:	This Stored procedure is useful to Generate data for Hazardous & Non-Hazardous Report.
-- Modified By: 
-- Modified date: 
-- =============================================

CREATE PROCEDURE    [usp_rep_haz_nhaz]
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

		SELECT STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE,STMAIN.U_PONO,STMAIN.U_PODT,
		STMAIN.U_LOADING, STMAIN.u_TMODE,STMAIN.U_PORT,STMAIN.U_PKGNO,STMAIN.U_CSEAL,STMAIN.U_TSEAL,
		STMAIN.U_COUNTAIN
		INTO #TBL1
		FROM STMAIN
		WHERE STMAIN.ENTRY_TY= @ENT  AND STMAIN.TRAN_CD=@TRN
		ORDER BY STMAIN.INV_NO


		SELECT STITEM.ENTRY_TY,STITEM.TRAN_CD,STITEM.ITEM,STITEM.RATE,STITEM.FCRATE,IT_MAST.IT_NAME,IT_MAST.EIT_NAME,
		IT_MAST.IT_ALIAS,(CAST(IT_MAST.IT_DESC AS VARCHAR(200))) AS [DESC],
		QTY = (SUM(STITEM.QTY)), GROAMT = CAST('0' AS NUMERIC(15,2)), STITEM.U_EXPNWT,
		IT_MAST.U_CNAME,IT_MAST.CHAPNO,STITEM.U_CORRU,IT_MAST.U_HDETAIL
		INTO #TBL2
		FROM STITEM
		INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE)
		WHERE STITEM.ENTRY_TY= @ENT  AND STITEM.TRAN_CD=@TRN
		GROUP BY STITEM.ENTRY_TY,STITEM.TRAN_CD,STITEM.ITEM,STITEM.RATE,STITEM.FCRATE,IT_MAST.IT_NAME,IT_MAST.EIT_NAME,
		IT_MAST.IT_ALIAS,(CAST(IT_MAST.IT_DESC AS VARCHAR(200))),IT_MAST.U_HDETAIL,
		STITEM.U_EXPNWT,IT_MAST.U_CNAME,IT_MAST.CHAPNO,STITEM.U_CORRU
		
		UPDATE #TBL2 SET GROAMT = QTY*FCRATE

	SELECT A.*,B.IT_NAME,B.[DESC],B.FCRATE,B.QTY,b.u_hdetail,B.U_EXPNWT,B.U_CNAME,B.CHAPNO,B.U_CORRU
	FROM #TBL1 A INNER JOIN #TBL2 B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD)
GO
