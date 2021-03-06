DROP PROCEDURE [USP_SHIPTO_EXCLDATA_EXPORT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_SHIPTO_EXCLDATA_EXPORT]
@FLDLIST NVARCHAR(MAX)
AS
BEGIN
DECLARE @CQRY NVARCHAR(MAX)

	SET @CQRY = 'WITH CTE_SHIPTO
	as
	( SELECT ' + REPLACE(@FLDLIST,',ISNULL(b.[InsCheck],'''') as ',',''Y'' as ')  + '
		from Ac_Mast a 
			Left outer join shipto b on a.Ac_id=b.ac_id and a.City=b.Location_Id Where a.Defa_ac=0 
	)
		select * from CTE_SHIPTO
		union all
		select ' + @FLDLIST + '
		from shipto b
		inner join AC_MAST a on a.Ac_id=b.ac_id
			Where a.Defa_ac=0 and cast(b.ac_id as varchar)+''|''+b.Location_Id 
				not in (Select cast(ac_id as varchar)+''|''+Location from CTE_SHIPTO)'

EXECUTE SP_EXECUTESQL @CQRY
			
END
GO
