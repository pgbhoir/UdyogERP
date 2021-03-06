IF EXISTS(SELECT * FROM SYSOBJECTS WHERE [NAME]='USP_ENT_CUSTMODACCUI_SELECT' AND XTYPE='P')
BEGIN
	DROP PROCEDURE USP_ENT_CUSTMODACCUI_SELECT
END
GO
Create Procedure [dbo].[USP_ENT_CUSTMODACCUI_SELECT]
@action varchar(10),
@id varchar(20)=''
--@custnm varchar(100)=''
As
Begin
	If rtrim(upper(@action)) = 'SELECT'
	Begin
		Select * From custfeature Where id=@id
		--Select distinct ccomp,0 as 'srno',cast(0 as bit) as 'select' From custmnutranrptdts Where fk_id=@id
		with duplicaterec as
		(
		select recid=row_number() over (Partition by ccomp,fk_id order by ccomp,fk_id),*
		from custmnutranrptdts
		)
		select id,ccomp,0 as 'srno',cast(0 as bit) as 'select' from DuplicateRec 
		Where recid = 1 and fk_id=@id

		Select 0 as 'srno',* From custmnutranrptdts Where fk_id=@id
		order by desc1
		--Select distinct ccomp From custmnutranrptdts Where fk_id=@id
		--Select * From custmnutranrptdts Where fk_id=@id and optiontype='MENU'
		--Select * From custmnutranrptdts Where fk_id=@id and optiontype='TRAN'
		--Select * From custmnutranrptdts Where fk_id=@id and optiontype='REPORT'
	End	
	If rtrim(upper(@action)) = 'NEW'
	Begin
		Select * From custfeature Where 1=2
		Select 0 as 'srno',ccomp,cast(0 as bit) as 'select' From custmnutranrptdts Where 1=2
		Select 0 as 'srno',* From custmnutranrptdts Where 1=2
		Select autoid = 'CM' + Case When count(*) = 0 then cast(1 as varchar(1)) else convert(varchar(20), max(convert(int, substring(id, 3, 100))) + 1) end From custfeature
		Select productnm,regprodcd From Prodmast
		--Select * From custmnutranrptdts Where fk_id=@id and optiontype='TRAN'
		--Select * From custmnutranrptdts Where fk_id=@id and optiontype='REPORT'
	End	
End