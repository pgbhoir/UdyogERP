DROP PROCEDURE [USP_DTS_BANKRECO]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_DTS_BANKRECO] 
@SDATE  SMALLDATETIME
AS
SELECT A.AC_NAME,A.CL_DATE,A.ENTRY_TY,A.DATE,INV_NO =SPACE(10),A.CHEQ_NO,PARTY_NM=SUBSTRING(OAC_NAME,1,50),A.AMOUNT,A.CLAUSE,A.DOC_NO,A.TRAN_CD,DB='RE',AMT_TY INTO #USPBRECO1
FROM RECOSTAT A 
UNION
SELECT A.AC_NAME,A.CL_DATE,A.ENTRY_TY,A.DATE,B.INV_NO,B.CHEQ_NO,B.PARTY_NM,A.AMOUNT,A.CLAUSE,A.DOC_NO,A.TRAN_CD,DB='BP',AMT_TY   
FROM BPACDET A INNER JOIN BPMAIN B ON(A.TRAN_CD=B.TRAN_CD) INNER JOIN AC_MAST C ON(A.AC_ID=C.AC_ID) WHERE RTRIM(UPPER(C.TYP))='BANK'
UNION 
SELECT A.AC_NAME,A.CL_DATE,A.ENTRY_TY,A.DATE,B.INV_NO,B.CHEQ_NO,B.PARTY_NM,A.AMOUNT,A.CLAUSE,A.DOC_NO,A.TRAN_CD,DB='BR',AMT_TY 
FROM BRACDET A INNER JOIN BRMAIN B ON(A.TRAN_CD=B.TRAN_CD) INNER JOIN AC_MAST C ON(A.AC_ID=C.AC_ID) WHERE RTRIM(UPPER(C.TYP))='BANK'
UNION 
SELECT A.AC_NAME,A.CL_DATE,A.ENTRY_TY,A.DATE,B.INV_NO,B.CHEQ_NO,B.PARTY_NM,A.AMOUNT,A.CLAUSE,A.DOC_NO,A.TRAN_CD,DB='BR',AMT_TY 
FROM OBACDET A INNER JOIN OBMAIN B ON(A.TRAN_CD=B.TRAN_CD) INNER JOIN AC_MAST C ON(A.AC_ID=C.AC_ID) WHERE RTRIM(UPPER(C.TYP))='BANK'
UNION 
SELECT A.AC_NAME,A.CL_DATE,A.ENTRY_TY,A.DATE,B.INV_NO,B.CHEQ_NO,B.PARTY_NM,A.AMOUNT,A.CLAUSE,A.DOC_NO,A.TRAN_CD,DB='JV',AMT_TY 
FROM JVACDET A INNER JOIN JVMAIN B ON(A.TRAN_CD=B.TRAN_CD) INNER JOIN AC_MAST C ON(A.AC_ID=C.AC_ID) WHERE RTRIM(UPPER(C.TYP))='BANK'

SELECT AC_NAME,
ACLBAL=SUM(CASE WHEN DATE<=@SDATE AND DB<>'RE'  THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),
TDR=SUM(CASE WHEN (ENTRY_TY<>'OB' AND AMT_TY='DR' AND DATE<=@SDATE  AND (YEAR(CL_DATE)<=1900 OR CL_DATE IS NULL OR CL_DATE>@SDATE) ) THEN AMOUNT  ELSE 0  END ),
TCR=SUM(CASE WHEN (ENTRY_TY<>'OB' AND AMT_TY='CR' AND DATE<=@SDATE  AND (YEAR(CL_DATE)<=1900 OR CL_DATE IS NULL OR CL_DATE>@SDATE) ) THEN AMOUNT  ELSE 0  END ) 
INTO #USPBRECO2 
FROM #USPBRECO1  
GROUP BY AC_NAME 

INSERT  INTO RECOSTAT (AC_NAME,CL_DATE,ENTRY_TY,DATE,AMOUNT,AMT_TY,CHEQ_NO,CLAUSE,DOC_NO,TRAN_CD)  SELECT AC_NAME,@SDATE,ENTRY_TY='OB',@SDATE,ABS(ACLBAL+TCR-TDR),AMT_TY=(CASE WHEN (ACLBAL+TCR-TDR)>0 THEN 'DR' ELSE 'CR' END),' ',' ',' ',99999  FROM #USPBRECO2
GO
