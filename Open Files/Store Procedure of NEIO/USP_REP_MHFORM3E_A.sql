IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name ='USP_REP_MHFORM3E_A' AND XTYPE='p' )
BEGIN
	DROP PROCEDURE USP_REP_MHFORM3E_A
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXECUTE USP_REP_MHFORM3E_A '','','','05/24/2016','10/24/2017','','','','',0,0,'','','','','','','','','2016-2017',''
*/

create PROCEDURE [dbo].[USP_REP_MHFORM3E_A]
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

BEGIN
DECLARE @FCON AS NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON 

@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE=Null,@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)
DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #MHFORM_3E
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #MHFORM_3E add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #MHFORM3E_A
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)

EXECUTE USP_REP_SINGLE_CO_DATA_VAT 
@TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
,@MFCON = @MCON OUTPUT
----==============================================================================================

-----------------------------------------------------------
select * into #vattupcd_tbl  from 
(select VATTYPECD,entry_ty,tran_cd,U_IMPORM from stmain WHERE ( DATE BETWEEN @SDATE AND @EDATE)
union all
select VATTYPECD,entry_ty,tran_cd ,U_IMPORM from srmain WHERE ( DATE BETWEEN @SDATE AND @EDATE)
union all
select VATTYPECD,entry_ty,tran_cd ,U_GPRICE  from cnmain WHERE ( DATE BETWEEN @SDATE AND @EDATE)
union all
select VATTYPECD,entry_ty,tran_cd,U_GPRICE  from dnmain WHERE ( DATE BETWEEN @SDATE AND @EDATE)
union all
select VATTYPECD,entry_ty,tran_cd,U_IMPORM  from ptmain WHERE ( DATE BETWEEN @SDATE AND @EDATE)
union all
select VATTYPECD,entry_ty,tran_cd ,U_IMPORM  from prmain WHERE ( DATE BETWEEN @SDATE AND @EDATE))a
------------------------------------------------------------

----------Temporary table for Sales Annexure data ---------------
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=M.TAXAMT,AMT5=M.TAXAMT,AMT6=M.TAXAMT,AMT7=M.TAXAMT,
AMT8=M.TAXAMT,AMT9=M.TAXAMT,M.INV_NO,M.DATE,Tran_cd=SPACE(5),Tran_Desc=SPACE(200),RAction = SPACE(50),Ret_Frm_no = SPACE(25),
AC1.S_TAX INTO #MHSL_CST2Temp FROM PTACDET A INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID) WHERE 1=2
Insert into #MHSL_CST2Temp EXECUTE USP_REP_MH_SALESANNEX '','','',@sdate,@edate,'','','','',0,0,'','','','','','','','','2015-2016','' 
-----------------------------------------------------------------------------
--->PART 1-5 
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

---PART 1
---1 Gross Turnover of Sales
-- A =ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,{"231","232","233","234","235","CST"})),0)

	SET @AMTA1 = 0
	SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no IN ('231','232','233','234','235','CST') 
	
-- B =ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,{"<>CST"},'Sales Annexure'!P:P,{"600","680","690","700","780","790"})),0)

	SET @AMTA2  = 0
	SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no <> 'CST' AND Tran_cd IN('600','680','690','700','780','790')

-- C =ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"600","610","620","630","640","650","660","670","680","700","710","720","730","740","750","760","770","780"})),0)
	SET @AMTB1   = 0
	SELECT @AMTB1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no = 'CST' AND Tran_cd IN('600','610','620','630','640','650','660','670','680','700','710','720','730','740','750','760','770','780')
--- Sales Turnover 
SET @AMTB2 = 0
SET @AMTB2 = round((@AMTA1)-(@AMTA2 + @AMTB1),0)
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','A1',0,round(@AMTB2,0),0,0,'','','','','','')

