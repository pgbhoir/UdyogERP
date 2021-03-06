DROP PROCEDURE [Usp_Ent_Check_Data_Used]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Birendra Prasad.
-- Create date: 19/10/2012
-- Description:	This Stored procedure is useful In Delete Validation for transaction.
-- Modify date: 
-- Modified By: 
-- Remark: 
-- =============================================
Create  Procedure [Usp_Ent_Check_Data_Used](@Code varchar(10),@pfldname varChar(250),@fldvalue varchar(254))as	declare  @sqlstr nvarchar(4000),@tblname nvarchar(250), @tmpvalue int, @tmpmessage varchar(1000),@TBLCAPTION VARCHAR(250),@TBLNAME1 VARCHAR(250),@FLDCAPTION VARCHAR(250),@FLDNAME1 VARCHAR(250),@FLDNAME VARCHAR(250)set @tmpmessage=''SET @TBLCAPTION=''SET @TBLNAME1=''SET @FLDCAPTION=''SET @FLDNAME1=''if len(@code)>0 and len(@pfldname)>0begin	set @sqlstr='Declare CursorDelVal cursor for SELECT tblname,fldname  from DeleteValidation where code='+''''+@code +''''+' and substring(fldname,1,case when charindex('':'',fldname,1)>0 then charindex('':'',fldname,1)-1 else len(fldname) end  )='+''''+@pfldname+''''	execute sp_executesql @sqlstr	OPEN CursorDelVal

	FETCH NEXT FROM CursorDelVal 
	INTO @tblname,@fldname

	WHILE @@FETCH_STATUS = 0
	BEGIN		set @tmpvalue=0		SET @tblname1=substring(@tblname,1,case when charindex(':',@tblname,1)>0 then charindex(':',@tblname,1)-1 else len(@tblname) end  ) 		set @fldname1=substring(@fldname,1,case when charindex(':',@fldname,1)>0 then charindex(':',@fldname,1)-1 else len(@fldname) end  ) 		set @tblcaption=substring(@tblname,case when charindex(':',@tblname,1)>0 then charindex(':',@tblname,1)+1 else len(@tblname)+1 end ,len(@tblname) ) 		set @fldcaption=substring(@fldname,case when charindex(':',@fldname,1)>0 then charindex(':',@fldname,1)+1 else len(@fldname)+1 end ,len(@fldname) ) 		set @sqlstr='SELECT @tmpvalue1=count(*)  from '+@tblname1+' where '+@fldname1+'='+''''+@fldvalue+''''		execute sp_executesql @sqlstr,N'@tmpvalue1 int output',@tmpvalue1=@tmpvalue output		if @tmpvalue>0		begin		set @tmpmessage=@tmpmessage+case when len(@tblcaption)>0 then @tblcaption else @tblname end+char(13)			end		FETCH NEXT FROM CursorDelVal 
		INTO @tblname,@fldname
	END 
	CLOSE CursorDelVal
	DEALLOCATE CursorDelValselect case when(len(@tmpmessage)>0) then case when len(@fldcaption)>0 then @fldcaption else @fldname end+' is used in '+char(13)+@tmpmessage+char(13)+'Can not delete!!!' else @tmpmessage end as msg	end
GO
