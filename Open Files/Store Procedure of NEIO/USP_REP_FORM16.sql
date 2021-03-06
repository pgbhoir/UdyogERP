DROP PROCEDURE [USP_REP_FORM16]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	This is useful for Form-16A report.
-- Modification Date/By/Reason: 10/03/2010 Rupesh Prajapati. Modified for Bank Payment Advanced. TKT-584
-- Remark: 
-- =============================================
CREATE    PROCEDURE [USP_REP_FORM16]  
 @TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),  
 @SDATE SMALLDATETIME,@EDATE SMALLDATETIME,  
 @SNAME NVARCHAR(60),@ENAME NVARCHAR(60),  
 @SITEM NVARCHAR(60),@EITEM NVARCHAR(60),  
 @SAMT NUMERIC,@EAMT NUMERIC,  
 @SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),  
 @SCAT NVARCHAR(60),@ECAT NVARCHAR(60),  
 @SWARE NVARCHAR(60),@EWARE NVARCHAR(60),  
 @SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),  
 @FINYR NVARCHAR(20), @EXTPAR NVARCHAR(60)  
 AS
Declare @FCON as NVARCHAR(4000),@SQLCOMMAND as NVARCHAR(4000)  
  EXECUTE USP_REP_FILTCON   
  @VTMPAC=@TMPAC,@VTMPIT=null,@VSPLCOND=@SPLCOND,  
  @VSDATE=@SDATE,@VEDATE=@EDATE,  
  @VSAC =@SNAME,@VEAC =@ENAME,  
  @VSIT=null,@VEIT=null,  
  @VSAMT=@SAMT,@VEAMT=@EAMT,  
  @VSDEPT=@SDEPT,@VEDEPT=@EDEPT,  
  @VSCATE =@SCAT,@VECATE =@ECAT,  
  @VSWARE =null,@VEWARE  =null,  
  @VSINV_SR =@SINVSR,@VEINV_SR =@EINVSR,  
  @VMAINFILE='M',@VITFILE=null,@VACFILE=NULL,  
  @VDTFLD = 'U_CLDT',@VLYN=null,@VEXPARA=@EXTPAR,  
  @VFCON =@FCON OUTPUT  
 PRINT @FCON  
 SET @SQLCOMMAND = ''  
SELECT DISTINCT SVC_CATE,SECTION INTO #TDSMASTER FROM TDSMASTER 

Select ac_mast.ac_id,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode  /*m.entry_ty,m.tran_cd,ac.acserial,mall.new_all,*/
,m.svc_cate,m.TDSonAmt,m.date,tm.section,tdspay=m.net_amt
,TDSAmt=mall.new_all,scamt=mall.new_all,ecamt=mall.new_all,hcamt=mall.new_all,TotTDSAmt=mall.new_all
--,ac_mast.ac_name,ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip,ac_mast.i_tax
,mall.entry_all,mall.main_tran,mall.acseri_all 
into #table1
from tdsmain_vw m
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd) 
inner join mainall_vw mall on (ac.entry_ty=mall.entry_ty and ac.tran_cd=mall.tran_cd and ac.acserial=mall.acserial)
inner join ac_mast on (ac_mast.ac_id=ac.ac_id)
inner join #TDSMASTER tm on (m.svc_cate=tm.svc_cate)
where 1=2
 
