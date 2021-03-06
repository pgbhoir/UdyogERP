IF EXISTS (SELECT XTYPE, NAME FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'USP_REP_UP_ANNEXURE_B')
BEGIN
	DROP PROCEDURE USP_REP_UP_ANNEXURE_B
END
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
go
-- =============================================
-- Author:		Hetal L Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate VAT Computation Report.
-- Modify date: 16/05/2007
-- Modified By: Hetal Patel
-- Modify date: 22/04/2010
-- Re-Modified By: Rakesh Varma
-- Re-Modify date: 13-May-2010
-- Modified By: Gaurav R. Tanna for the bug-
-- Modify date: 06/07/2015
-- Remark: TKT-1070 (Problem In Amount Calculation)
-- Modified By: Gaurav R. Tanna for the bug-
-- Modify date: 31-03-2016
-- Remark: TKT-26173(Register dealer should come )

-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_UP_ANNEXURE_B]
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

 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)


---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX,Item=space(150),Qty=9999999999999999999.9999
INTO #AnnexB
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

INSERT INTO #Annexb (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,S_TAX,ADDRESS,ITEM,Qty,FORM_NM) 

SELECT 1,'1','A',A.PER,A.VATONAMT, A.TAXAMT, A.GRO_AMT, A.INV_NO, A.DATE, A.AC_NAME, A.S_TAX, A.ADDRESS, CASE WHEN CAST(I.IT_DESC AS VARCHAR(150)) <> '' THEN I.IT_DESC ELSE I.IT_NAME END , D.QTY, I.HSNCODE
FROM VATTBL A
INNER JOIN STITEM D ON (D.ENTRY_TY = A.BHENT AND D.TRAN_CD = A.TRAN_CD AND D.IT_CODE = A.IT_CODE AND A.ItSerial =D.itserial)
INNER JOIN IT_MAST I ON (I.IT_CODE = D.IT_CODE)
WHERE A.ST_TYPE='LOCAL' AND A.BHENT IN ('ST') AND (A.DATE BETWEEN @SDATE AND @EDATE) 
And A.Tax_Name like '%VAT%' AND A.S_TAX <> ''



--Sales in commission account
INSERT INTO #Annexb (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,qty,address) VALUES (1,'2','A',0,0,0,0,'',0,'')
-----------------------------------------------------------------------------------------------------------
DECLARE @RCOUNT INT

SELECT @RCOUNT = 0

SET @RCOUNT = (SELECT COUNT(*) FROM #Annexb WHERE PARTSR='1')

IF (@RCOUNT=0)
INSERT INTO #Annexb (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,qty) VALUES (1,'1','A',0,0,0,0,'',0)
-----------------------------------------------------------------------------------------------------------

Update #Annexb set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,''), Qty = isnull(Qty,0),  ITEM =isnull(item,'')


SELECT * FROM #AnnexB order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
--Print 'UP VAT FORM 24 B'


