DROP PROCEDURE [Usp_Ent_Emp_Gen_Processing_Month]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--**************************************************************--
-- Procedure Name : Usp_Ent_Emp_Gen_Processing_Month
-- Created by/on/for : Sachin N. S. on 14/11/2015 for Bug-27212
-- Description : This procedure is being used in generating muster records while creating the employee.
--**************************************************************--
CREATE PROCEDURE [Usp_Ent_Emp_Gen_Processing_Month]
@LOC_CODE VARCHAR(10)
AS
BEGIN
	DECLARE @YEAR VARCHAR(4), @MONTH INT
	SELECT TOP 1 @YEAR=PAY_YEAR,@MONTH=PAY_MONTH FROM EMP_PROCESSING_MONTH 
		WHERE LOC_CODE=@LOC_CODE
		ORDER BY PAY_YEAR DESC,PAY_MONTH DESC
	
	IF (ISNULL(@YEAR,'')='' AND ISNULL(@MONTH,0)=0)
	BEGIN
		SELECT TOP 1 @YEAR=PAY_YEAR,@MONTH=PAY_MONTH FROM EMP_PROCESSING_MONTH 
			ORDER BY PAY_YEAR DESC,PAY_MONTH DESC
	END

	IF (ISNULL(@YEAR,'')<>'' AND ISNULL(@MONTH,0)<>0)
	BEGIN
		EXECUTE [Usp_Ent_Emp_Processing_Month_Creation] @YEAR,@MONTH,@LOC_CODE
	END
END
GO