--1A Less:-Turnover of Sales within the State
---A =ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,{"231","232","233","234","235"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no IN ('231','232','233','234','235')
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,{"<>CST"},'Sales Annexure'!P:P,{"600","680","690","700","780","790"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no <> 'CST'  and Tran_cd in('600','680','690','700','780','790')
---
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX)
			   VALUES (1,'1','A2',0,round((@AMTA1-@AMTA2),0) ,0,0,'','','','','','')

---1B Less:-Turnover of Sales of Goods outside the State
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"910")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd ='910'
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"610","710"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('610','710')

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','B',0,ROUND((@AMTA1-@AMTA2),0),0,0,'','','','','','')

---1C	Less:-Value ( inclusive of sales tax) of Goods Return u/s 8A(1)(b)
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"600","610","620","630","640","650","660","670","680"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('600','610','620','630','640','650','660','670','680')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','C',0,round(@AMTA1,0),0,0,'','','','','','')
--1D Less:- Credit Note , price on account of rate difference and discount
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"700","710","720","730","740","750","760","770","780"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('700','710','720','730','740','750','760','770','780')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','D',0,round(@AMTA1,0),0,0,'','','','','','')

---1E	Less:- Sales of the goods in the course of export out of India (Direct Export)
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"950")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('950')
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"650","750"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('650','750')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','E',0,ROUND((@AMTA1 - @AMTA2),0),0,0,'','','','','','')

--1F	Less:- Sales of the goods in the course of export out of India (Export Against Form-H)
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"940")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('940')
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"640","740"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('640','740')

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX)
			   VALUES (1,'1','F',0,ROUND(@AMTA1- @AMTA2,0),0,0,'','','','','','')
--1G	Less:-Sales of the goods in the course of import into India
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"960")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('960')
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"660","760"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('660','760')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','G',0,ROUND(@AMTA1 - @AMTA2,0),0,0,'','','','','','')

