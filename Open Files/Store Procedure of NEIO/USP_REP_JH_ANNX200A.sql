set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:  Hetal L Patel
-- Create date: 26/10/2009
-- Description:	This Stored procedure is useful to generate  JH VAT FORM 200A
-- Modify date: 16-Feb-2010
-- Modified By: Rakesh Varma
-- Remark:
-- =============================================
 ALTER PROCEDURE [dbo].[USP_REP_JH_ANNX200A]
 @TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),
 @SPLCOND VARCHAR(8000),
 @SDATE  SMALLDATETIME,@EDATE SMALLDATETIME,
 @SAC AS VARCHAR(60),@EAC AS VARCHAR(60),
 @SIT AS VARCHAR(60),@EIT AS VARCHAR(60),
 @SAMT FLOAT,@EAMT FLOAT,
 @SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60),
 @SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60),
 @SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60),
 @SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60),
 @LYN VARCHAR(20),
 @EXPARA  AS VARCHAR(60)= NULL
AS

BEGIN

DECLARE @FCON AS NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON
 @VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND,
 @VSDATE=NULL,@VEDATE=@EDATE,
 @VSAC =@SAC,@VEAC =@EAC,
 @VSIT=@SIT,@VEIT=@EIT,
 @VSAMT=@SAMT,@VEAMT=@EAMT,
 @VSDEPT=@SDEPT,@VEDEPT=@EDEPT,
 @VSCATE =@SCATE,@VECATE =@ECATE,
 @VSWARE =@SWARE,@VEWARE  =@EWARE,
 @VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR,
 @VMAINFILE='M',@VITFILE=Null,@VACFILE='AC',
 @VDTFLD ='DATE',@VLYN=Null,
 @VEXPARA=@EXPARA,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)

DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),
        @AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),
        @AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),
        @AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)

DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),
        @AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),
        @AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),
        @AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)

DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1)
INTO #VATAC_MAST
FROM STAX_MAS
WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''

INSERT INTO #VATAC_MAST
SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1)
FROM STAX_MAS
WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>'' 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,
M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,
MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM,
ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,
Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #JH_Annexure_A
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #JH_Annexure_A add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX,ITEM=space(50),Qty=9999999999999999999.9999
INTO #JH_AnnexureA
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID)
          Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
		 EXECUTE USP_REP_MULTI_CO_DATA
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo  #JH_Annexure_A Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 EXECUTE USP_REP_SINGLE_CO_DATA
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo  #JH_Annexure_A Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End

----------------------------------------------------------------------------------------------------------

--Rate Sales of Goods

 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,
        @AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0

-- SET @CHAR=71

 DECLARE  CUR_FORM1 CURSOR FOR select distinct level1 from stax_mas where ST_TYPE='LOCAL'

 OPEN CUR_FORM1

 FETCH NEXT FROM CUR_FORM1 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	if @per = 0
		begin
			SELECT @AMTA1=Round(SUM(NET_AMT),0) FROM #JH_Annexure_A where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' And ac_name not like '%Rece%' and U_imporm <> 'Purchase Return'
			SELECT @AMTB1=Round(SUM(TAXAMT),0)  FROM #JH_Annexure_A where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' And ac_name not like '%Rece%' and U_imporm <> 'Purchase Return'
			SELECT @AMTC1=Round(SUM(NET_AMT),0) FROM #JH_Annexure_A where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER 
			SELECT @AMTD1=Round(SUM(TAXAMT),0)  FROM #JH_Annexure_A where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER
		end
	else
		begin
			SELECT @AMTA1=Round(SUM(NET_AMT),0) FROM #JH_Annexure_A where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and ac_name not like '%Rece%' And S_tax <> '' AND PER=@PER and U_imporm <> 'Purchase Return'
			SELECT @AMTB1=Round(SUM(TAXAMT),0)  FROM #JH_Annexure_A where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and ac_name not like '%Rece%' And S_tax <> '' AND PER=@PER and U_imporm <> 'Purchase Return'
			SELECT @AMTC1=Round(SUM(NET_AMT),0) FROM #JH_Annexure_A where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND PER=@PER
			SELECT @AMTD1=Round(SUM(TAXAMT),0)  FROM #JH_Annexure_A where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND PER=@PER
		end
	
  --Sales Invoices
  SET @AMTA1=ISNULL(@AMTA1,0)
  SET @AMTB1=ISNULL(@AMTB1,0)
 
  --Return Invoices
  SET @AMTC1=ISNULL(@AMTC1,0)
  SET @AMTD1=ISNULL(@AMTD1,0)

  --Net Effect
  Set @NetEFF = @AMTA1-(@AMTB1+(@AMTC1-@AMTD1))

  --Net Tax
  Set @NetTAX = (@AMTB1)-(@AMTD1)

  if @nettax <> 0
	  begin
          SET @AMTN1 = @NETEFF + @AMTN1
	  end

  FETCH NEXT FROM CUR_FORM1 INTO @PER
 END
 CLOSE CUR_FORM1
 DEALLOCATE CUR_FORM1

INSERT INTO #JH_AnnexureA(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty)
                   VALUES(1,'1','A',0,@AMTN1,0,0,0,0,0,0,0,0,0,0)

----------------------------------------------------------------------------------------------------------

--Amount of Sales of 'Exempt Goods' in the Tax-Period (Goods mentioned in Schedule I : Box 25A)

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
       @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

