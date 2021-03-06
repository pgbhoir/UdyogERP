DROP PROCEDURE [USP_REP_Emp_Payroll_Declaration_Master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Ramya
-- Create date: 12/07/2012
-- Description:	This is useful for Section Master Report
-- Modify date: 
-- Remark:
-- =============================================

--EXECUTE [USP_REP_Emp_Payroll_Declaration_Master] '','','','','','','','','',0,0,'','','','','','','','','',''

Create PROCEDURE [USP_REP_Emp_Payroll_Declaration_Master]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(1000)
AS
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)

	
	EXECUTE USP_REP_FILTCON 
		@VTMPAC=null,@VTMPIT=@TMPIT,@VSPLCOND=@SPLCOND,
		@VSDATE=@SDATE,@VEDATE=@EDATE,
		@VSAC =null,@VEAC =null,
		@VSIT=@SIT,@VEIT=@EIT,
		@VSAMT=null,@VEAMT=null,
		@VSDEPT=@SDEPT,@VEDEPT=@EDEPT,
		@VSCATE =@SCATE,@VECATE =@ECATE,
		@VSWARE =@SWARE,@VEWARE  =@EWARE,
		@VSINV_SR =@SINV_SR,@VEINV_SR =@EINV_SR,
		@VMAINFILE='',@VITFILE='',@VACFILE=null,
		@VDTFLD = '',@VLYN=null,@VEXPARA=@EXPARA,
		@VFCON =@FCON OUTPUT

BEGIN
SELECT a.* FROM Emp_Payroll_Declaration_Master a inner join Emp_Payroll_Section_Master b on(a.section=b.section) order by b.Sortord,a.sortord
END
GO
