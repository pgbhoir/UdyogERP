DROP FUNCTION [DaysofYear]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [DaysofYear](@lyn Varchar(10))
returns int
as 
Begin
	Declare @sdate smalldatetime,@edate smalldatetime
	set @sdate=convert(smalldatetime,'04/01/'+left(rtrim(@lyn),4))
	set @edate=convert(smalldatetime,'03/31/'+right(rtrim(@lyn),4))
	return datediff(d,@sdate,@edate)+1
End
GO
