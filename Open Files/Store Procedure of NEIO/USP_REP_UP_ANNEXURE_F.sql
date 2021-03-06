IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name ='USP_REP_UP_ANNEXURE_F')
BEGIN
	DROP PROCEDURE USP_REP_UP_ANNEXURE_F
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXECUTE USP_REP_UP_ANNEXURE_F'','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''

-- =============================================
-- Author:		Sumit S Gavate
-- Create date: 29/08/2015
-- Description:	This Stored procedure is useful to generate VAT Annexure - F For Utter Pradesh State
-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_UP_ANNEXURE_F]
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

---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,S_INV_NO=space(200),M.DATE AS S_DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
AC1.STATE,STM.FORM_NM,AC1.S_TAX,Item=space(150),Qty=9999999999999999999.9999
INTO #AnnexF
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
-----

----- PART 1
INSERT INTO #AnnexF (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,S_INV_NO,S_DATE,PARTY_NM,S_TAX,ADDRESS,STATE,ITEM,Qty,FORM_NM) 
SELECT 1,'1','A',A.PER,A.VATONAMT, A.TAXAMT, (A.VATONAMT+A.TAXAMT), A.INV_NO, A.DATE,PM.u_pinvno,PM.u_pinvdt, 
A.AC_NAME, A.S_TAX, A.ADDRESS,AC.State,CASE WHEN CAST(I.IT_DESC AS VARCHAR(150)) <> '' THEN I.IT_DESC ELSE I.IT_NAME END , P.QTY, I.HSNCODE
FROM VATTBL A
INNER JOIN PTITEM P ON (P.ENTRY_TY = A.BHENT AND P.TRAN_CD = A.TRAN_CD AND P.IT_CODE = A.IT_CODE AND P.itserial = A.ItSerial)
INNER JOIN PTMAIN PM ON (PM.entry_ty = A.BHENT AND PM.Tran_cd = A.TRAN_CD AND PM.entry_ty = P.entry_ty AND PM.Tran_cd = P.Tran_cd)
INNER JOIN IT_MAST I ON (I.IT_CODE = P.IT_CODE AND I.It_code = A.It_code)
INNER JOIN AC_Mast AC On (A.AC_ID = AC.Ac_id AND A.AC_ID = PM.Ac_id  AND A.Ac_id = P.AC_ID)
WHERE A.BHENT in('PT','P1','EP') AND LTRIM(RTRIM(REPLACE(REPLACE(A.FORM_NM,'-',''),'FORM','')))='I' -- A.TAX_NAME = 'FORM I'
 AND (A.DATE BETWEEN @SDATE AND @EDATE) ORDER BY a.INV_NO

-----------------------------------------------------------------------------------------------------------
DECLARE @RCOUNT INT
SELECT @RCOUNT = 0
SET @RCOUNT = (SELECT COUNT(*) FROM #AnnexF WHERE PARTSR='1')
IF (@RCOUNT=0)
	INSERT INTO #AnnexF (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,qty,Date) VALUES (1,'1','A',0,0,0,0,'',0,'')

Update #AnnexF set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
			 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
			 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
			 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,''), Qty = isnull(Qty,0),  ITEM =isnull(item,'')


SELECT * FROM #AnnexF order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)

END
--Print 'UP VAT Annexure F'