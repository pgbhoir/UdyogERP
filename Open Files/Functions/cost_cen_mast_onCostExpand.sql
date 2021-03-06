DROP FUNCTION [cost_cen_mast_onCostExpand]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------

-- Author : Birendra

-- Creation Date : 15/05/2013

-- Modified Date:31/05/2017

-- Modified By :Priyanka B

-- Remark : This function use for show cost centre in cost under on the base of costExpand setting in co_mast.

------------------------------------

CREATE function [cost_cen_mast_onCostExpand](@compid varchar(10)
,@costcenname varchar(50)) --Added by Priyanka B on 31/05/2017

returns @table table (cost_cen_name varchar(50),cost_cen_id numeric(22))

as

begin

	declare @costexpand bit

	select @costexpand=costexpand from vudyog..co_mast where compid=@compid

	if (@costexpand=0)  

		--insert into @table select cost_cen_name,cost_cen_id  from cost_cen_mast  --Commented by Priyanka B on 31/05/2017

		--Added by Priyanka B on 31/05/2017 Start
		insert into @table select cost_cen_name,cost_cen_id  from cost_cen_mast
		where cost_cen_name <> @costcenname 
		--Added by Priyanka B on 31/05/2017 End
	else 

		/*insert into @table select cost_cen_name,cost_cen_id from cost_cen_mast 
		where cost_cen_id not in(select distinct cost_cen_id from costallocation_vw)
		--Commented by Priyanka B on 31/05/2017*/
		
		--Added by Priyanka B on 31/05/2017 Start
		insert into @table select cost_cen_name,cost_cen_id from cost_cen_mast
		where cost_cen_id not in(select distinct cost_cen_id from costallocation_vw)
		and cost_cen_name <> @costcenname 
		--Added by Priyanka B on 31/05/2017 End
return

end
GO
