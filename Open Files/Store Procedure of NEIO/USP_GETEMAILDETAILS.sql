DROP PROCEDURE [USP_GETEMAILDETAILS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [USP_GETEMAILDETAILS]
@ACID INT,
@ACNAME VARCHAR(100)
AS
SELECT rtrim(EMAIL) as Email FROM AC_MAST WHERE AC_NAME=@ACNAME
GO