---1H Less:- Value of goods transferred u/s 6A (1) of C.S.T. Act, 1956
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"300")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('300')
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"680","780"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('680','780')
--
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','H',0,ROUND(@AMTA1 - @AMTA2,0),0,0,'','','','','','')
---1I Less:- Turnover of interstate sales u/s 6(3) of C.S.T. Act, 1956.
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"930")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('930')
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"630","730"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('630','730')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','I',0,ROUND(@AMTA1 - @AMTA2,0),0,0,'','','','','','')
---1J			Less:- Turnover of sales of goods fully exempted from tax under section 8(5) read with 8(4) of MVAT ACT, 2002
--=ROUND(SUM(SUMIFS('Sales Annexure'!J:J,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"500")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT6),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('500')
--=ROUND(SUM(SUMIFS('Sales Annexure'!J:J,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"600","700"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT6),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('600','700')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX)
			   VALUES (1,'1','J',0,ROUND(@AMTA1 - @AMTA2,0),0,0,'','','','','','')
---2 Balance :- Inter-State sales on which tax is leviable in Maharashtra State ( 1- 1A-1B-1C-1D-1E-1F-1G-1H-1I-1J)
SET @AMTA1 = 0
SET @AMTA2 = 0
SET @AMTB1 = 0
SELECT @AMTA1=ISNULL(Sum(AMT1),0) FROM #MHFORM3E_A where Partsr = '1' and srno = 'A1'
SELECT @AMTA2=ISNULL(Sum(AMT1),0) FROM #MHFORM3E_A where Partsr = '1' and srno In('A2','B','C','D','E','F','G','H','I','J')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1 = @AMTA1 - @AMTA2
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','K1',0,round(@AMTB1,0),0,0,'','','','','','')

---2A Less:-Cost of freight , delivery or installation , if separately charged
---=ROUND(SUM(SUMIFS('Sales Annexure'!L:L,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"100","200","900","500"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT8),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('100','200','900','500')
---=ROUND(SUM(SUMIFS('Sales Annexure'!L:L,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"600","700"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT8),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('600','700')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','K2',0,round(@AMTA1-@AMTA2,0),0,0,'','','','','','')
--2B Less:-Cost of Labour, if separately charged 
--=ROUND(SUM(SUMIFS('Sales Annexure'!K:K,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"100","200","900","500"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT7),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('100','200','900','500')
---=ROUND(SUM(SUMIFS('Sales Annexure'!K:K,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"600","700"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT7),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('600','700')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','K3',0,round(@AMTA1-@AMTA2,0),0,0,'','','','','','')
			   
--2C	Less:-Turnover of interstate sales on which no tax is payable
---=ROUND(SUM(SUMIFS('Sales Annexure'!I:I,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"100","200","900","500"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT5),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('100','200','900','500')
---=ROUND(SUM(SUMIFS('Sales Annexure'!J:J,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"100","200","900","500"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT6),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('100','200','900','500')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','K4',0,round(@AMTA1-@AMTA2,0),0,0,'','','','','','')
--2D Less:-Turnover of interstate sales u/s 6(2)
--=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"920")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('920')
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"620","720"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('620','720')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','K5',0,round(@AMTA1-@AMTA2,0),0,0,'','','','','','')
---2E	Less:-Turnover of interstate sales u/s 8(6)
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,"970")),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('970')
---=ROUND(SUM(SUMIFS('Sales Annexure'!M:M,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"670","770"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT9),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('670','770')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','K6',0,round(@AMTA1-@AMTA2,0),0,0,'','','','','','')

--3 Balance :-Total Taxable interstate sales ( 2- 2A-2B-2C-2D-2E)
set @AMTA1 = 0
set @AMTA2 = 0
set @AMTB1 = 0
SELECT @AMTA1=isnull(Sum(AMT1),0) FROM #MHFORM3E_A where Partsr = '1' and srno = 'K1'
SELECT @AMTA2=isnull(Sum(AMT1),0) FROM #MHFORM3E_A where Partsr = '1' and srno In('K2','K3','K4','K5','K6')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1 = @AMTA1 - @AMTA2
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX)
			   VALUES (1,'1','L1',0,round(@AMTB1,0),0,0,'','','','','','')
--3A Less:- Total Value in which tax is not collected seperatly ( Inclusive of Tax with gross Amount )
---=ROUND(SUM(SUMIFS('Sales Annexure'!G:G,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"100","200","900"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT3),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('100','200','900')
---=ROUND(SUM(SUMIFS('Sales Annexure'!G:G,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"600","700"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT3),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('600','700')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','L2',0,round(@AMTA1-@AMTA2,0),0,0,'','','','','','')
			   
--3B	Less:-Deduction u/s 8A(1)(a)
---=ROUND(SUM(SUMIFS('Sales Annexure'!F:F,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"100","200","900"})),0)
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT2),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('100','200','900')
--=ROUND(SUM(SUMIFS('Sales Annexure'!F:F,'Sales Annexure'!O:O,"CST",'Sales Annexure'!P:P,{"600","700"})),0)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT2),0) FROM #MHSL_CST2Temp WHERE Ret_Frm_no ='CST' AND Tran_cd IN ('600','700')
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','L3',0,ROUND(@AMTA1 -@AMTA2,0) ,0,0,'','','','','','')

--4	 Net Taxable interstate sales ( 3- 3A-3B)
SET @AMTA1 = 0
SET @AMTA2 = 0
SET @AMTB1 = 0
SELECT @AMTA1=ISNULL(Sum(AMT1),0) FROM #MHFORM3E_A where Partsr = '1' and srno = 'L1'
SELECT @AMTA2=ISNULL(Sum(AMT1),0) FROM #MHFORM3E_A where Partsr = '1' and srno In('L2','L3')
SET @AMTB1 = @AMTA1 - @AMTA2
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'1','M',0,round(@AMTB1,0),0,0,'','','','','','')
--- A. Sales Taxable U/s. 8 (1)
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
----------------------
SELECT DISTINCT  A.PER,B.U_IMPORM,A.BHENT,A.TRAN_CD,ENTRY_TY,A.TAX_NAME,A.VATONAMT 
,A.TAXAMT INTO #VATTBL_CST  FROM vattbl A INNER JOIN #vattupcd_tbl B ON A.BHENT =B.entry_ty AND A.TRAN_CD = B.Tran_cd
where A.bhent IN('ST','SR','CN')  AND A.ST_TYPE ='OUT OF STATE' AND A.TAX_NAME not like '%VAT%'
AND B.VATTYPECD <> '' AND B.U_IMPORM  IN('Under section 8(5)','Under section 8(1)') AND ( A.DATE BETWEEN @SDATE AND @EDATE)
---------------------
 DECLARE  CUR_FORM221 CURSOR FOR 
 select distinct level1 from stax_mas where ST_TYPE='OUT OF STATE' And  level1 > 0 AND ac_name1 not like '%VAT%'
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	SET @NetEFF = 0
	Set @NetTAX  = 0
 	SELECT @AMTA1=ISNULL(SUM(CASE WHEN A.BHENT = 'ST' THEN  +A.VATONAMT ELSE -A.VATONAMT END),0)
	,@AMTA2=ISNULL(SUM(CASE WHEN A.BHENT ='ST' THEN  +A.TAXAMT ELSE -A.TAXAMT END),0) FROM #VATTBL_CST A  WHERE A.BHENT IN('ST','SR','CN')  AND  A.U_IMPORM ='Under section 8(1)' AND A.PER =@PER
  --Net Effect
	Set @NetEFF = ROUND(@AMTA1,0)
	Set @NetTAX = ROUND(@AMTA2,0)
	 if @nettax <> 0
	  begin
		  INSERT INTO #MHFORM3E_A
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'2','A',@PER,round(@NETEFF,0),round(@NETTAX,0),0,'')
		  
		  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
	  end
	FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221
if not exists(select top 1 srno from #MHFORM3E_A where part=1 and PARTSR ='2' and SRNO ='A')
begin
  INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'2','A',0,0,0,0,'')
end 

---Total 
 INSERT INTO #MHFORM3E_A
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'2','Z',0,@AMTJ1,@AMTK1,0,'')

---  B. Sales Taxable U/s. 8 (2) {Tax Collected Separetaly}
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'3','A',0,0,0,0,'','','','','','')


---C. Sales Taxable U/s. 8 (2) {Inclusive of Tax}																											
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'3A','A',0,0,0,0,'','','','','','')

-- D. Sales Taxable U/s. 8 (5)
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
---------------------
 DECLARE  CUR_FORM221 CURSOR FOR 
 select distinct level1 from stax_mas where ST_TYPE='OUT OF STATE' And  level1 > 0 AND ac_name1 not like '%VAT%'
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	SET @NetEFF = 0
	Set @NetTAX  = 0
 	SELECT @AMTA1=ISNULL(SUM(CASE WHEN A.BHENT = 'ST' THEN  +A.VATONAMT ELSE -A.VATONAMT END),0)
	,@AMTA2=ISNULL(SUM(CASE WHEN A.BHENT ='ST' THEN  +A.TAXAMT ELSE -A.TAXAMT END),0) FROM #VATTBL_CST A  WHERE A.BHENT IN('ST','SR','CN')  AND  A.U_IMPORM ='Under section 8(5)' AND A.PER =@PER
  --Net Effect
	Set @NetEFF = ROUND(@AMTA1,0)
	Set @NetTAX = ROUND(@AMTA2,0)
	 if @nettax <> 0
	  begin
		  INSERT INTO #MHFORM3E_A
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'4','A',@PER,round(@NETEFF,0),round(@NETTAX,0),0,'')
		  
		  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
	  end
	FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221

---Total 
if not exists(select top 1 srno from #MHFORM3E_A where part=1 and PARTSR ='4' and SRNO ='A')
begin
  INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'4','A',0,0,0,0,'')
end 

 INSERT INTO #MHFORM3E_A
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'4','Z',0,@AMTJ1,@AMTK1,0,'')

--5	Tax collected in excess of the tax payable ( 3B - total tax 4( A+B+D) if positive
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #MHFORM3E_A  WHERE PART = 1 AND PARTSR ='1' AND SRNO ='L3'
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT2),0) FROM #MHFORM3E_A  WHERE PART = 1 AND PARTSR IN('2','4') AND SRNO ='A'
SET @AMTB1 = ROUND(@AMTA1 - @AMTA2,0)
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','A',0,(CASE WHEN @AMTB1 > 0 THEN round(@AMTB1,0) ELSE 0 END ),0,0,'','','','','','')
--6 Total Amount of C.S.T Payable ( Total tax 4( A+B+C+D)
SET @AMTA2 = 0
SELECT @AMTA2 = ISNULL(SUM(AMT2),0) FROM #MHFORM3E_A  WHERE PART = 1 AND PARTSR IN('2','4') AND SRNO ='A'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','B',0,ROUND(@AMTA2,0),0,0,'','','','','','')
--7 Amount deferred (out of Box (6)) ( under package scheme of incentives) if any
SET @AMTA1 = 0
select @AMTA1 = isnull(sum(B.AMOUNT),0) from JVMAIN A INNER JOIN JVACDET B ON ( A.ENTRY_TY =B.entry_ty AND A.Tran_cd =B.Tran_cd  AND B.amt_ty ='DR')
where A.entry_ty ='J4'   and (A.date between @SDATE and @EDATE )
and A.VAT_ADJ ='Under Package Scheme of Incentives' AND A.party_nm = 'CST PAYABLE'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','C',0,ROUND(@AMTA1,0),0,0,'','','','','','')
--8 Balance  Amount Payable  ( Box (6)- Box (7))
SET @AMTA1 = 0
Select @AMTA1=ROUND(ISNULL(sum(Amt1),0),0) from #MHFORM3E_A where Partsr = '5' And Srno = 'B'
SET @AMTA2 = 0
Select @AMTA2=ROUND(ISNULL(sum(Amt1),0),0) from #MHFORM3E_A where Partsr = '5' And Srno = 'C'

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','D',0,round((@AMTA1-@AMTA2),0) ,0,0,'','','','','','')
--9 (a) Add:- Interest Payable
SET @AMTA1 = 0
select @AMTA1 = isnull(sum(B.AMOUNT),0) from JVMAIN A INNER JOIN JVACDET B ON ( A.ENTRY_TY =B.entry_ty AND A.Tran_cd =B.Tran_cd  AND B.amt_ty ='DR')
where A.entry_ty ='J4'   and (A.date between @SDATE and @EDATE )
and a.VAT_ADJ ='Interest  Payable' AND a.party_nm = 'CST PAYABLE'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','E1',0,ROUND(@AMTA1,0),0,0,'','','','','','')
---- 9 (b) Add:- Amount Payable against excess collection if any, as per Box-5
SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #MHFORM3E_A  WHERE PART = 1 AND PARTSR ='5' AND SRNO ='A'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','E2',0,ROUND(@AMTA1,0),0,0,'','','','','','')

----9 (c) Add:-Late Fee Payable
SET @AMTA1 = 0
select @AMTA1 = isnull(sum(B.AMOUNT),0) from JVMAIN  A INNER JOIN JVACDET B ON ( A.ENTRY_TY =B.entry_ty AND A.Tran_cd =B.Tran_cd  AND B.amt_ty ='DR')
 where A.entry_ty ='J4'   and (A.date between @SDATE and @EDATE )
and a.VAT_ADJ ='Late Fees Payable' AND a.party_nm = 'CST PAYABLE'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','E3',0,ROUND(@AMTA1,0),0,0,'','','','','','')

--10 Total Amount Payable ( Box (8)+ Box (9))
Select @AMTA1=isnull(sum(Amt1),0) from #MHFORM3E_A where Partsr = '5' And Srno In('D','E1','E2','E3')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','F',0,ROUND(@AMTA1,0),0,0,'','','','','','')
---Deduct																		
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','G',0,0,0,0,'','','','','','')

--11 a)			Excess Credit brought forward from previous return
SET @AMTA1 = 0
select @AMTA1 = isnull(sum(B.AMOUNT),0) from JVMAIN A INNER JOIN JVACDET B ON ( A.ENTRY_TY =B.entry_ty AND A.Tran_cd =B.Tran_cd  AND B.amt_ty ='DR')
where A.entry_ty ='J4'   and (A.date between @SDATE and @EDATE )
and A.VAT_ADJ ='Excess credit brought forward from previous return' AND A.party_nm = 'CST PAYABLE'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','H1',0,round(@AMTA1,0),0,0,'','','','','','')
--11 b)			Excess MVAT refund to be adjusted against the CST liability.
SET @AMTA1 = 0
select @AMTA1 = isnull(sum(b.amount),0) from JVMAIN A INNER JOIN JVACDET B ON ( A.ENTRY_TY =B.entry_ty AND A.Tran_cd =B.Tran_cd  AND B.amt_ty ='DR') 
where A.entry_ty ='J4'   and (A.date between @SDATE and @EDATE )
and A.VAT_ADJ ='Adjustment Towards CST' AND A.party_nm = 'CST PAYABLE'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','H2',0,round(@AMTA1,0),0,0,'','','','','','')
--11 c)			Amount already paid ( if any)( Details to be entered in Box 13

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','H3',0,0,0,0,'','','','','','')
---11 d)			Refund Adjustment order Amount ( Details to be entered in Box 14

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','H4',0,0,0,0,'','','','','','')

--12	Balance Amount Refundable / Excess credit ( if amount [11(a)+11(b)+11(c)+11(d)] -Amount  10- is positive)

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
 			   VALUES (1,'5','I1',0,0,0,0,'','','','','','')
---a)			Excess Credit carried forward to subsequent return
SET @AMTA1 = 0
select @AMTA1 = isnull(sum(B.AMOUNT),0) from JVMAIN A inner JOIN JVACDET B ON ( A.ENTRY_TY =B.entry_ty AND A.Tran_cd =B.Tran_cd  AND B.amt_ty ='DR')
where a.entry_ty ='J4'   and (a.date between @SDATE and @EDATE )
and A.VAT_ADJ ='Excess Credit carried forward to subsequent return' AND A.party_nm = 'CST PAYABLE'
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','I2',0,round(@AMTA1,0),0,0,'','','','','','')
--- b)			Excess Credit claimed as refund( amount ( 12- 12(a))

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','I3',0,round(@AMTB2,0),0,0,'','','','','','')
-- c)			Balance Amount payable  ( if Amount 10- (11(a)+11(b)+11(c)+11(d))- is positive)

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'5','I4',0,round(@AMTB2,0),0,0,'','','','','','')

