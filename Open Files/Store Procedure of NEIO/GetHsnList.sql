DROP PROCEDURE [GetHsnList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [GetHsnList]
as
Select a.HsnCode,a.state_code,b.State,c.HSN_Desc
From HSNCODEMAST a 
Cross Apply (Select State From STATE Where Gst_State_Code=a.State_code) b 
Cross Apply (Select hsn_desc From HSN_Master where hsn_id=a.hsnid) c
GO
