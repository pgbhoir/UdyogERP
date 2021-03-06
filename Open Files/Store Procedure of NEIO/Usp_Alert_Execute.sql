DROP PROCEDURE [Usp_Alert_Execute]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ramya.
-- Create date: 24/09/2011
-- Description:	Alert Execution.
-- =============================================

Create procedure [Usp_Alert_Execute]
as
begin
	declare @Alert_Name varchar(60),@FreQuency varchar(30),@Last_Updated smalldatetime,@SqlQuery varchar(100),@Paralist varchar(150)	 
	declare @vexecute bit,@SqlCommand nvarchar(500),@SqlCommand1 nvarchar(500);
	set @vexecute=0
	set @SqlQuery=' '
	declare  cur_alert cursor for select Alert_Name,FreQuency,Last_Updated,Query,Paralist from Alert_Master
	open cur_alert

	fetch next from cur_alert into @Alert_Name,@FreQuency,@Last_Updated ,@SqlQuery,@Paralist
	while(@@fetch_status=0)
	begin
		set  @Last_Updated= isnull(@Last_Updated,cast('' as datetime))
        print @Last_Updated

	  
       if (@FreQuency='yearly') and @vexecute=0
		begin
			if  ( datediff(yy,@Last_Updated,getdate()) )>0
			begin
				set @vexecute=1
             print 'udyog begin started'

			end
		end
		if (@FreQuency='monthly') and @vexecute=0
		begin
     
			if  ( datediff(mm,@Last_Updated,getdate()) )>0
			begin
				set @vexecute=1
                print 'udyog begin started' 

			end
		end
       if (@FreQuency='weekly') and @vexecute=0
		begin
    
			if  ( datediff(ww,@Last_Updated,getdate()) )>0
			begin
				set @vexecute=1
                print 'udyog begin started'    
			end
		end

		if (@FreQuency='hourly') and @vexecute=0
		begin
			if  ( datediff(hh,@Last_Updated,getdate()) )>0
			begin
				set @vexecute=1
                 print 'udyog begin started'
			end
		end
		if (@FreQuency='daily') and @vexecute=0
		begin
			if  ( datediff(day,@Last_Updated,getdate()) )>0
			begin
				set @vexecute=1
                print 'udyog begin started'
			end
		end

		if @vexecute=1
		begin
            print @FreQuency
            print @Paralist  
			set @SqlCommand=@SqlQuery+''+''''+@Paralist+''''
			print @SqlCommand
			execute sp_executesql @SqlCommand
            print @Frequency
            set @SqlCommand1='update alert_master set [Last_Updated] = getdate() where [Query]='''+@SqlQuery
			set @SqlCommand1=@SqlCommand1+''''
            print @SqlCommand1
            execute sp_executesql @SqlCommand1
		end
        set @vexecute=0 
		fetch next from cur_alert into @Alert_Name,@FreQuency,@Last_Updated ,@SqlQuery,@Paralist
	end
	close cur_alert
	deallocate cur_alert
end
GO
