DROP FUNCTION [finYear]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [finYear]
(@date smalldatetime)
returns Varchar(10) 
as
Begin
	Declare @finYear Varchar(10)
	set @finYear=Case when Month(@date ) between 4 and 12 then convert(varchar(4),year(@date))+'-'+convert(varchar(4),year(@date)+1) else convert(varchar(4),year(@date)-1)+'-'+convert(varchar(4),year(@date))  end
return @finYear
End
GO
