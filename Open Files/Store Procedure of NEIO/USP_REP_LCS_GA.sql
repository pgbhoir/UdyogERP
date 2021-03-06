DROP PROCEDURE [USP_REP_LCS_GA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Excise Duty Available Report.
-- Modification Date/By/Reason: 09/08/2009 Rupesh Prajapati. Modified for Addl. Duty / CVD.
-- Modification Date/By/Reason: 11/08/2009 Rupesh Prajapati. Modified for Part-II Opening Balance Entry. 
-- Modification Date/By/Reason: 07/10/2009 Duty Available Part Grouping
-- Modification Date/By/Reason: 11/02/2010 Duty payable Part for u_cldt-->date
-- Modification Date/By/Reason: 16/06/2010 for TKT-2397 by Ajay Jaiswal
-- Modification Date/By/Reason: 09/07/2010 for TKT-2862 by Ajay Jaiswal
-- Modification Date/By/Reason: 02/10/2010 for TKT-3905 by Shrikant S. 
-- Modify By				  : Nilesh on date 25/02/2015 for bug 25365 
-- Remark:
-- =============================================
Create PROCEDURE  [USP_REP_LCS_GA]
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
SET QUOTED_IDENTIFIER OFF
DECLARE @FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
DECLARE @FDATE VARCHAR(15)
SELECT @FDATE=CASE WHEN DBDATE=1 THEN 'DATE' ELSE 'U_CLDT' END FROM MANUFACT
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE
 ,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='STMAIN',@VITFILE='STITEM',@VACFILE=' '
/*,@VDTFLD =@FDATE*/
,@VDTFLD ='DATE'
,@VLYN=@LYN
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

-- added by Nilesh on date 25/02/2015 for bug 25365 Start
Select SRNO='AAA',s.party_nm,e.date,e.inv_no,e.tran_cd,s.[Rule],e.u_asseamt,examt=0,u_cessamt=0,U_hcesamt=0,u_cvdamt=0,bcdamt=0,
ac.mailname
INTO #DAILY
from stitem e
INNER JOIN STMAIN s ON (e.TRAN_CD=s.TRAN_CD)
INNER JOIN AC_MAST ac ON (s.AC_ID=ac.AC_ID)
WHERE 1=2

-- added by Nilesh on date 25/02/2015 for bug 25365 End 



Print @FCON
DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000)


-- added by Nilesh on date 25/02/2015 for bug 25365 Start
SET @SQLCOMMAND=' INSERT INTO #DAILY ' 
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(SRNO,party_nm,DATE,inv_no,Tran_cd,[Rule],u_asseamt,examt,u_cessamt,U_hcesamt,u_cvdamt,bcdamt,mailname)'
-- added by Nilesh on date 25/02/2015 for bug 25365 End

SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'SELECT SRNO=0,STMAIN.PARTY_NM,STITEM.DATE,STITEM.INV_NO,STITEM.TRAN_CD,STMAIN.[RULE],STITEM.U_ASSEAMT,STITEM.EXAMT,STITEM.U_CESSAMT,STITEM.U_HCESAMT,STITEM.U_CVDAMT,STITEM.BCDAMT, '
--Added by Ajay Jaiswal on 09/07/2010 for TKT-2862 ---> Start
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'MailName=(CASE WHEN ISNULL(Ac_mast.MailName,'''')='''' THEN Ac_mast.ac_name ELSE Ac_mast.mailname END)'
--Added by Ajay Jaiswal on 09/07/2010 for TKT-2862 ---> End
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' FROM STITEM  INNER JOIN STMAIN  ON (STITEM.TRAN_CD=STMAIN.TRAN_CD)INNER JOIN IT_MAST  ON (STITEM.IT_CODE=IT_MAST.IT_CODE)  INNER JOIN AC_MAST ON (STMAIN.AC_ID=AC_MAST.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND STITEM.ENTRY_TY='+'''ST'''+' AND (STMAIN.[RULE] IN ('+'''MODVATABLE'''+','+'''REBATE'''+')) AND STITEM.EXAMT<>0 '
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ORDER BY STITEM.DATE,STITEM.INV_NO '
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' UNION' Changed by Ajay Jaiswal for TKT-2397 on 16/06/2010
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' UNION ALL'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' SELECT SRNO=1,PARTY_NM=EX.SHORTNM,DATE=AC.'+@FDATE+' ,INV_NO=CASE   WHEN  LEN(LTRIM(RTRIM(AC.U_RG23NO)))>0 THEN AC.U_RG23NO  WHEN  LEN(LTRIM(RTRIM(AC.U_RG23CNO)))>0 THEN AC.U_RG23CNO  WHEN  LEN(LTRIM(RTRIM(AC.U_PLASR)))>0 THEN AC.U_PLASR 	ELSE SPACE(1)  END'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  ,AC.TRAN_CD,[RULE]=SPACE(1),U_ASSEAMT=0,EXAMT=AMOUNT,U_CESSAMT=0,U_HCESAMT=0,U_CVDAMT=0,BCDAMT=0,  '
--Added by Ajay Jaiswal on 09/07/2010 for TKT-2862 ---> Start
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'MailName=(CASE WHEN ISNULL(A.MailName,'''')='''' THEN A.ac_name ELSE A.mailname END)'
--Added by Ajay Jaiswal on 09/07/2010 for TKT-2862 ---> End
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  FROM EX_VW_ACDET AC INNER JOIN AC_MAST A ON (AC.AC_ID=A.AC_ID) '  
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  INNER JOIN  ER_EXCISE EX ON (EX.AC_NAME=A.AC_NAME)   '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'   WHERE (AC.'+@FDATE+' BETWEEN  '+CHAR(39)+CAST(@SDATE AS  VARCHAR)+CHAR(39)+'  AND '+CHAR(39)+CAST(@eDATE AS  VARCHAR)+CHAR(39)+') AND AC.AMT_TY='+'''CR'''
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' UNION' Changed by Ajay Jaiswal for TKT-2397 on 16/06/2010
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' UNION ALL'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  SELECT SRNO=2,PARTY_NM=EX.SHORTNM'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  +(case when  CHARINDEX(''RG23A'', a.ac_name)<>0 then  ''- RG23A'' else (case when  CHARINDEX(''RG23C'', a.ac_name)<>0 then  ''- RG23C'' else (case when  CHARINDEX(''PLA'', a.ac_name)<>0 then  ''- PLA'' else '''' end) end) end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,DATE=GETDATE(),INV_NO=SPACE(1) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  ,TRAN_CD=0,[RULE]=SPACE(1),U_ASSEAMT=0,EXAMT=SUM(CASE WHEN AC.AMT_TY='+'''DR'''+' THEN AC.AMOUNT ELSE -AC.AMOUNT END)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  ,U_CESSAMT=0,U_HCESAMT=0,U_CVDAMT=0,BCDAMT=0 ,'
--Added by Ajay Jaiswal on 09/07/2010 for TKT-2862 ---> Start
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'MailName=(CASE WHEN ISNULL(A.MailName,'''')='''' THEN A.ac_name ELSE A.mailname END)'
--Added by Ajay Jaiswal on 09/07/2010 for TKT-2862 ---> End
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  FROM EX_VW_ACDET AC '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  INNER JOIN AC_MAST A ON (AC.AC_ID=A.AC_ID)  '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  INNER JOIN  ER_EXCISE EX ON (EX.AC_NAME=A.AC_NAME)   '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'   WHERE (AC.'+@FDATE+' <= '+CHAR(39)+CAST(@eDATE AS  VARCHAR)+CHAR(39)+') '		--Changed by Shrikant S. on 02/10/2010 for TKT-3905
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'   WHERE (AC.'+@FDATE+' < '+CHAR(39)+CAST(@eDATE AS  VARCHAR)+CHAR(39)+') '	--Commented by Shrikant S. on 02/10/2010 for TKT-3905
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'   GROUP BY EX.SHORTNM,a.ac_name,a.mailname'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'   HAVING SUM(CASE WHEN AC.AMT_TY='+'''DR'''+' THEN AC.AMOUNT ELSE -AC.AMOUNT END)<>0 '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'   order by stitem.date,STITEM.INV_NO'
EXECUTE SP_EXECUTESQL @SQLCOMMAND
PRINT @SQLCOMMAND


-- added by Nilesh on date 25/02/2015 for bug 25365 Start
DECLARE @nCount AS NUMERIC(4)

SET @nCount = 0
Select @nCount=COUNT(SRNO) From #DAILY Where SRNO = '0'
SET @nCount=CASE WHEN @nCount IS NULL THEN 0 ELSE @nCount END

IF @nCount = 0
	INSERT INTO #DAILY
   (SRNO,party_nm,DATE,inv_no,Tran_cd,[Rule],u_asseamt,examt,u_cessamt,U_hcesamt,u_cvdamt,bcdamt,mailname)
         VALUES ('0','', '',  ''  ,   '',    '',      0,    0 ,  0,        0,       0,    0,  '')           
  
  
SET @nCount = 0
Select @nCount=COUNT(SRNO) From #DAILY Where SRNO = '1'
SET @nCount=CASE WHEN @nCount IS NULL THEN 0 ELSE @nCount END

IF @nCount = 0
	INSERT INTO #DAILY
	   (SRNO,party_nm,DATE,inv_no,Tran_cd,[Rule],u_asseamt,examt,u_cessamt,U_hcesamt,u_cvdamt,bcdamt,mailname)
        VALUES ('1','', '',  ''  ,   '',    '',      0,    0 ,  0,        0,       0,    0,  '')        
        

SET @nCount = 0
Select @nCount=COUNT(SRNO) From #DAILY Where SRNO = '2'
SET @nCount=CASE WHEN @nCount IS NULL THEN 0 ELSE @nCount END

IF @nCount = 0
	INSERT INTO #DAILY
	      (SRNO,party_nm,DATE,inv_no,Tran_cd,[Rule],u_asseamt,examt,u_cessamt,U_hcesamt,u_cvdamt,bcdamt,mailname)
        VALUES ('2','', '',  ''  ,   '',    '',      0,    0 ,  0,        0,       0,    0,  '')           


select * from #DAILY  order by date,INV_NO

-- added by Nilesh on date 25/02/2015 for bug 25365 End
GO