--13)  Details of Amount Already Paid

INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) SELECT 1
,'6','A',0,round(B.NET_AMT,0),0,0,B.U_CHALNO,B.DATE,B.BANK_NM,'','',C.S_TAX FROM BPMAIN B  INNER JOIN AC_MAST C ON (B.BANK_NM=C.AC_NAME) WHERE B.party_nm ='CST PAYABLE' and b.u_nature ='CST' AND (B.DATE BETWEEN @SDATE AND @EDATE)
	
IF NOT EXISTS(SELECT TOP 1 SRNO FROM #MHFORM3E_A WHERE PART = 1 AND PARTSR ='6' AND SRNO ='A')
BEGIN
	INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'6','A',0,0,0,0,'','','','','','')
END
set @AMTA1 = 0
select @AMTA1=Sum(AMT1) from #MHFORM3E_A where Partsr = '6'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,Party_nm) VALUES  (1,'6','Z',0,round(@AMTA1,0),round(@AMTO1,0),0,'Total','')

--14 )  Details of RAO
INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX)
select 1,'7','A'
,0,ROUND(B.AMOUNT,0),0,0,A.RAOSNO,A.RAODT,'','','','' FROM JVMAIN A  INNER JOIN JVACDET B 
ON ( A.ENTRY_TY =B.entry_ty AND A.Tran_cd =B.Tran_cd  AND B.amt_ty ='DR') WHERE A.ENTRY_TY='J4' AND (A.RAOSNO<>'' OR A.RAODT<>'') 
and A.VAT_ADJ='Refund Adjustment order' and A.PARTY_NM='CST PAYABLE' AND (A.DATE BETWEEN @SDATE AND @EDATE)
IF NOT EXISTS(SELECT TOP 1 SRNO FROM #MHFORM3E_A WHERE PART = 1 AND PARTSR ='7' AND SRNO ='A')
BEGIN
	INSERT INTO #MHFORM3E_A (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
			   VALUES (1,'7','A',0,0,0,0,'','','','','','')
END
----AMOUNT ALREADY PAID 
SET @AMTA1 = 0
SELECT @AMTA1 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '6' AND SRNO = 'A'
UPDATE #MHFORM3E_A  SET AMT1= @AMTA1 WHERE PART = 1 AND  PARTSR = '5' AND SRNO = 'H3' 
---11 d)			Refund Adjustment order Amount ( Details to be entered in Box 14
SET @AMTA1 = 0
SELECT @AMTA1 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '7' AND SRNO = 'A'
UPDATE #MHFORM3E_A  SET AMT1= round(@AMTA1,0) WHERE PART = 1 AND  PARTSR = '5' AND SRNO = 'H4' 
-----------------------------
----- 12 colum value updatation query
SET @AMTA1 = 0
SELECT @AMTA1 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '5' AND SRNO in('H1','H2','H3','H4')
SET @AMTA2 = 0
SELECT @AMTA2 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '5' AND SRNO ='F'
SET @AMTB1 = ROUND(@AMTA1,0) - ROUND(@AMTA2,0)
UPDATE #MHFORM3E_A  SET AMT1= (CASE WHEN @AMTB1 > 0 THEN round(@AMTB1,0) ELSE 0 END) WHERE PART = 1 AND  PARTSR = '5' AND SRNO = 'I1' 
--------
---- 12 B colum value updatation query
SET @AMTA1 = 0
SELECT @AMTA1 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '5' AND SRNO = 'I1' 
SET @AMTA2 = 0
SELECT @AMTA2 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '5' AND SRNO = 'I2' 
SET @AMTB1 = ROUND(@AMTA1,0) - ROUND(@AMTA2,0)
UPDATE #MHFORM3E_A  SET AMT1= @AMTB1  WHERE PART = 1 AND  PARTSR = '5' AND SRNO = 'I3' 
----------------------------------------------------------------
----- 12 colum value updatation query
SET @AMTA1 = 0
SELECT @AMTA1 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '5' AND SRNO ='F'
SET @AMTA2 = 0
SELECT @AMTA2 =  ISNULl(SUM(AMT1),0) FROM #MHFORM3E_A WHERE PART = 1 AND  PARTSR = '5' AND SRNO in('H1','H2','H3','H4')
SET @AMTB1 = ROUND(@AMTA1,0) - ROUND(@AMTA2,0)
UPDATE #MHFORM3E_A  SET AMT1= (CASE WHEN @AMTB1 > 0 THEN @AMTB1 ELSE 0 END) WHERE PART = 1 AND  PARTSR = '5' AND SRNO = 'I4' 
--------

Update #MHFORM3E_A set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),
SELECT * FROM #MHFORM3E_A order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
