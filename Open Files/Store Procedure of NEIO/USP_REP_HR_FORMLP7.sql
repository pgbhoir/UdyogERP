If Exists(Select [Name] from Sysobjects where xType='P' and Id=Object_Id(N'USP_REP_HR_FORMLP7'))

Begin
	Drop PROCEDURE USP_REP_HR_FORMLP7
End
Go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author      : Hetal L Patel
-- Create date : 16/05/2007
-- Description : This Stored procedure is useful to generate HR VAT FORM LP 07
-- Modify date : 
-- Modified By : Sandeep Shah
-- Modify date : 15/11/2011
-- Remark      : Modified store procedure with valid Data of the formate for TKT-5093
-- Modified By : GAURAV R. TANNA for the Bug-
-- Modify date : 18/05/2015
-- Modified By : Sumit Gavate for bug - 26283
-- Modify date : 22/07/2016
-- =============================================

/*
EXECUTE USP_REP_HR_FORMLP7'','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''
*/

CREATE   PROCEDURE [dbo].[USP_REP_HR_FORMLP7]
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

Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=null,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='B',@VITFILE='A',@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

---Temporary Cursor
SELECT PART=1,PARTSR='AAA',SRNO='AAA',LEVEL1=STM.LEVEL1,AMT1=NET_AMT,AMT2=M.TAXAMT,AC1.S_TAX ,PARTY_NM=AC1.AC_NAME INTO #FORMLP7 FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD) INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME) INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
inner join dcmast dc on (m.entry_ty=dc.entry_ty) WHERE 1=2

BEGIN
Declare @MultiCo	VarChar(3), @AMTA1 Numeric (14,2)


Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
		 /* --Put in remarks by GAURAV R. TANNA for the Bug - start
		-- EXECUTE USP_REP_MULTI_CO_DATA
		--  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		-- ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		-- ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		-- ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		-- ,@MFCON = @MCON OUTPUT

		----SET @SQLCOMMAND='Select * from '+@MCON
		-----EXECUTE SP_EXECUTESQL @SQLCOMMAND
		--SET @SQLCOMMAND='Insert InTo #FORM_LP7 Select * from '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		-----Drop Temp Table 
		--SET @SQLCOMMAND='Drop Table '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		*/ --Put in remarks by GAURAV R. TANNA for the Bug - End

	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 --Changed by GAURAV R. TANNA for the Bug - start
		 --EXECUTE USP_REP_SINGLE_CO_DATA
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  --Changed by GAURAV R. TANNA for the Bug - end
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT
		
		
		--Put in remarks by GAURAV R. TANNA for the Bug - start
		----SET @SQLCOMMAND='Select * from '+@MCON
		-----EXECUTE SP_EXECUTESQL @SQLCOMMAND
		--SET @SQLCOMMAND='Insert InTo #FORM_LP7 Select * from '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		-----Drop Temp Table 
		--SET @SQLCOMMAND='Drop Table '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		--Put in remarks by GAURAV R. TANNA for the Bug - end		
	End

INSERT INTO #FORMLP7 (PART,PARTSR,SRNO,LEVEL1,AMT1,AMT2,PARTY_NM,S_TAX)
SELECT 1,'1', 'A', stm.level1,ISNULL(SUM(a.GRO_AMT),0) as vatonamt,ISNULL(SUM(a.taxamt),0) as taxamt, a.AC_NAME, a.S_TAX from vattbl a
LEFT join stax_mas stm on (stm.tax_name = a.TAX_NAME and stm.entry_ty = a.BHENT) inner join IT_MAST it on (it.it_code = a.it_code)
where a.bhent in ('PT', 'EP') AND a.st_type in ('LOCAL','') AND it.U_shcode = '' And (a.Tax_Name LIKE '%VAT%') 
AND (A.DATE BETWEEN @SDATE AND @EDATE) AND A.S_TAX <> ' ' group by a.ac_name, a.s_tax, stm.level1
ORDER BY a.AC_NAME,a.S_TAX,stm.level1

SET @AMTA1 = 0
SELECT @AMTA1 = Count(PART) from #FORMLP7 WHERE PARTSR='1'
SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

IF @AMTA1 = 0
   BEGIN
		INSERT INTO #FORMLP7 (PART,PARTSR,SRNO,LEVEL1,AMT1,AMT2,PARTY_NM,S_TAX) VALUES  (1,'1','A',0,0,0,'', '')
   END

INSERT INTO #FORMLP7 (PART,PARTSR,SRNO,LEVEL1,AMT1,AMT2,PARTY_NM,S_TAX)
SELECT 1,'2', 'A', stm.level1, sum(a.GRO_AMT) as vatonamt, sum(a.taxamt) as taxamt, a.AC_NAME, a.S_TAX from vattbl a
LEFT join stax_mas stm on (stm.tax_name = a.TAX_NAME and stm.entry_ty = a.BHENT) inner join IT_MAST it on (it.it_code = a.it_code)
where a.bhent in ('PT', 'EP') AND a.st_type in ('LOCAL','') AND it.U_shcode = 'Schedule D' And (a.Tax_Name LIKE '%VAT%') AND 
(A.DATE BETWEEN @SDATE AND @EDATE) AND A.S_TAX <> ' ' group by a.ac_name, a.s_tax, stm.level1 ORDER BY a.AC_NAME,a.S_TAX,stm.level1

SET @AMTA1 = 0
SELECT @AMTA1=Count(PART) from #FORMLP7 WHERE PARTSR='2'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

IF @AMTA1 = 0
   BEGIN
		INSERT INTO #FORMLP7 (PART,PARTSR,SRNO,LEVEL1,AMT1,AMT2,PARTY_NM,S_TAX) VALUES  (1,'2','A',0,0,0,'', '')  
   END


INSERT INTO #FORMLP7 (PART,PARTSR,SRNO,LEVEL1,AMT1,AMT2,PARTY_NM,S_TAX)
VALUES (1,'3', 'A', 0, 0, 0, '', '')

INSERT INTO #FORMLP7 (PART,PARTSR,SRNO,LEVEL1,AMT1,AMT2,PARTY_NM,S_TAX)
SELECT 1,'4', 'A', stm.level1, sum(a.GRO_AMT) as vatonamt, sum(a.taxamt) as taxamt, a.AC_NAME, a.S_TAX from vattbl a
LEFT join stax_mas stm on (stm.tax_name = a.TAX_NAME and stm.entry_ty = a.BHENT) inner join IT_MAST it on (it.it_code = a.it_code)
where a.bhent in ('PT', 'EP') AND a.st_type in ('LOCAL','') AND it.U_shcode IN ('Schedule A', 'Schedule C') 
And (a.Tax_Name IN('Exempted','')) AND (A.DATE BETWEEN @SDATE AND @EDATE) AND A.S_TAX <> ' '
group by a.ac_name, a.s_tax, stm.level1 ORDER BY a.AC_NAME,a.S_TAX,stm.level1

SET @AMTA1 = 0
SELECT @AMTA1=Count(PART) from #FORMLP7 WHERE PARTSR='4'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

IF @AMTA1 = 0
   BEGIN
		INSERT INTO #FORMLP7 (PART,PARTSR,SRNO,LEVEL1,AMT1,AMT2,PARTY_NM,S_TAX) VALUES  (1,'4','A',0,0,0,'', '')  
   END


SELECT * FROM #FORMLP7 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
DROP TABLE #FORMLP7