set @SqlCommand = 'insert into #table1 Select ac_mast.ac_id,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode' /*m.entry_ty,m.tran_cd,ac.acserial,mall.new_all,*/
set @SqlCommand=RTRIM(@SqlCommand)+' '+',m1.svc_cate,m1.TDSonAmt,m1.date,tm.section,tdspay=m1.net_amt'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',TDSAmt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',scamt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',ecamt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',hcamt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',TotTDSAmt=sum(case when AC_MAST1.TYP IN (''TDS'',''TDS-SUR'',''TDS-ECESS'',''TDS-HCESS'') then new_all else 0 end)'
/*set @SqlCommand=RTRIM(@SqlCommand)+' '+',TDSAmt=sum(case when AC_MAST.TYP IN (''TDS'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',scamt=sum(case when AC_MAST1.TYP IN (''TDS-SUR'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',ecamt=sum(case when AC_MAST1.TYP IN (''TDS-ECESS'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',hcamt=sum(case when AC_MAST1.TYP IN (''TDS-HCESS'') then new_all else 0 end)'*/
/*set @SqlCommand=RTRIM(@SqlCommand)+' '+',ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip,ac_mast.i_tax'*/
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran,mall.acseri_all'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'from tdsmain_vw m'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd) '
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join mainall_vw mall on (ac.entry_ty=mall.entry_ty and ac.tran_cd=mall.tran_cd and ac.acserial=mall.acserial)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join ac_mast ac_mast1 on (ac_mast1.ac_id=ac.ac_id)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join tdsmain_vw m1 on (m1.entry_ty=mall.entry_all and m1.tran_cd=mall.main_tran)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join ac_mast on (ac_mast.ac_id=m1.ac_id)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join #TDSMASTER tm on (m1.svc_cate=tm.svc_cate)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+rtrim(@fcon)
set @SqlCommand=RTRIM(@SqlCommand)+' '+' and isnull(mall.new_all,0)>0 '
set @SqlCommand=RTRIM(@SqlCommand)+' '+' and AC_MAST1.TYP IN (''TDS'',''TDS-ECESS'',''TDS-HCESS'',''TDS-SUR'')'
set @SqlCommand=RTRIM(@SqlCommand)+' '+' group by ac_mast.ac_id,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',m1.svc_cate,m1.TDSonAmt,m1.date,tm.section,m1.net_amt'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran,mall.acseri_all'
PRINT @SQLCOMMAND  
EXECUTE SP_EXECUTESQL @SQLCOMMAND 

Select m.Entry_ty,m.Tran_cd
,TDSAmt=sum(case when AC_MAST1.TYP IN ('TDS') then amount else 0 end)
,scamt=sum(case when AC_MAST1.TYP IN ('TDS-SUR') then amount else 0 end)
,ecamt=sum(case when AC_MAST1.TYP IN ('TDS-ECESS') then amount else 0 end)
,hcamt=sum(case when AC_MAST1.TYP IN ('TDS-HCESS') then amount else 0 end)
into #lac1
from tdsmain_vw m 
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
inner join ac_mast ac_mast1 on (ac_mast1.ac_id=ac.ac_id)
where ac.date<=@edate and ac.amt_ty='CR'
group by m.Entry_ty,m.Tran_cd

update a set a.tdsamt=b.tdsamt,a.scamt=b.scamt,a.ecamt=b.ecamt,a.hcamt=b.hcamt
from #table1 a inner join #lac1 b on (b.entry_ty=a.entry_all and b.tran_cd=a.main_tran)

 DECLARE @QUARTER VARCHAR(20),@ACK_NO VARCHAR(50),@QUARTER1 VARCHAR(20),@QUARTER2 VARCHAR(20),@QUARTER3 VARCHAR(20),@QUARTER4 VARCHAR(20)  
 SELECT @QUARTER=CASE DATEPART(qq,@EDATE) WHEN '1' THEN '4'  
   WHEN '2' THEN '1'  
   WHEN '3' THEN '2'  
   WHEN '4' THEN '3' END  
 --SET @ACK_NO=''  
 --SELECT @ACK_NO=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER=@QUARTER   
PRINT 'S1'+@QUARTER
if @QUARTER='1'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	set @QUARTER2=''
	set @QUARTER3=''
	set @QUARTER4=''
end
if @QUARTER='2'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
	set @QUARTER3=''
	set @QUARTER4=''
end
if @QUARTER='3'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
	SELECT @QUARTER3=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='3'   
	set @QUARTER4=''
