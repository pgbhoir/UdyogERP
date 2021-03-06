DROP PROCEDURE [Usp_Rep_Leave_Maintenance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date:
-- Description:	This Stored Procedure is useful for Leave Maintance Details in reports
-- =============================================
Create procedure [Usp_Rep_Leave_Maintenance]
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
BEGIN
DECLARE @FCON AS NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=null
,@VEDATE=null
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='e',@VITFILE='',@VACFILE=' '
,@VDTFLD =''
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

if(@FCON='')
begin
	set @FCON=' where 1=1'
end 	
set @FCON=replace(@FCON,'Dept','Department')
set @FCON=replace(@FCON,'Cate','Category')
print @FCON
Declare @SQLCOMMAND as NVARCHAR(4000)

--@Loc_Desc varchar(30),
--@Year varchar(30),
--@Month varchar(30),
--@EmployeeName varchar(50)
--
--as
--begin
Declare @Pay_Year varchar(30),@Pay_Month varchar(30),@EmpNm varchar(100)
Declare @POS INT
if(charindex('[Pay_Year=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX(']',@EXPARA)
	SET @Pay_Year=SUBSTRING(@EXPARA,11,@POS-11)
end 	

if(charindex('[Pay_Month=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[Pay_Month=',@EXPARA)
	SET @Pay_Month=SUBSTRING(@EXPARA,@POS+11,len(@EXPARA)-@pos)
	SET @Pay_Month=replace(@Pay_Month,'[Pay_Month=','')
	SET @POS=CHARINDEX(']',@Pay_Month)
	SET @Pay_Month=SUBSTRING(@Pay_Month,1,@pos)
	SET @Pay_Month=replace(@Pay_Month,']','')
end


if(charindex('[EmpNm=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[EmpNm=',@EXPARA)
	SET @EmpNm=SUBSTRING(@EXPARA,@POS+7,len(@EXPARA)-@pos)
	SET @EmpNm=replace(@EmpNm,']','')
end


Declare @mth int,@Att_Code varchar(4),@Att_Nm varchar(60)
SELECT @mth=DATEPART(mm,CAST(@Pay_Month+ ' 1900' AS DATETIME))

Declare cur_AttSet Cursor for Select Att_Code,Att_Nm From Emp_Attendance_Setting where isLeave=1 and lDeactive=0 order by SortOrd

open cur_AttSet
Fetch Next From cur_AttSet into @Att_Code,@Att_Nm
set @SqlCommand=''
while(@@Fetch_Status=0)
begin
	set @SqlCommand=rtrim(@SqlCommand)+ ',['+rtrim(@Att_Nm)+' Op Bal]='+rtrim(@Att_Code)+'_OpBal'
	set @SqlCommand=rtrim(@SqlCommand)+ ',['+rtrim(@Att_Nm)+' Credit]='+rtrim(@Att_Code)+'_Credit'
	set @SqlCommand=rtrim(@SqlCommand)+ ',['+rtrim(@Att_Nm)+' Availed]='+rtrim(@Att_Code)+'_Availed'
	set @SqlCommand=rtrim(@SqlCommand)+ ',['+rtrim(@Att_Nm)+' Encash]='+rtrim(@Att_Code)+'_Encash'
	set @SqlCommand=rtrim(@SqlCommand)+ ',['+rtrim(@Att_Nm)+' Balance]='+rtrim(@Att_Code)+'_Balance'
	Fetch Next From cur_AttSet into @Att_Code,@Att_Nm
end
close cur_AttSet
DeAllocate cur_AttSet
set @SqlCommand='Select l.Pay_Year as [Year],DateName( month , DateAdd( month , cast(l.Pay_Month as int), 0 )-1  ) as [Month]  ,l.EmployeeCode,e.EmployeeName as [Employee Name]'+rtrim(@SqlCommand)
set @SqlCommand=rtrim(@SqlCommand)+' '+',e.Department,lc.Loc_Desc as Location'
set @SqlCommand=rtrim(@SqlCommand)+' '+'From Emp_Leave_Maintenance l'
set @SqlCommand=rtrim(@SqlCommand)+' '+'inner Join EmployeeMast e on (e.EmployeeCode=l.EmployeeCode)'
set @SqlCommand=rtrim(@SqlCommand)+' '+'Left Join Loc_Master lc on (e.Loc_Code=lc.Loc_Code)'
set @SqlCommand=rtrim(@SqlCommand)+' '+'where 1=1  '

if isnull(@Pay_Year,'')<>''
begin
set @SqlCommand=rtrim(@SqlCommand)+' '+'and l.Pay_Year='+char(39)+@Pay_Year+char(39)
end

if isnull(@mth,'')<>''
begin
set @SqlCommand=rtrim(@SqlCommand)+' '+' and l.Pay_Month='+cast(@mth as varchar)
end


--if isnull(@Loc_Desc,'')<>''
--begin
--	set @SqlCommand=rtrim(@SqlCommand)+' '+' and lc.Loc_Desc='+char(39)+@Loc_Desc+char(39)
--end

if isnull(@EmpNm,'')<>''
begin
	set @SqlCommand=rtrim(@SqlCommand)+' '+' and E.EmployeeName='+char(39)+@EmpNm+char(39)
end

set @SqlCommand=rtrim(@SqlCommand)+' '+' Order by l.Pay_Year,l.Pay_Month '

print @SqlCommand
execute Sp_ExecuteSql @SqlCommand


end
GO
