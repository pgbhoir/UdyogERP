DROP PROCEDURE [USP_REP_P4_BILL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shrikant S.
-- Create date: 03/11/2011
-- Description:	This Stored procedure is useful to generate Service Tax Proforma Bill .
-- Remark:
-- =============================================
Create PROCEDURE [USP_REP_P4_BILL]
	@ENTRYCOND NVARCHAR(254)
	AS
begin	
	Declare @SQLCOMMAND as NVARCHAR(4000),@TBLCON as NVARCHAR(4000)
	
	select distinct code,[name] into #SERTAX_MAST from SERTAX_MAST
	/*--->Entry_Ty and Tran_Cd Separation*/
		declare @ent varchar(2),@trn int,@pos1 int,@pos2 int,@pos3 int--,@ENTRYCOND NVARCHAR(254)
		print @ENTRYCOND
		set @pos1=charindex('''',@ENTRYCOND,1)+1
		set @ent= substring(@ENTRYCOND,@pos1,2)
		set @pos2=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos1))+1
		set @pos3=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos2))+1
		set @trn= substring(@ENTRYCOND,@pos2,@pos2-@pos3)
		print 'ent '+ @ent
		print @trn
		--select * from bpmain where entry_ty=@ent and tran_cd=@trn
	/*<---Entry_Ty and Tran_Cd Separation*/
	
	SELECT m.INV_SR,m.TRAN_CD,m.ENTRY_TY,m.INV_NO,m.DATE
	,al.SERTY,al.sabtper,al.sabtamt,al.staxable,al.amount
	,SM.CODE,m.SERBPER,m.SERBAMT,m.SERCPER,m.SERCAMT,m.SERHPER,m.SERHAMT,m.DUE_DT,m.GRO_AMT GRO_AMT1,m.TAX_NAME,m.TAXAMT,m.NET_AMT
	,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.S_TAX,AC_MAST.I_TAX,AC_MAST.ECCNO,AC_MAST.SREGN
	FROM P4MAIN M  
	INNER JOIN AC_MAST ON (AC_MAST.AC_ID=m.AC_ID) 
	Inner Join AcDetAlloc al on (m.entry_ty=al.entry_ty  and m.tran_cd=al.tran_cd)
	LEFT JOIN #SERTAX_MAST SM ON (SM.[NAME]=al.SERTY)  
	WHERE  m.ENTRY_TY= 'P4' and m.tran_cd=@trn
	ORDER BY m.INV_SR,m.INV_NO  

end
GO
