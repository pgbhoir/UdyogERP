DROP PROCEDURE [Salesman_outstanding]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salesman_outstanding]
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
begin
	PRINT @sdate
	PRINT @edate
	
	SELECT EmployeeName,Target1,Target2,Comm1,Comm2 INTO #salesman FROM dbo.EmployeeMast WHERE SALTARGET=1

	SELECT stmain.SALESMAN,SUM(stmain.net_amt) AS 'ST_AMT' INTO #ST FROM dbo.STMAIN 
	WHERE stmain.date BETWEEN @sdate AND @edate 	
	GROUP BY stmain.salesman ORDER BY stmain.salesman 

	SELECT stmain.SALESMAN,SUM(stmall.new_all)+sum(stmall.disc) AS 'ST_BR_CR_AMT' INTO #STBRCR FROM dbo.STMAIN 	
	left JOIN dbo.sTmall on (sTmall.tran_cd=sTmain.tran_Cd)	 
	WHERE stmain.date BETWEEN @sdate AND @edate 
	GROUP BY stmain.salesman ORDER BY stmain.salesman 

	SELECT sbmain.SALESMAN,SUM(sbmain.net_amt) AS 'SB_AMT' INTO #Sb FROM dbo.SbMAIN 
	WHERE sbmain.date BETWEEN @sdate AND @edate 
	GROUP BY sbmain.salesman ORDER BY sbmain.salesman 

	SELECT sbmain.SALESMAN,SUM(sbmall.new_all)+sum(sbmall.disc) AS 'Sb_BR_CR_AMT' INTO #SbBRCR FROM dbo.SbMAIN 	
	left JOIN dbo.sbmall on (sbmall.tran_cd=sbmain.tran_Cd)	 
	WHERE sBmain.date BETWEEN @sdate AND @edate 
	GROUP BY sbmain.salesman ORDER BY sbmain.salesman 

	SELECT brmain.salesman,SUM(brmain.net_amt) AS 'BR_ADV' INTO #BR_ADV FROM brmain 
	WHERE brmain.date BETWEEN @sdate AND @edate AND brmain.tdspaytype=2
	GROUP BY brmain.salesman

	SELECT CRmain.salesman,SUM(CRmain.net_amt) AS 'CR_ADV' INTO #CR_ADV FROM Crmain 
	WHERE Crmain.date BETWEEN @sdate AND @edate AND Crmain.tdspaytype=2
	GROUP BY Crmain.salesman

	SELECT BRMAIN.SALESMAN,SUM(BRMALL.NEW_ALL)+sum(brmall.disc) AS BRRCVD INTO #BR_ST_AMT FROM BRMAIN 
	LEFT JOIN BRMALL ON (BRmall.tran_cd=BRmain.tran_Cd) 
	WHERE BRMAIN.TDSPAYTYPE=1 AND BRMAIN.DATE BETWEEN @sdate AND @edate AND BRMALL.ENTRY_ALL='ST' 
	GROUP BY Brmain.salesman

	SELECT BRMAIN.SALESMAN,SUM(BRMALL.NEW_ALL)+sum(brmall.disc) AS BRRCVD INTO #BR_SB_AMT FROM BRMAIN 
	LEFT JOIN BRMALL ON (BRmall.tran_cd=BRmain.tran_Cd) 
	WHERE BRMAIN.TDSPAYTYPE=1 AND BRMAIN.DATE BETWEEN @sdate AND @edate AND BRMALL.ENTRY_ALL='SB' 
	GROUP BY Brmain.salesman

	SELECT CRMAIN.SALESMAN,SUM(CRMALL.NEW_ALL)+sum(crmall.disc) AS CRRCVD INTO #CR_ST_AMT FROM CRMAIN 
	LEFT JOIN CRMALL ON (CRmall.tran_cd=CRmain.tran_Cd) 
	WHERE CRMAIN.TDSPAYTYPE=1 AND CRMAIN.DATE BETWEEN @sdate AND @edate AND CRMALL.ENTRY_ALL='ST' 
	GROUP BY Crmain.salesman

	SELECT CRMAIN.SALESMAN,SUM(CRMALL.NEW_ALL)+sum(crmall.disc) AS CRRCVD INTO #CR_SB_AMT FROM CRMAIN 
	LEFT JOIN CRMALL ON (CRmall.tran_cd=CRmain.tran_Cd) 
	WHERE CRMAIN.TDSPAYTYPE=1 AND CRMAIN.DATE BETWEEN @sdate AND @edate AND CRMALL.ENTRY_ALL='SB' 
	GROUP BY Crmain.salesman


	SELECT #salesman.*,
	ISNULL(#ST.ST_AMT,0) AS STINVAMT,
	ISNULL(#SB.SB_AMT,0) AS SBINVAMT,
	ISNULL(#STBRCR.ST_BR_CR_AMT,0)+ISNULL(#BR_ST_AMT.BRRCVD,0)+ISNULL(#CR_ST_AMT.CRRCVD,0) AS SALES_RCVD,
	ISNULL(#SBBRCR.SB_BR_CR_AMT,0)+ISNULL(#BR_SB_AMT.BRRCVD,0)+ISNULL(#CR_SB_AMT.CRRCVD,0) AS SERV_RCVD,
	ISNULL(#BR_ADV.BR_ADV,0)+ISNULL(#CR_ADV.CR_ADV,0) AS TOT_ADV,
	ISNULL(#BR_ADV.BR_ADV,0)+ISNULL(#CR_ADV.CR_ADV,0)-(ISNULL(#STBRCR.ST_BR_CR_AMT,0)+ISNULL(#SBBRCR.SB_BR_CR_AMT,0)) AS ADV_BAL,
	ISNULL(#ST.ST_AMT,0)-(ISNULL(#STBRCR.ST_BR_CR_AMT,0)+ISNULL(#BR_ST_AMT.BRRCVD,0)+ISNULL(#CR_ST_AMT.CRRCVD,0)) AS TOT_ST_BAL,
	ISNULL(#SB.SB_AMT,0)-(ISNULL(#SBBRCR.SB_BR_CR_AMT,0)+ISNULL(#BR_SB_AMT.BRRCVD,0)+ISNULL(#CR_SB_AMT.CRRCVD,0)) AS TOT_SB_BAL,
	ISNULL(#ST.ST_AMT,0)+ISNULL(#SB.SB_AMT,0)-(ISNULL(#STBRCR.ST_BR_CR_AMT,0)+ISNULL(#BR_ST_AMT.BRRCVD,0)+ISNULL(#CR_ST_AMT.CRRCVD,0)+ISNULL(#SBBRCR.SB_BR_CR_AMT,0)+ISNULL(#BR_SB_AMT.BRRCVD,0)+ISNULL(#CR_SB_AMT.CRRCVD,0)+ISNULL(#BR_ADV.BR_ADV,0)+ISNULL(#CR_ADV.CR_ADV,0))+(ISNULL(#STBRCR.ST_BR_CR_AMT,0)+ISNULL(#SBBRCR.SB_BR_CR_AMT,0)) as TOT_BAL
	FROM #salesman
	LEFT JOIN #ST ON #SALESMAN.EmployeeName=#ST.salesman
	LEFT JOIN #Sb ON #SALESMAN.EmployeeName=#SB.salesman
	LEFT JOIN #STBRCR ON #STBRCR.salesman=#ST.salesman
	LEFT JOIN #SbBRCR ON #SbBRCR.salesman=#SB.salesman
	LEFT JOIN #BR_ADV ON #SALESMAN.EmployeeName=#BR_ADV.salesman
	LEFT JOIN #CR_ADV ON #SALESMAN.EmployeeName=#CR_ADV.salesman
	LEFT JOIN #BR_ST_AMT ON #SALESMAN.EmployeeName=#BR_ST_AMT.salesman
	LEFT JOIN #BR_SB_AMT ON #SALESMAN.EmployeeName=#BR_SB_AMT.salesman
	LEFT JOIN #CR_ST_AMT ON #SALESMAN.EmployeeName=#CR_ST_AMT.salesman
	LEFT JOIN #CR_SB_AMT ON #SALESMAN.EmployeeName=#CR_SB_AMT.salesman
	

DROP TABLE #ST
DROP TABLE #Sb
DROP TABLE #STBRCR
DROP TABLE #SbBRCR
DROP TABLE #BR_ADV
DROP TABLE #CR_ADV
DROP TABLE #BR_ST_AMT
DROP TABLE #BR_SB_AMT
DROP TABLE #CR_ST_AMT
DROP TABLE #CR_SB_AMT

end 
--
--SET ANSI_NULLS Off
--
--set ANSI_NULLS Off
--go
--set QUOTED_IDENTIFIER Off
--go
--
--EXECUTE SALESMAN_OUTSTANDING'','','','10/29/2012','10/29/2012','','','','',0,0,'','','','','','','','','2012-2013',''
--
GO
