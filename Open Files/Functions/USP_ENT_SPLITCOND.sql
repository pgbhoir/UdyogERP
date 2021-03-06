DROP FUNCTION [USP_ENT_SPLITCOND]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Function NAME		   : USP_REP_SPLITCOND
-- Function DESCRIPTION   : USED TO GET PARAMETER CONDITIONS PASSED
-- MODIFIED DATE/BY/REASON :
-- REMARK				   : 
-- ==========================================================
CREATE Function [USP_ENT_SPLITCOND](@SPCond VARCHAR(max))
Returns @SPTbl TABLE (SCond Char(100),SVal Char(250))
AS
Begin
	Declare @SpCond1 as NVARCHAR(4000),@SpCond1A as NVARCHAR(4000),@SpCond1B as NVARCHAR(4000)
	Declare @idx INT,@idx1 INT

	SET @SpCond1	 = ''
	SET @SpCond1A = ''
	SET @SpCond1B	 = ''
	SET @idx  = 1       
	SET @idx1 = 1       

	While @idx != 0       
	Begin       
		Set @idx = CharIndex('~~',@SPCond)       

		If @idx != 0       
		Begin
			Set @SpCond1 = Left(@SPCond,@idx - 1)       
		End
		Else   
		Begin    
			Set @SpCond1 = @SPCond
		End

		Set @idx1 = CharIndex('::',@SPCond1)       
		Set @SpCond1A = Left(@SPCond1,@idx1 - 1)       
		Set @SpCond1B = Substring(@SPCond1,@idx1 +2,Len(@SPCond1))       

		Insert Into @SPTbl  (SCond,SVal) Values(@SpCond1A,@SpCond1B)

		If @idx != 0       
		Begin    		
			Set @SPCond = Substring(@SPCond,@idx +2,Len(@SPCond))       
		End	

		If @SPCond = ''
		Begin    
			Set @SPCond = ''
			Set @idx = 0
		End
	End  
	Return
End
GO
