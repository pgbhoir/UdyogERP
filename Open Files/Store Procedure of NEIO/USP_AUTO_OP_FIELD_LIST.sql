DROP PROCEDURE [USP_AUTO_OP_FIELD_LIST]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author      : Raghavendra Joshi
-- Create date : 04/01/2012
-- Description :	
-- =============================================

CREATE Procedure [USP_AUTO_OP_FIELD_LIST]
As
Declare @Header_Field Varchar(Max),@Detail_Field Varchar(Max)
SELECT @Header_Field =(SELECT ''+([Name])+',' FROM Syscolumns 
		WHERE [Id] = Object_Id('Auto_op_head') AND Colstat <> 1 FOR XML PATH(''))
SELECT @Detail_Field =(SELECT ''+([Name])+',' FROM Syscolumns 
		WHERE [Id] = Object_Id('Auto_op_detail') AND Colstat <> 1 FOR XML PATH(''))
SELECT Left(@Header_Field,Len(@Header_Field)-1) as Header_Field
	,Left(@Detail_Field,Len(@Detail_Field)-1) as Detail_Field
GO
