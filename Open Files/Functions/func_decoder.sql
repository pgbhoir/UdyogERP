DROP FUNCTION [func_decoder]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [func_decoder](@thispass varchar(50),@passflag varchar(1))
returns varchar(200)
as
BEGIN
   DECLARE @retStr varchar(50),
           @position int, 
           @string varchar(50),
           @fincode varchar(50),
           @mycoder varchar(50)
	-- Initialize the variables.
	SET @position = 1
	SET @string = @thispass
	SET @mycoder = ''
	WHILE @position <= DATALENGTH(@string)
	BEGIN
	   IF @passflag = 'T'	
		set @mycoder = @mycoder + char(ASCII(SUBSTRING(@string, @position, 1))-4) 
	   ELSE
		set @mycoder = @mycoder + char(ASCII(SUBSTRING(@string, @position, 1))+4) 
	 SET @position = @position + 1
	/*   SET @fincode  = @fincode + rtrim(ltrim(@mycoder))*/
	END
RETURN @mycoder
END
GO
