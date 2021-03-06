DROP PROCEDURE [TestProc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [TestProc]
	 @TableName AS Varchar(10) = NULL,@SQLCOND AS VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SQLCOMMAND NVARCHAR(4000)
	SET @SQLCOMMAND='SELECT * FROM '+@TABLENAME+' WHERE '+@SQLCOND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
END
GO
