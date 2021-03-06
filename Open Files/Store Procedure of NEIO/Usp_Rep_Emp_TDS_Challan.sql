DROP PROCEDURE [Usp_Rep_Emp_TDS_Challan]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI
-- CREATE DATE: 20/04/2009
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE Employee TDS CHALLAN REPORT.
-- MODIFY DATE/BY/Reason:
-- REMARK:
-- =============================================
CREATE PROCEDURE   [Usp_Rep_Emp_TDS_Challan]
	@ENTRYCOND NVARCHAR(254)
AS
Begin
	SET QUOTED_IDENTIFIER OFF
	DECLARE @SQLCOMMAND NVARCHAR(4000),@FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
	Select Tran_cd into #TDSChal From CRItem where 1=2
	
		declare @ent varchar(2),@trn int,@pos1 int,@pos2 int,@pos3 int--,@ENTRYCOND NVARCHAR(254)
		if(charindex('m.Date between',@ENTRYCOND)>0) /*Sp Called from USP_REP_EMP_TDS_CHALLAN_MENU*/
		begin
			set @SQLCOMMAND='insert into #TDSChal Select Tran_Cd From Bpmain m where Entry_ty=''TH'' and '+@ENTRYCOND
			execute Sp_ExecuteSql @SQLCOMMAND
		end
		else/*Sp Called from Voucher*/
		Begin
			/*--->Entry_Ty and Tran_Cd Separation*/
			print @ENTRYCOND
			set @pos1=charindex('''',@ENTRYCOND,1)+1
			set @ent= substring(@ENTRYCOND,@pos1,2)
			set @pos2=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos1))+1
			set @pos3=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos2))+1
			set @trn= substring(@ENTRYCOND,@pos2,@pos2-@pos3)
			print 'ent '+ @ent
			print @trn
			insert into #TDSChal (Tran_cd) values (@trn)
			/*<---Entry_Ty and Tran_Cd Separation*/
		end
		
	--EXECUTE Usp_Rep_Emp_TDS_Challan "A.ENTRY_TY = 'TH' AND A.TRAN_CD =1373 " 
	SELECT DISTINCT TM.SVC_CATE,TM.SECTION,TM.SEC_CODE,
	M.L_YN ,CHALNO=ISNULL(M.U_CHALNO,''),CHALDT=ISNULL(M.U_CHALDT,''),M.CHEQ_NO,M.DATE,BANK_NM=ISNULL(M.BANK_NM,'') 
	,TDS=(CASE WHEN A.TYP in ('TDS','TCS','TDS192','TDS192B') THEN AC.AMOUNT ELSE 0 END)   /*Ramya added for bug-9106*/
	,TDSSUR=(CASE WHEN A.TYP in ('TDS-SUR','TCS-SUR') THEN AC.AMOUNT ELSE 0 END) 
	,TDSECESS=(CASE WHEN A.TYP in ('TDS-ECESS','TCS-ECESS') THEN AC.AMOUNT ELSE 0 END) 
	,TDSHCESS=(CASE WHEN A.TYP in ('TDS-HCESS','TCS-HCESS') THEN AC.AMOUNT ELSE 0 END)
	,DRAWN_ON=ISNULL(M.DRAWN_ON,'') 
	,AC.Ac_Name
	INTO #TDSCHAL1
	FROM BpMain M 
	INNER JOIN BpAcDet AC ON (M.ENTRY_TY=AC.ENTRY_TY AND M.TRAN_CD=AC.TRAN_CD) 
	INNER JOIN AC_MAST A ON (AC.AC_ID=A.AC_ID)
	--INNER JOIN TDSMASTER TM ON ('"'+rtrim(AC.Ac_Name)+'"'=rtrim(TM.TDSPosting)) 
	INNER JOIN TDSMASTER TM ON ('"'+rtrim(AC.Ac_Name)+'"'=rtrim(TM.CTPOSTING) or '"'+rtrim(AC.Ac_Name)+'"'=rtrim(TM.STPOSTING) or '"'+rtrim(AC.Ac_Name)+'"'=rtrim(TM.ITPOSTING))
	inner join #TDSChal tem on (tem.Tran_cd=m.Tran_cd)
	where ISNULL(Tm.SVC_CATE,'')<>''


	SELECT SVC_CATE,SECTION,SEC_CODE,CHALNO,CHALDT,CHEQ_NO,DATE,BANK_NM,L_YN
	,TDS=SUM(TDS),TDSSUR=SUM(TDSSUR),TDSECESS=SUM(TDSECESS),TDSHCESS=SUM(TDSHCESS),DRAWN_ON
	FROM #TDSCHAL1
	GROUP BY SVC_CATE,SECTION,SEC_CODE,CHALNO,CHALDT,CHEQ_NO,DATE,BANK_NM,L_YN,DRAWN_ON
end
GO
