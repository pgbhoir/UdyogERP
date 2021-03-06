IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE ='P' AND NAME ='USP_REP_MP_VATFORM26')
BEGIN
	DROP PROCEDURE USP_REP_MP_VATFORM26
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
--EXECUTE USP_REP_MP_VATFORM26'','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''
-- Author:		Hetal L Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate MP VAT FORM 26
-- Modify date: 16/05/2007
-- Modified By: SURAJ KUAMWAT 
-- Modify date: 27-08-2015
-- Remark:
-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_MP_VATFORM26]
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
declare @bank_nm varchar(250),@u_chalno varchar(50),@u_chaldt smalldatetime
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
 ,bank_nm=AC1.AC_NAME,u_chalno=M.INV_NO,u_chaldt=M.DATE
INTO #FORM26
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)

---- (a) Tax/Lump-sum according to  return period from 01-04-2015 to  31-03-2016
--SET @AMTA1 = 0
--select @AMTA1=isnull(SUM(NET_AMT),0) From BPMAIN 
--Where U_NATURE ='' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
--INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','A',0,@AMTA1,0,0,'')
----(b) Tax demanded after  assessment for the year case no. assesed by 
--INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm) VALUES (1,'1','B',0,0,0,0,'')
----(c) Penalty
--SET @AMTA1 = 0
--select @AMTA1=isnull(SUM(NET_AMT),0) From BPMAIN 
--Where U_NATURE ='Penalty' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
--INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','C',0,@AMTA1,0,0,'')
----(d) Interest
--SET @AMTA1 = 0
--select @AMTA1=ISNULL(SUM(NET_AMT),0) From BPMAIN
--Where U_NATURE ='Interest' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
--INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','D',0,@AMTA1,0,0,'')
----(e) Registration fee
--SET @AMTA1 = 0
--select @AMTA1=ISNULL(SUM(NET_AMT),0) From BPMAIN
--Where U_NATURE ='Registration fee' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
--INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','E',0,@AMTA1,0,0,'')
----(f) Miscellaneous
--SET @AMTA1 = 0
--select @AMTA1=ISNULL(SUM(NET_AMT),0) From BPMAIN
--Where U_NATURE ='Miscellaneous' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
--INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','F',0,0,0,0,'')

Declare cur_mp_vat_form_26 cursor for 
select DISTINCT bank_nm,u_chalno,u_chaldt From BPMAIN 
Where  Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE' and U_NATURE in('Miscellaneous','Registration fee','Registration fees','Interest','Penalty','','Composition Money')
open cur_mp_vat_form_26
fetch cur_mp_vat_form_26 into @bank_nm,@u_chalno,@u_chaldt
while(@@fetch_status = 0)
begin
	-- (a) Tax/Lump-sum according to  return period from 01-04-2015 to  31-03-2016
	SET @AMTA1 = 0
	select @AMTA1=isnull(SUM(NET_AMT),0) From BPMAIN 
	Where U_NATURE ='' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
	and bank_nm=@bank_nm and u_chalno=@u_chalno and u_chaldt=@u_chaldt
	INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,bank_nm,u_chalno,u_chaldt) VALUES (1,'1','A',0,@AMTA1,0,0,'',@bank_nm,@u_chalno,@u_chaldt)
	--(b) Tax demanded after  assessment for the year case no. assesed by 
	
	INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,party_nm,bank_nm,u_chalno,u_chaldt) VALUES (1,'1','B',0,0,0,0,'',@bank_nm,@u_chalno,@u_chaldt)
	--(c) Penalty
	SET @AMTA1 = 0
	select @AMTA1=isnull(SUM(NET_AMT),0) From BPMAIN 
	Where U_NATURE ='Penalty' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
	and bank_nm=@bank_nm and u_chalno=@u_chalno and u_chaldt=@u_chaldt
	INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,bank_nm,u_chalno,u_chaldt) VALUES (1,'1','C',0,@AMTA1,0,0,'',@bank_nm,@u_chalno,@u_chaldt)
	--(d) Interest
	SET @AMTA1 = 0
	select @AMTA1=ISNULL(SUM(NET_AMT),0) From BPMAIN
	Where U_NATURE ='Interest' AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
	and bank_nm=@bank_nm and u_chalno=@u_chalno and u_chaldt=@u_chaldt
	INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,bank_nm,u_chalno,u_chaldt) VALUES (1,'1','D',0,@AMTA1,0,0,'',@bank_nm,@u_chalno,@u_chaldt)
	--(e) Registration fee
	SET @AMTA1 = 0
	select @AMTA1=ISNULL(SUM(NET_AMT),0) From BPMAIN
	Where U_NATURE IN('Registration fee','Registration fees') AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
	and bank_nm=@bank_nm and u_chalno=@u_chalno and u_chaldt=@u_chaldt
	pRINT @AMTA1
	INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,bank_nm,u_chalno,u_chaldt) VALUES (1,'1','E',0,@AMTA1,0,0,'',@bank_nm,@u_chalno,@u_chaldt)
	--(f) Miscellaneous
	SET @AMTA1 = 0
	select @AMTA1=ISNULL(SUM(NET_AMT),0) From BPMAIN
	Where U_NATURE in('Miscellaneous','Composition Money')  AND Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE'
	and bank_nm=@bank_nm and u_chalno=@u_chalno and u_chaldt=@u_chaldt
	INSERT INTO #FORM26 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,bank_nm,u_chalno,u_chaldt) VALUES (1,'1','F',0,@AMTA1,0,0,'',@bank_nm,@u_chalno,@u_chaldt)
	
fetch cur_mp_vat_form_26 into @bank_nm,@u_chalno,@u_chaldt
end
close cur_mp_vat_form_26
deallocate cur_mp_vat_form_26

Update #form26 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = ISNULl((SELECT SUM(AMT1) FROM #form26),0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 --PARTY_NM = isnull((select TOP 1 BANK_NM From BPMAIN Where  Date between @Sdate And @Edate and ENTRY_TY = 'BP' And Party_nm = 'VAT PAYABLE' AND bank_nm <>''),'')
					 ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),


SELECT * FROM #FORM26 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
