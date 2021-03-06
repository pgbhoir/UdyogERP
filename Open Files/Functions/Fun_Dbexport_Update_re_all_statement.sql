DROP FUNCTION [Fun_Dbexport_Update_re_all_statement]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [Fun_Dbexport_Update_re_all_statement]
(
@cTbl_name varchar(10)
,@cRe_all_val Varchar(50)
,@cRef_no Varchar(2)
,@Main_tran int
,@Acseri_all Varchar(5)
,@cType Varchar(1)
)
Returns varchar(Max) 
As 
Begin
	Declare @Updtsql Varchar(Max)
	SELECT @Updtsql = 'UPDATE '+@cTbl_name+'ACDET'
	IF @cType = '+'
	BEGIN
		SELECT @Updtsql = @Updtsql + ' SET Re_all = ISNULL(Re_all,0) + '+RTrim(@cRe_all_val)
		SELECT @Updtsql = @Updtsql + ',Ref_no = RTrim(Ref_no)+'
		SELECT @Updtsql = @Updtsql + 'Case when Charindex('+Char(39)+@cRef_no+Char(39)+',Ref_no) = 0 Then'
		SELECT @Updtsql = @Updtsql + Char(39)+'/'+ @cRef_no+Char(39)+ ' Else '+Char(39)+Char(39)+' End ' 
	END
	ELSE
	BEGIN
		SELECT @Updtsql = @Updtsql + ' SET Re_all = ISNULL(Re_all,0) - '+RTrim(@cRe_all_val)
	END
	SELECT @Updtsql = @Updtsql+' WHERE Tran_cd = '+Cast(@Main_tran as Varchar(50))
	SELECT @Updtsql = @Updtsql+' AND Acserial = '+Char(39)+@Acseri_all+Char(39)
	return @Updtsql
End
GO