SELECT @AMTA1=SUM(NET_AMT) FROM #JH_Annexure_A 
where BHENT in('ST','DN') AND (DATE BETWEEN @SDATE AND @EDATE) AND TAX_NAME='EXEMPTED'

SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #JH_AnnexureA(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty)
VALUES(1,'1','B',0,@AMTA1,0,0,0,0,0,0,0,0,0,0)

----------------------------------------------------------------------------------------------------------------

--Amount of 'Exempt Transactions' in the Period (Box 22A)

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
       @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0

SELECT @AMTA1=SUM(NET_AMT) FROM #JH_Annexure_A 
WHERE BHENT in('ST','DN') AND ST_TYPE = 'OUT OF STATE' AND U_IMPORM = 'Branch Transfer' 
AND (DATE BETWEEN @SDATE AND @EDATE) 

SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #JH_AnnexureA(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty)
                   VALUES(1,'1','C',0,@AMTA1,0,0,0,0,0,0,0,0,0,0)

----------------------------------------------------------------------------------------------------------------

---Part 2 (Section B)

--SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
--       @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
--
--
--SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
--       @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
-- 
--SELECT @AMTA1=SUM(NET_AMT) FROM #JH_Annexure_A 
--where BHENT in('PT') AND (DATE BETWEEN @SDATE AND @EDATE) AND Tax_name ='VAT 12.5%'
--
--SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END


 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,
        @AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

 SET @CHAR=65

 DECLARE  CUR_FORM CURSOR FOR 
 select distinct level1 from stax_mas where ST_TYPE='LOCAL'

 OPEN CUR_FORM

 FETCH NEXT FROM CUR_FORM INTO @PER

 WHILE (@@FETCH_STATUS=0)
 BEGIN
  if @per = 0
	Begin
		SELECT @AMTA1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
		SELECT @AMTB1=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' 
		SELECT @AMTC1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
		SELECT @AMTD1=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> ''
		SELECT @AMTF1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
		SELECT @AMTF2=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> ''
		SELECT @AMTG1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
		SELECT @AMTG2=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> ''
		SELECT @AMTH1=Round(SUM(NET_AMT),0) FROM (select distinct tran_cd,bhent,net_amt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND U_IMPORM = 'Purchase Return') b
		SELECT @AMTH2=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND U_IMPORM = 'Purchase Return' 
	End
  else
	Begin
		SELECT @AMTA1=Round(SUM(Net_AMT),0) FROM (select distinct tran_cd,bhent,net_amt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
		SELECT @AMTB1=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
		SELECT @AMTC1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
		SELECT @AMTD1=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
		SELECT @AMTF1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
		SELECT @AMTF2=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
		SELECT @AMTG1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
		SELECT @AMTG2=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
		SELECT @AMTH1=Round(SUM(NET_AMT),0) FROM (select distinct tran_cd,bhent,net_amt,dbname from #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND U_IMPORM = 'Purchase Return') b
		SELECT @AMTH2=Round(SUM(TAXAMT),0)   FROM #JH_Annexure_A WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND U_IMPORM = 'Purchase Return' 
	End

  --Purchase Invoice
  SET @AMTA1=ISNULL(@AMTA1,0)
  SET @AMTB1=ISNULL(@AMTB1,0)
  --Return Invoice
  SET @AMTC1=ISNULL(@AMTC1,0)
  SET @AMTD1=ISNULL(@AMTD1,0)
  --Expense Purchase Invoice
  SET @AMTF1=ISNULL(@AMTF1,0)
  SET @AMTF2=ISNULL(@AMTF2,0)
  --Debit Note Invoice
  SET @AMTG1=ISNULL(@AMTG1,0)
  SET @AMTG2=ISNULL(@AMTG2,0)
  --Sales Invoice Where U_imporm = 'Purchase Return'
  SET @AMTH1=ISNULL(@AMTH1,0)
  SET @AMTH2=ISNULL(@AMTH2,0)

--Net Effect

  Set @NetEFF = ((@AMTA1 - @AMTB1) + (@AMTF1 ) - (@AMTC1 - @AMTD1) - (@AMTG1 - @AMTG2) - (@AMTH1 - @AMTH2)) 
--  PRINT @NetEFF 

--Net Tax
  Set @NetTAX = (@AMTB1 + @AMTF2) - @AMTD1 - @AMTG2 - @AMTH2

  if @nettax <> 0
	  Begin

		  INSERT INTO #JH_AnnexureA(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,Qty)
          VALUES(1,'2',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,0,'',0)

		  SET @AMTM1=@AMTM1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTO1=@AMTO1+@NETTAX --TOTAL TAX

		  SET @CHAR=@CHAR+1
	  end
  FETCH NEXT FROM CUR_FORM INTO @PER
 END
 CLOSE CUR_FORM
 DEALLOCATE CUR_FORM



----------------------------------------------------------------------------------------------------------------
INSERT INTO #JH_AnnexureA(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty)
VALUES(1,'2','Z',0,@AMTA1,@AMTA2,0,0,0,0,0,0,0,0,0)


--INSERT INTO #JH_AnnexureA (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) VALUES (1,'2','A',0,0,0,0,0,0,0,0,0,0,0,0)
--INSERT INTO #JH_AnnexureA (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) VALUES (1,'2','B',0,0,0,0,0,0,0,0,0,0,0,0)
--INSERT INTO #JH_AnnexureA (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) VALUES (1,'2','C',0,0,0,0,0,0,0,0,0,0,0,0)

SELECT * FROM #JH_AnnexureA 
order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)

END
--Print 'JH VAT FORM 200A'

