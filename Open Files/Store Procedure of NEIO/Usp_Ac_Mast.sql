DROP PROCEDURE [Usp_Ac_Mast]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Usp_Ac_Mast]
As 
Declare @Balance Numeric(17,2)
DECLARE @Level Int
DECLARE @OrderLevel VarChar(50)
Set @Balance = 0
Set @Level = 0
Select @OrderLevel as OrderLevel,@Level As [Level],'G' As MainFlg,Ac_Group_Id as Ac_Id,gAC_id as Ac_Group_Id,AC_GROUP_NAME as Ac_Name,[Group],@Balance As OpBal,@Balance As Debit,@Balance As Credit,@Balance As ClBal
From Ac_Group_Mast
Union All 
Select @OrderLevel as OrderLevel, @Level As [Level],'L' As MainFlg,a.Ac_Id,a.Ac_Group_Id,a.Ac_Name,[Group],@Balance As OpBal,@Balance as Debit,@Balance as Credit,@Balance as ClBal
From Ac_Mast a
GO
