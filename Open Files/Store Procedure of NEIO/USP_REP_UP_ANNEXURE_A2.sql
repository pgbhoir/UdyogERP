IF EXISTS (SELECT XTYPE, NAME FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'USP_REP_UP_ANNEXURE_A2')
BEGIN
	DROP PROCEDURE USP_REP_UP_ANNEXURE_A2
END
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
go
-- =============================================
-- Author:		Rakesh Varma
-- Create date: 13 May,2010
-- Description:	This Stored procedure is useful to generate VAT Computation Report.
-- Modify date: 14 May,2010
-- Modified By: Gaurav R. Tanna for the bug-
-- Modify date: 07/07/2015
-- Remark:
-- =============================================
Create PROCEDURE [dbo].[USP_REP_UP_ANNEXURE_A2]
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

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX,Item=space(50),qty=9999999999999999999.9999
INTO #AnnexA
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
		 EXECUTE USP_REP_MULTI_CO_DATA
	
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

	End

-----------------------------------------------------------------------------------------------------------

--List of purchases of Capital goods made against tax invoice

 INSERT INTO #AnnexA (PART,PARTSR,SRNO,PARTY_NM,ADDRESS,S_TAX,INV_NO,DATE,ITEM,QTY,RATE,AMT1,AMT2,AMT3)
 SELECT 1,'1','A',AA.AC_NAME,AA.ADDRESS,AA.S_TAX,AA.INV_NO,AA.DATE,LV.ITEM,LV.QTY,0,AA.VATONAMT,AA.TAXAMT,AA.GRO_AMT
 FROM VATTBL AA 
 INNER JOIN PTITEM LV
 ON (AA.BHENT = LV.ENTRY_TY AND AA.TRAN_CD = LV.TRAN_CD AND AA.IT_CODE = LV.IT_CODE And AA.ITSERIAL = LV.ITSERIAL)
 WHERE AA.BHENT IN ('PT','EP') AND AA.ITEMTYPE = 'C' AND AA.ST_TYPE = 'LOCAL' AND AA.S_TAX <> ''
 AND (AA.DATE BETWEEN @SDATE AND @EDATE)
 
 
--List of purchases of Capital goods made against tax invoice

INSERT INTO #AnnexA (PART,PARTSR,SRNO,PARTY_NM,ADDRESS,S_TAX,INV_NO,DATE,ITEM,QTY,RATE,AMT1,AMT2,AMT3)
 SELECT 1,'2','A',AA.AC_NAME,AA.ADDRESS,AA.S_TAX,AA.INV_NO,AA.DATE,LV.ITEM,LV.QTY,0,AA.VATONAMT,AA.TAXAMT,AA.GRO_AMT
 FROM VATTBL AA 
 INNER JOIN PTITEM LV
 ON (AA.BHENT = LV.ENTRY_TY AND AA.TRAN_CD = LV.TRAN_CD AND AA.IT_CODE = LV.IT_CODE And AA.ITSERIAL = LV.ITSERIAL)
 WHERE AA.BHENT IN ('PT','EP') AND AA.ITEMTYPE = 'C' AND AA.ST_TYPE = 'LOCAL' AND AA.S_TAX = ''
 AND (AA.DATE BETWEEN @SDATE AND @EDATE)
 -----------------------------------------------------------------------------------------------------------

 DECLARE @RCOUNT INT

 SELECT @RCOUNT = 0

 SET @RCOUNT = (SELECT COUNT(*) FROM #AnnexA WHERE PARTSR='1')

 IF (@RCOUNT=0)
 INSERT INTO #AnnexA (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,qty) VALUES (1,'1','A',0,0,0,0,'',0)

--------------------------------------------------------------------------------------------------------

 SELECT @RCOUNT = 0

 SET @RCOUNT = (SELECT COUNT(*) FROM #AnnexA WHERE PARTSR='2')

 IF (@RCOUNT=0)
 INSERT INTO #AnnexA (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,qty) VALUES (1,'2','A',0,0,0,0,'',0)
--------------------------------------------------------------------------------------------------------
	
Update #AnnexA set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,''), Qty = isnull(Qty,0),
					 ITEM =isnull(item,'')

SELECT * FROM #AnnexA order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
-----


