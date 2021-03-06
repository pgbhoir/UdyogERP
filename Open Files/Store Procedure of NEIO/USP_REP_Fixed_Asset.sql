DROP PROCEDURE [USP_REP_Fixed_Asset]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shrikant Shedekar.
-- Create date: 21/03/2010
-- Description:	This Stored procedure is useful to generate ACCOUNTS  Fixed Asset Statement Report.
-- Modify date: 21/03/2010
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_Fixed_Asset]  
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
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000),@DIFFDAY as numeric(5)
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
,@VMAINFILE='M',@VITFILE=Null,@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

PRINT @FCON
--EXECUTE USP_REP_FIXED_ASSET '','','','04/01/2007','03/31/2008','1% HIGHER EDU.CESS                                          ','ZAMFABAR CORPORATION                                        ','','',0,99999999999.00,'','','','WASTE & SCRAP       ','','','','YAWAT               ','2007-2008',''
SET @DIFFDAY = convert(int,@edate) - convert(int,@sdate) + 1
DECLARE @GRPID AS INT,@MCOND AS BIT,@LVL  AS INT,@GRP AS VARCHAR(100)

SELECT ENTRY_TY,BHENT=(CASE WHEN EXT_VOU=0 THEN ENTRY_TY ELSE BCODE_NM END) INTO #LCODE FROM LCODE

SET @GRP='FIXED ASSETS'
CREATE TABLE #ACGRPID (GACID DECIMAL(9),LVL DECIMAL(9))
SET @LVL=0
INSERT INTO #ACGRPID SELECT AC_GROUP_ID,@LVL  FROM AC_GROUP_MAST WHERE AC_GROUP_NAME=@GRP
SET @MCOND=1
WHILE @MCOND=1
BEGIN
	IF EXISTS (SELECT AC_GROUP_ID FROM AC_GROUP_MAST WHERE GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL)) --WHERE LVL=@LVL
	BEGIN
		PRINT @LVL
		INSERT INTO #ACGRPID SELECT AC_GROUP_ID,@LVL+1 FROM AC_GROUP_MAST WHERE GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL)
		SET @LVL=@LVL+1
	END
	ELSE
	BEGIN
		SET @MCOND=0	
	END
END
SELECT AC_ID,AC_NAME INTO #ACMAST FROM AC_MAST WHERE  AC_GROUP_ID IN (SELECT DISTINCT GACID FROM #ACGRPID)

SELECT A.AC_NAME,AC.ENTRY_TY,A.I_RATE,AC.AMT_TY,AC.AMOUNT,AC.DATE,M.L_YN,AC.TRAN_CD,BHENT=AC.ENTRY_TY,CAST(' ' AS VARCHAR(50)) AS U_NATURE,CAST(' ' AS DATETIME) AS U_NATUREDT,CAST(0 AS NUMERIC(20,2)) AS DEPRE INTO #FIXASSET FROM LAC_VW AC INNER JOIN LMAIN_VW M ON (AC.ENTRY_TY=M.ENTRY_TY AND AC.TRAN_CD=M.TRAN_CD) INNER JOIN AC_MAST A ON (A.AC_ID=AC.AC_ID) WHERE 1=2

SET @SQLCOMMAND='INSERT INTO #FIXASSET (AC_NAME,ENTRY_TY,I_RATE,AMT_TY,DATE,AMOUNT,L_YN,TRAN_CD,BHENT,U_NATURE,U_NATUREDT,DEPRE)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT AC_MAST.AC_NAME,AC.ENTRY_TY,AC_MAST.I_RATE,AC.AMT_TY,AC.DATE,AC.AMOUNT,AC.L_YN,AC.TRAN_CD,L.BHENT,ISNULL(J.U_NATURE,'' '' ),CAST('' '' AS DATETIME),0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'FROM LAC_VW AC '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN LMAIN_VW M ON (AC.ENTRY_TY=M.ENTRY_TY AND AC.TRAN_CD=M.TRAN_CD)' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=AC.AC_ID)' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN #ACMAST A1 ON (AC_MAST.AC_ID=A1.AC_ID)' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN #LCODE L ON (AC.ENTRY_TY=L.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'LEFT JOIN JVMAIN J ON (J.ENTRY_TY=M.ENTRY_TY AND J.TRAN_CD=M.TRAN_CD)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
EXECUTE SP_EXECUTESQL @SQLCOMMAND


DELETE FROM #FIXASSET WHERE BHENT IN ('OB') AND L_YN = @LYN AND AC_NAME IN (SELECT AC_NAME FROM #FIXASSET WHERE L_YN < @LYN GROUP BY AC_NAME) 

