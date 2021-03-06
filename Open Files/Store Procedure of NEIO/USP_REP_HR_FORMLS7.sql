IF EXISTS (SELECT XTYPE, NAME FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'USP_REP_HR_FORMLS7')
BEGIN
	DROP PROCEDURE USP_REP_HR_FORMLS7
END
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
go

/*
EXECUTE USP_REP_HR_FORMLS7'','','','04/01/2010','03/31/2017','','','','',0,0,'','','','','','','','','2010-2011',''
*/

-- =============================================
-- Author:		Hetal L Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate HR VAT FORM LS 07
-- Modify date: 16/05/2007
-- Modified By: Sandeep Shah
-- Modify date: 18/01/2011
-- Remark:    : Store procedure update for TKT-5091
-- Modified By: GAURAV R. TANNA for the Bug-
-- Modify date: 15/05/2015
-- Modified By: Suraj Kumawat -
-- Modify date: 27-08-2016 for bug-26291 

-- =============================================
Create  PROCEDURE [dbo].[USP_REP_HR_FORMLS7]
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

DECLARE @SQLCOMMAND NVARCHAR(4000), @MCON as NVARCHAR(2000)

---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=rtrim(ltrim(Ac.AC_NAME))+Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3) ,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX,Item=Space(50),Qty=9999999999.9999,stm.level1
INTO #FORMLS7
FROM STACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)

Begin ------Fetch Single Co. Data
	 Set @MultiCo = 'NO'
	 --Changed by GAURAV R. TANNA for the Bug - start
	 --EXECUTE USP_REP_SINGLE_CO_DATA
	 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
	  --CHanged by GAURAV R. TANNA for the Bug - End
	  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
	 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
	 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
	 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
	 ,@MFCON = @MCON OUTPUT

	 INSERT INTO #FORMLS7 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM, QTY,S_TAX,FORM_NM,LEVEL1)
		
	 ---SELECT 1,'1', 'A', 0, A.VATONAMT,0,0, A.INV_NO, A.DATE, A.AC_NAME, A.ADDRESS, I.IT_NAME, D.QTY, A.S_TAX,RFORM_NM=CASE WHEN A.RFORM_NM IN ('F','FORM F', 'F FORM', 'FORM-F', 'FORM - F') THEN S.FORM_No ELSE '' END,STM.LEVEL1 FROM VATTBL A  --- for bug-26291 date on 27-08-2016
	 SELECT 1,'1', 'A', 0, A.GRO_AMT,0,0, A.INV_NO, A.DATE, rtrim(ltrim(A.AC_NAME)) + ' '+ ltrim(rtrim(A.ADDRESS)), A.ADDRESS
	 , IT_NAME = case when cast(I.it_desc as varchar(250)) <> '' then cast(I.it_desc as varchar(250)) else I.IT_NAME end , D.QTY, A.S_TAX,RFORM_NM=CASE WHEN rtrim(ltrim(replace(replace(replace(replace(a.rform_nm,'form',''),'-',''),'/',''),' ',''))) = 'f' THEN S.FORM_No ELSE '' END,STM.LEVEL1 FROM VATTBL A  --- for bug-26291 date on 27-08-2016
	 INNER JOIN STMAIN S ON (S.TRAN_CD = A.TRAN_CD AND S.ENTRY_TY = A.BHENT)
	 INNER JOIN STITEM D ON (D.TRAN_CD = A.TRAN_CD AND D.ENTRY_TY = A.BHENT AND D.IT_CODE = A.IT_CODE)
	 INNER JOIN STAX_MAS STM ON (D.TAX_NAME=STM.TAX_NAME AND STM.ENTRY_TY = A.BHENT)
	 INNER JOIN IT_MAST I ON (I.IT_CODE = A.IT_CODE)
	 INNER JOIN AC_MAST AC ON AC.AC_ID = A.AC_ID 
	 WHERE A.ST_TYPE = 'OUT OF STATE' AND A.BHENT ='ST' AND  rtrim(ltrim(replace(replace(replace(replace(a.rform_nm,'form',''),'-',''),'/',''),' ',''))) = 'f' and a.u_imporm in('Branch Transfer','Consignment Transfer') 
	 ---WHERE A.ST_TYPE = 'OUT OF STATE' AND A.BHENT in ('ST') AND A.RFORM_NM IN ('F', 'FORM F', 'F FORM', 'FORM-F', 'FORM - F')
	 AND (A.DATE BETWEEN @SDATE AND @EDATE) 

		--Put in remarks by GAURAV R. TANNA for the Bug - start
		------SET @SQLCOMMAND='Select * from '+@MCON
		-------EXECUTE SP_EXECUTESQL @SQLCOMMAND
		----SET @SQLCOMMAND='Insert InTo #FORM_LS5 Select * from '+@MCON
		----EXECUTE SP_EXECUTESQL @SQLCOMMAND
		-------Drop Temp Table 
		----SET @SQLCOMMAND='Drop Table '+@MCON
		----EXECUTE SP_EXECUTESQL @SQLCOMMAND

		----Declare cur_formls5aa cursor for
		----SELECT A.PER,A.TAXONAMT,B.TAXAMT,ITEMAMT=B.GRO_AMT,A.INV_NO,A.DATE,A.PARTY_NM,A.ADDRESS,B.ITEM,FORM_NM=FORM_NO,A.S_TAX,B.QTY
		----FROM #FORM_LS5 A
		----Inner Join LITEM_VW B On (A.BHENT = B.ENTRY_TY AND A.TRAN_CD = B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
		----inner join PTITEM C ON (C.ENTRY_TY =B.ENTRY_TY AND C.TRAN_CD=B.TRAN_CD AND C.ITSERIAL=B.ITSERIAL)
		----inner join PTMAIN D ON (D.ENTRY_TY =C.ENTRY_tY AND D.TRAN_CD=C.TRAN_CD )
		----WHERE A.ST_TYPE='OUT OF STATE' AND A.PER<>0 AND A.BHENT IN ('PT','P1') AND (A.DATE BETWEEN @SDATE AND @EDATE)
		--Put in remarks by GAURAV R. TANNA for the Bug - end
		
End

Update #formLS7 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''), level1 = isnull(level1,0),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,''), Qty = isnull(Qty,0),  ITEM =isnull(item,'')

SELECT * FROM #FORMLS7 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
--Print 'HR VAT FORM LS 07'

