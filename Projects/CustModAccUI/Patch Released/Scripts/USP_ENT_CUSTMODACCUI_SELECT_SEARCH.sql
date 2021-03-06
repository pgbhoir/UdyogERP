IF EXISTS(SELECT * FROM SYSOBJECTS WHERE [NAME]='USP_ENT_CUSTMODACCUI_SELECT_SEARCH' AND XTYPE='P')
BEGIN
	DROP PROCEDURE USP_ENT_CUSTMODACCUI_SELECT_SEARCH
END
GO
Create Procedure [dbo].[USP_ENT_CUSTMODACCUI_SELECT_SEARCH]
As
Begin
	Select id as [Id],rcomp as [Registered Company],rmacid as [Machine Id],prodname as [Product Name],prodver as [Product Version]
	From custfeature order by id
	Select * From custmnutranrptdts order by fk_id
End