SELECT AC_NAME,MAX(DATE) AS DATE INTO #FIXASSET1 FROM #FIXASSET WHERE RTRIM(LTRIM(U_NATURE))='DEPRECIATION' GROUP BY AC_NAME

UPDATE #FIXASSET SET U_NATUREDT = B.DATE FROM #FIXASSET A,#FIXASSET1 B WHERE A.AC_NAME = B.AC_NAME 




Declare @i int,@tmp_lyn Varchar(10),@cnt int,@tmpSdate smalldatetime,@tmpEdate smalldatetime,@nDays int,@tmpIntPaid Numeric (15,2),@YearCnt Int,@tmpDate smalldatetime 
Set @tmpDate=(Select top 1 Date From #FIXASSET Order by Date)
set @tmp_lyn=dbo.finYear(@tmpDate)

set @i=0
set @cnt=0
Create Table #tblYear(lyn Varchar(10),Sdate smalldatetime,Edate Smalldatetime,nDays Numeric,YearCnt Int identity)
While @i<=10
Begin
	set @cnt=dbo.DaysofYear(@tmp_lyn)
	Insert Into #tblYear Values(@tmp_lyn,convert(smalldatetime,'04/01/'+left(rtrim(@tmp_lyn),4)),convert(smalldatetime,'03/31/'+right(rtrim(@tmp_lyn),4)),@cnt)
	set @tmp_lyn=convert(varchar(4),convert(int,left(rtrim(@tmp_lyn),4))+1)+'-'+convert(varchar(4),convert(int,right(rtrim(@tmp_lyn),4))+1)
	set @i=@i+1
End

Select @YearCnt=YearCnt from #tblYear where lyn=dbo.finYear(@Sdate) 
Select @nDays =nDays from #tblYear Where lyn=dbo.finYear(@tmpDate)


Select Ac_name,Opening=Amount
			,Receipt1=Amount,Receipt2=Amount,Issue=Amount,PrevDepre=Amount,CurrDepre=Amount,Closing =Amount,i_Rate,Date,l_yn Into #FXSTAT2 from #FIXASSET WHERE 1=2	

if dbo.finYear(@tmpDate)=dbo.finYear(@Sdate)
	Begin
		print 'a'	
		SELECT AC_NAME
		,OPBAL  = (CASE WHEN (BHENT='OB' And DATE <= @SDATE) THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
		,RECEIPT1= (CASE WHEN NOT (BHENT='OB') AND DATE <= @EDATE AND [dbo].[FixAssetPeriod](DATE)=1 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
		,RECEIPT2= (CASE WHEN NOT (BHENT='OB') AND DATE <= @EDATE AND [dbo].[FixAssetPeriod](DATE)=2 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
		,ISSUE  = (CASE WHEN NOT (BHENT='OB') AND DATE <= @EDATE AND AMT_TY='CR' THEN AMOUNT ELSE 0 END)
		,DEPRE,U_NATURE,U_NATUREDT,I_RATE,DATE,l_yn
		INTO #FXSTAT FROM #FIXASSET WHERE RTRIM(LTRIM(U_NATURE))<>'DEPRECIATION' 
		ORDER BY AC_NAME

		Insert Into #FXSTAT2 Select Ac_name
		,Opbal,Receipt1,Receipt2,Issue
		,PrevDepre=Case When Date <@Sdate then 
					Datediff(d,@tmpDate,@Sdate) * ((Opbal+Receipt1-Issue) * i_Rate)/100 / @nDays
						+(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@Sdate)) * Receipt2 * i_Rate /100 / @nDays
					Else (Case when Receipt1<>0 or Issue<>0 Then Datediff(d,@tmpDate,@Sdate) * ((Receipt1-Issue) * i_Rate)/100 / @nDays 
							else 0 end) End
	
		,CurrDepre=(Datediff(d,@Sdate,@Edate) + 1) * ((Opbal+Receipt1-Issue) * i_Rate)/100 / @nDays
							+Case When Date Between @Sdate and @Edate Then
								(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@Edate) + 1) * Receipt2 * i_Rate /100 / @nDays
							Else (Datediff(d,@Sdate,@Edate) + 1) * Receipt2 * i_Rate /100 / @nDays End
		,Closing =0,I_Rate,Date,l_yn from #FXSTAT

		Update #FXSTAT2 set Opening=Opening-PrevDepre
							+(Case when Date <@Sdate then Receipt1 else 0 End)
							+(Case when Date <@Sdate then Receipt2 else 0 End)
							-(Case when Date <@Sdate then Issue else 0 End)
		Update #FXSTAT2 set Receipt1=(Case when Date Between @Sdate and @Edate then Receipt1 else 0 End),
							Receipt2=(Case when Date Between @Sdate and @Edate then Receipt2 else 0 End),
							Issue=(Case when Date Between @Sdate and @Edate then Issue else 0 End)

		Update #FXSTAT2 set Closing=Opening+Receipt1+Receipt2-Issue-CurrDepre
		Drop table #FXSTAT
	End
Else
	Begin
		print 'b'	
		Select @i=YearCnt,@nDays=nDays,@tmpSdate=Sdate,@tmpEdate=Edate,@tmp_lyn=lyn from #tblYear where lyn=dbo.finYear(@tmpDate) 
		SELECT AC_NAME
		,OPBAL  = (CASE WHEN (BHENT='OB' And DATE <= @tmpSdate) THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
		,RECEIPT1= (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND [dbo].[FixAssetPeriod](DATE)=1 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
		,RECEIPT2= (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND [dbo].[FixAssetPeriod](DATE)=2 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
		,ISSUE  = (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND AMT_TY='CR' THEN AMOUNT ELSE 0 END)
		,DEPRE,U_NATURE,U_NATUREDT,I_RATE,DATE,L_YN
		INTO #FXSTATM FROM #FIXASSET WHERE RTRIM(LTRIM(U_NATURE))<>'DEPRECIATION' AND L_YN=dbo.finYear(@tmpDate) 
		ORDER BY AC_NAME
		
		Insert Into #FXSTAT2 Select Ac_name
		,Opbal=Opbal+Receipt1+Receipt2-Issue
				-(Datediff(d,@tmpSdate,@tmpEdate)+1) * ((Opbal+Receipt1-Issue) * i_Rate/100 / @nDays)
					-(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@tmpEdate)+1) * Receipt2 * i_Rate /100 / @nDays
		,Receipt1=0,Receipt2=0,Issue=0,PrevDepre=0,CurrDepre=0
		,Closing =0,I_Rate,Date,l_yn from #FXSTATM
		
		set @i=@i+1
		Select @tmpSdate=Sdate,@tmpEdate=Edate,@nDays=nDays,@tmp_lyn=lyn from #tblYear where YearCnt=@i
		Update #FXSTAT2 set Date=@tmpSdate,l_yn=@tmp_lyn,@tmpDate=@tmpSdate 

--Delete from #FXSTAT2 
		while @i<@YearCnt
		Begin
			print 'c'
				Update #FXSTAT2 set Opening=Opening				
									-(Datediff(d,@tmpSdate,@tmpEdate)+1) * ((Opening) * i_Rate/100 / @nDays)

				INSERT INTO #FXSTATM SELECT AC_NAME
				,OPBAL  = (CASE WHEN (BHENT='OB' And DATE <= @tmpSdate) THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
				,RECEIPT1= (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND [dbo].[FixAssetPeriod](DATE)=1 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
				,RECEIPT2= (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND [dbo].[FixAssetPeriod](DATE)=2 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
				,ISSUE  = (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND AMT_TY='CR' THEN AMOUNT ELSE 0 END)
				,DEPRE,U_NATURE,U_NATUREDT,I_RATE,DATE,L_YN
				FROM #FIXASSET WHERE RTRIM(LTRIM(U_NATURE))<>'DEPRECIATION' AND L_YN=@tmp_lyn 
				ORDER BY AC_NAME
			
				Insert Into #FXSTAT2 Select Ac_name
					,Opbal=Opbal+Receipt1+Receipt2-Issue
						-(Datediff(d,@tmpSdate,@tmpEdate)+1) * ((Opbal+Receipt1-Issue) * i_Rate/100 / @nDays)
						-(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@tmpEdate)+1) * Receipt2 * i_Rate /100 / @nDays
						,Receipt1=0,Receipt2=0,Issue=0,PrevDepre=0,CurrDepre=0
						,Closing =0,I_Rate,Date,l_yn from #FXSTATM where L_YN=@tmp_lyn  

			set @i=@i+1
			Select @tmpSdate=Sdate,@tmpEdate=Edate,@nDays=nDays,@tmp_lyn=lyn from #tblYear where YearCnt=@i
			Update #FXSTAT2 set Date=@tmpSdate,l_yn=@tmp_lyn,@tmpDate=@tmpSdate 
		End
		

		Select @i=YearCnt,@nDays=nDays,@tmpSdate=Sdate,@tmpEdate=Edate,@tmp_lyn=lyn from #tblYear where lyn=dbo.finYear(@tmpDate) 
		INSERT INTO #FXSTATM SELECT AC_NAME
		,OPBAL  = (CASE WHEN (BHENT='OB' And DATE <= @tmpSdate) THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
		,RECEIPT1= (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND [dbo].[FixAssetPeriod](DATE)=1 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
		,RECEIPT2= (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND [dbo].[FixAssetPeriod](DATE)=2 AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
		,ISSUE  = (CASE WHEN NOT (BHENT='OB') AND DATE <= @tmpEdate AND AMT_TY='CR' THEN AMOUNT ELSE 0 END)
		,DEPRE,U_NATURE,U_NATUREDT,I_RATE,DATE,L_YN
		FROM #FIXASSET WHERE RTRIM(LTRIM(U_NATURE))<>'DEPRECIATION' AND L_YN=@tmp_lyn 
		ORDER BY AC_NAME
		PRINT 'S4'
		PRINT @nDays
		PRINT @tmpDate

		Update #FXSTAT2 set PrevDepre=Case When Date <@Sdate then
									Datediff(d,@tmpDate,@Sdate) * ((Opening+Receipt1-Issue) * i_Rate)/100 / @nDays
								+(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@Sdate)) * Receipt2 * i_Rate /100 / @nDays 
					Else (Case when Receipt1<>0 or Issue<>0 Then Datediff(d,@tmpDate,@Sdate) * ((Receipt1-Issue) * i_Rate)/100 / @nDays else 0 end) End

		,CurrDepre=(Datediff(d,@Sdate,@Edate) + 1) * ((Opening+Receipt1-Issue) * i_Rate)/100 / @nDays
							+Case When Date Between @Sdate and @Edate Then
								(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@Edate) + 1) * Receipt2 * i_Rate /100 / @nDays
							Else (Datediff(d,@Sdate,@Sdate) + 1) * Receipt2 * i_Rate /100 / @nDays End 
		
		Insert Into #FXSTAT2 Select Ac_name
		,Opbal,Receipt1,Receipt2,Issue
		,PrevDepre=Case When Date <@Sdate then 
					Datediff(d,@tmpDate,@Sdate) * ((Opbal+Receipt1-Issue) * i_Rate)/100 / @nDays
						+(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@Sdate)) * Receipt2 * i_Rate /100 / @nDays
					Else (Case when Receipt1<>0 or Issue<>0 Then Datediff(d,@tmpDate,@Sdate) * ((Receipt1-Issue) * i_Rate)/100 / @nDays 
						else 0 end) End
		,CurrDepre=(Datediff(d,@Sdate,@Edate) + 1) * ((Opbal+Receipt1-Issue) * i_Rate)/100 / @nDays
							+Case When Date Between @Sdate and @Edate Then
								(Datediff(d,dbo.fixAsset2QDt(dbo.finYear(@tmpDate)),@Edate) + 1) * Receipt2 * i_Rate /100 / @nDays
							Else (Datediff(d,@Sdate,@Edate) + 1) * Receipt2 * i_Rate /100 / @nDays End
		,Closing=0,I_Rate,Date,l_yn from #FXSTATM where L_YN=@tmp_lyn 

		Update #FXSTAT2 set Opening=Opening-PrevDepre
							+(Case when Date <@Sdate then Receipt1 else 0 End)
							+(Case when Date <@Sdate then Receipt2 else 0 End)
							-(Case when Date <@Sdate then Issue else 0 End)
		Update #FXSTAT2 set Receipt1=(Case when Date Between @Sdate and @Edate then Receipt1 else 0 End),
							Receipt2=(Case when Date Between @Sdate and @Edate then Receipt2 else 0 End),
							Issue=(Case when Date Between @Sdate and @Edate then Issue else 0 End)

			Update #FXSTAT2 set Closing=Opening+Receipt1+Receipt2-Issue-CurrDepre
			set @i=@i+1
			Select @tmpSdate=Sdate,@tmpEdate=Edate,@nDays=nDays,@tmp_lyn=lyn from #tblYear where YearCnt=@i
			Update #FXSTAT2 set Date=@tmpSdate,l_yn=@tmp_lyn,@tmpDate=@tmpSdate 
		End
		--Drop table #FXSTATM 
	

Select Ac_name,Opening=Sum(Opening)
			,Receipt1=Sum(Receipt1),Receipt2=Sum(Receipt2),Issue=Sum(Issue),PrevDepre=Sum(PrevDepre),CurrDepre=Sum(CurrDepre),Closing =Sum(Closing),i_Rate 
			from #FXSTAT2 
			Group By Ac_name,I_Rate

Drop table #FIXASSET

Drop table #FXSTAT2
GO