end
if @QUARTER='4'  
Begin
	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
	SELECT @QUARTER3=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='3'   
	SELECT @QUARTER4=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='4'   
end 
/*print '-----'
PRINT @QUARTER1
PRINT @QUARTER2
PRINT @QUARTER3
PRINT @QUARTER4*/



select  
a.*,QUARTER1=isnull(@QUARTER1,''),QUARTER2=isnull(@QUARTER2,''),QUARTER3=isnull(@QUARTER3,''),QUARTER4=isnull(@QUARTER4,'') 
,ac_mast.ac_name,ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip,ac_mast.i_tax
from #table1 a
inner join ac_mast on (a.ac_id=ac_mast.ac_id)
ORDER BY Ac_mast.AC_NAME,A.SVC_CATE,A.DATE,a.entry_all,a.main_tran

/*
--SELECT MVW.ENTRY_TY,MVW.TRAN_CD,MVW.DATE,MVW.TDSONAMT,MVW.TDSAMT,MVW.SCAMT,MVW.ECAMT,MVW.HCAMT,MVW.SVC_CATE,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.I_TAX INTO #TBLNAME1 FROM TDSMAIN_VW MVW inner join AC_MAST on (mvw.ac_id=ac_mast.ac_id) where 1=2

-- SET @SQLCOMMAND = 'INSERT INTO #TBLNAME1 SELECT MVW.ENTRY_TY,MVW.TRAN_CD,MVW.DATE,MVW.TDSONAMT,MVW.TDSAMT,MVW.SCAMT,MVW.ECAMT,MVW.HCAMT,MVW.SVC_CATE,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.I_TAX FROM TDSMAIN_VW MVW inner join AC_MAST on (mvw.ac_id=ac_mast.ac_id) '+RTRIM(@FCON)+'  AND MVW.SVC_CATE <> '' '''  
-- PRINT @SQLCOMMAND  
-- EXECUTE SP_EXECUTESQL @SQLCOMMAND  
--
--SELECT DISTINCT SVC_CATE,SECTION INTO #TBLNAME2 FROM TDSMASTER  
-- 
--/*  
-- SET @SQLCOMMAND = ''  
-- SET @SQLCOMMAND = 'SELECT DISTINCT A.*,C.NET_AMT AS TDSPAY,C.CHEQ_NO,C.U_CHALNO,C.U_CHALDT,C.BSRCODE,E.SECTION FROM '+@TBLNAME1+' A '  
-- SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner JOIN MAINALL_VW B ON (A.ENTRY_TY=B.ENTRY_ALL  AND A.TRAN_CD = B.MAIN_TRAN) '  
-- SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner JOIN TDSMAIN_VW C ON (C.ENTRY_TY=B.ENTRY_TY and C.TRAN_CD = B.TRAN_CD) '  
-- SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner JOIN AC_MAST D ON (D.AC_ID=B.AC_ID and left(D.TYP,3)=''TDS'') '   
-- SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'LEFT JOIN '+@TBLNAME2+' E ON (E.SVC_CATE=A.SVC_CATE)'   
-- SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' ORDER BY A.AC_NAME,A.SVC_CATE'  
-- PRINT @SQLCOMMAND  
-- EXECUTE SP_EXECUTESQL @SQLCOMMAND  
--*/  
--SELECT * FROM  #TBLNAME1  
-- DECLARE @QUARTER VARCHAR(20),@ACK_NO VARCHAR(50),@QUARTER1 VARCHAR(20),@QUARTER2 VARCHAR(20),@QUARTER3 VARCHAR(20),@QUARTER4 VARCHAR(20)  
-- SELECT @QUARTER=CASE DATEPART(qq,@EDATE) WHEN '1' THEN '4'  
--   WHEN '2' THEN '1'  
--   WHEN '3' THEN '2'  
--   WHEN '4' THEN '3' END  
-- --SET @ACK_NO=''  
-- --SELECT @ACK_NO=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER=@QUARTER   
--PRINT 'S1'+@QUARTER
--if @QUARTER='1'  
--Begin
--	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
--	set @QUARTER2=''
--	set @QUARTER3=''
--	set @QUARTER4=''
--end
--if @QUARTER='2'  
--Begin
--	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
--	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
--	set @QUARTER3=''
--	set @QUARTER4=''
--end
--if @QUARTER='3'  
--Begin
--	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
--	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
--	SELECT @QUARTER3=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='3'   
--	set @QUARTER4=''
--end
--if @QUARTER='4'  
--Begin
--	SELECT @QUARTER1=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='1'   
--	SELECT @QUARTER2=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='2'   
--	SELECT @QUARTER3=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='3'   
--	SELECT @QUARTER4=isnull(ACKNOW_NO,'') FROM TDSACKNOW WHERE L_YN=@FINYR AND QUARTER='4'   
--end 
--
--PRINT @QUARTER1
--PRINT @QUARTER2
----PRINT @QUARTER3
----PRINT @QUARTER4
--
-- 
-- SELECT DISTINCT A.*,C.NET_AMT AS TDSPAY,C.CHEQ_NO,C.U_CHALNO,C.DATE AS U_CHALDT,C.BSRCODE,E.SECTION,QUARTER=isnull(rtrim(@QUARTER),''),QUARTER1=isnull(rtrim(@QUARTER1),''),QUARTER2=isnull(RTRIM(@QUARTER2),''),QUARTER3=isnull(rtrim(@QUARTER3),''),QUARTER4=isnull(rtrim(@QUARTER4),'')
-- FROM #TBLNAME1 A   
-- INNER JOIN MAINALL_VW B ON (A.ENTRY_TY=B.ENTRY_ALL  AND A.TRAN_CD = B.MAIN_TRAN )   
-- INNER JOIN AC_MAST ON (AC_MAST.AC_ID=B.AC_ID AND AC_MAST.TYP IN ('TDS','TDS-ECESS','TDS-HCESS','TDS-SUR')) 
-- INNER JOIN TDSMAIN_VW C ON (C.ENTRY_TY=B.ENTRY_TY and C.TRAN_CD = B.TRAN_CD)   
-- LEFT JOIN #TBLNAME2 E ON (E.SVC_CATE=A.SVC_CATE)   
-- UNION ALL  
-- SELECT DISTINCT A.*,C.NET_AMT AS TDSPAY,C.CHEQ_NO,C.U_CHALNO,C.DATE AS U_CHALDT,C.BSRCODE,E.SECTION,QUARTER=isnull(rtrim(@QUARTER),''),QUARTER1=isnull(rtrim(@QUARTER1),''),QUARTER2=isnull(RTRIM(@QUARTER2),''),QUARTER3=isnull(rtrim(@QUARTER3),''),QUARTER4=isnull(rtrim(@QUARTER4),'')
-- FROM #TBLNAME1 A   
-- LEFT JOIN MAINALL_VW B ON (A.ENTRY_TY=B.ENTRY_TY  AND A.TRAN_CD = B.TRAN_CD)   
-- INNER JOIN AC_MAST ON (AC_MAST.AC_ID=B.AC_ID AND AC_MAST.TYP IN ('TDS','TDS-ECESS','TDS-HCESS','TDS-SUR'))   
-- LEFT JOIN TDSMAIN_VW C ON (C.ENTRY_TY=B.ENTRY_ALL and C.TRAN_CD = B.MAIN_TRAN)   
-- LEFT JOIN #TBLNAME2 E ON (E.SVC_CATE=A.SVC_CATE)   
-- ORDER BY A.AC_NAME,A.SVC_CATE,A.DATE,C.DATE  
-- PRINT @SQLCOMMAND  
-- EXECUTE SP_EXECUTESQL @SQLCOMMAND  
*/
GO
