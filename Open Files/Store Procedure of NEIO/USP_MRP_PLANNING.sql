DROP PROCEDURE [USP_MRP_PLANNING]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [USP_MRP_PLANNING]
@ItName AS Varchar(50),@Qty AS Numeric(18,4),@Ware_nm as varchar(50),@Wharehouseapplicable int 
AS
set Nocount on
Declare @Entry_Ty Varchar(2),@Bcode_nm Varchar(2),@EntryTbl Varchar(2),@SqlCmd NVarchar(4000)
Declare @It_code Numeric(10),@Spl_Cond Varchar(500)
Declare @Itemid Numeric(10),@Item Varchar(100),@FgQty Numeric(18,4), @RmitemId Numeric(10),@Rmitem Varchar(100),@Rmqty Numeric(18,4),@nLevel Int
Declare @ReOrder Numeric(15,4),@Item_Type Varchar(50),@mIt_code Numeric(10)
Declare @PEND_WO Numeric(18,4),@pend_ord Numeric(18,4),@stock_avl Numeric(18,4),@stock_Req Numeric(18,4)

Declare @BomId Varchar(10),@childCount int,@srno  Int ,@iswareappl integer 

-- Added by Suraj Kumawat for Bug-29249 date on 30-12-2016 Start
 --- Select @Spl_Cond=Case when @Ware_nm<>'' Then 'And i.Ware_nm='''+@Ware_nm+''' ' Else '' End  -- Commented by Suraj for bug-29249
----select @iswareappl =isnull(iswareappl,0) from  lcode  where entry_ty='so' -- Added By Suraj Kumawat for Bug-29249 
Select @iswareappl = isnull(@Wharehouseapplicable,0) -- Added By Suraj Kumawat for Bug-29249 
if ( @iswareappl = 1 )
	begin
		Select @Spl_Cond=' And i.Ware_nm='''+@Ware_nm+''' ' 
	end
else
	begin
		Select @Spl_Cond=Case when @Ware_nm<>'' Then 'And i.Ware_nm='''+@Ware_nm+''' ' Else '' End 
	end

-- Added by Suraj Kumawat for Bug-29249 date on 30-12-2016 End

SELECT IT_CODE,QTY,WARE_NM  INTO #PENDWO FROM ITEM WHERE 1=2

Select @It_code=It_code,@BomId=u_Bomid1 From It_mast Where It_name=@ItName

/*		Retrieving Stock Entries	 Start		*/
---select i.It_code,SQtym=i.Qty,SQty=i.Qty,SQtyLabr=i.Qty into #GetStock  from STITEM i  where 1=2  commented for bug-29249 
select i.It_code,i.ware_nm ,SQtym=i.Qty,SQty=i.Qty,SQtyLabr=i.Qty into #GetStock  from STITEM i  where 1=2  -- added for bug-29249 

Insert Into #GetStock Execute USP_MRP_GETSTOCK @It_code,@Spl_Cond
--Fetching Pending work orders



INSERT INTO #PENDWO EXEC USP_MRP_GET_PEND_WO 

print @It_code			--Don't comment the print statement

/*		Fetching all related raw materials		Start	*/

 ;WITH BomDetails AS 
( 
--initialization 
Select y.Itemid,y.Item,y.FgQty,x.RmitemId,x.Rmitem,x.Rmqty,0 AS nLevel,x.Srno
FROM BomDet x
Inner Join Bomhead y on (x.BomId=y.BomId and x.bomlevel=y.bomlevel)
WHERE x.BomId =@BomId and x.bomlevel=0
UNION ALL 
--recursive execution 
SELECT m.Itemid,m.Item,m.FgQty,d.RmitemId,d.Rmitem,d.Rmqty,nLevel+1,d.Srno
FROM BomDet d 
Inner join Bomhead m on (m.BomId=d.BomId and d.Bomlevel=m.Bomlevel)
Inner Join BomDetails b ON b.RmitemId = m.itemId
) 
SELECT * Into #Bom FROM BomDetails Order by nLevel,srno
/*		Fetching all related raw materials		End		*/

--Select * Into #inventory from inventory Where 1=2

--create table #inventory(item varchar(50) ,order_qty decimal(15,2),rmitem varchar(50),req_qty decimal(15,2),req1_qty decimal(15,2),stock_avl decimal(15,2),pend_order decimal(15,2),reorder decimal(15,2),pending_wo decimal(15,2),indent_qty decimal(15,2),mtype varchar(20))
print 'a'
Select a.Item,a.qty as order_qty,a.Item as rmitem,a.qty as req_qty,a.qty as stock_avl,a.qty as pend_order,b.reorder
	,a.qty as pending_wo,a.qty as indent_qty,b.[type] as mtype,b.It_code,IsSubBOM =CONVERT(Bit,0),a.Item as pItem,a.it_code as pit_code
	,a.ware_nm --- Added for bug-29249  
	Into #inventory From Stitem a Inner Join IT_MAST b on (a.It_code=b.It_code) where 1=2

print'b'
print @It_code
--Insert Into #inventory values(@itname,@qty,'',0,0,0,0,0,0,'',@It_code)

print'c'

--Select Itemid,Item,FgQty,RmitemId,Rmitem,Rmqty,nLevel From #Bom Order by nLevel,srno


/*		Retrieving pending order, work order and stock of raw materials		Start	*/

Declare BomdetCur Cursor for
	Select Itemid,Item,FgQty,RmitemId,Rmitem,Rmqty,nLevel,srno From #Bom Order by nLevel,srno
	
Open BomdetCur	
Fetch Next From BomdetCur Into @Itemid,@Item,@FgQty,@RmitemId,@Rmitem,@Rmqty,@nLevel,@srno
While @@Fetch_Status=0
Begin
		
	Select @childCount=COUNT(Itemid) From #Bom Where Item=@Rmitem
		
	--- Added by by Suraj Kumawat for Bug-29249 STart
		--- Select @ReOrder=ReOrder,@Item_Type=[type] FROM IT_MAST WHERE It_code=@RmitemId  --- commented by Suraj Kumawat for Bug-29249
	if ( @iswareappl = 1 )
		begin
			Select @ReOrder= (case when (select re_ord_qty from  ITEM_Warehouse_ReOrder WHERE IT_CODE = @RmitemId AND Ware_Nm =@Ware_nm )  > 0  THEN (select re_ord_qty from  ITEM_Warehouse_ReOrder WHERE IT_CODE = @RmitemId AND Ware_Nm =@Ware_nm )  ELSE   ReOrder END )  ,@Item_Type=[type] FROM IT_MAST WHERE It_code=@RmitemId 
			SELECT @PEND_WO=Isnull(SUM(QTY),0) FROM #PENDWO WHERE it_code=@RmitemId and WARE_NM=@Ware_nm
			select @pend_ord=Isnull(sum(qty-re_qty),0) from poitem where item=@Rmitem  and WARE_NM=@Ware_nm  
		end
	else
		begin
			Select @ReOrder=ReOrder,@Item_Type=[type] FROM IT_MAST WHERE It_code=@RmitemId  
			SELECT @PEND_WO=Isnull(SUM(QTY),0) FROM #PENDWO WHERE it_code=@RmitemId 
			select @pend_ord=Isnull(sum(qty-re_qty),0) from poitem where item=@Rmitem  
		end	
	---- Added by by Suraj Kumawat for Bug-29249 STart		
	print '30122016'
	print @ReOrder
	
	/* Commented by Suraj Kumawat for bug-29249
		SELECT @PEND_WO=Isnull(SUM(QTY),0) FROM #PENDWO WHERE it_code=@RmitemId 
		select @pend_ord=Isnull(sum(qty-re_qty),0) from poitem where item=@Rmitem  
	*/

	Insert Into #GetStock Execute USP_MRP_GETSTOCK @RmitemId,@Spl_Cond
	---select @stock_avl=Isnull(sum(sqtym+sqty+sqtylabr),0) from #GetStock where it_code=@RmitemId  Commented by Suraj Kumawat for Bug-29249
	select @stock_avl=Isnull(sum(sqtym+sqty+sqtylabr),0) from #GetStock where it_code=@RmitemId  AND  Ware_nm=@Ware_nm  -- added by Suraj Kumawat for Bug-29249
	
	Set @stock_Req=Case when @stock_avl < (@Rmqty * @Qty) then (@Rmqty * @Qty)- @stock_avl Else (@Rmqty * @Qty) End 
	print 'a'
	insert into #inventory values(@ItName,@Qty,@Rmitem, (@Rmqty * @Qty)/@FgQty,@stock_avl,@pend_ord,@reorder,@PEND_WO,0,@Item_Type,@RmitemId,case when @childCount>0 then 1 else 0 end, @Item,@Itemid,@Ware_nm)
	--insert into #inventory values(@ItName,@Qty,@Rmitem, @stock_Req /@FgQty,(@Rmqty * @Qty)/@FgQty,@stock_avl,@pend_ord,@reorder,@PEND_WO,0,@Item_Type,@RmitemId)
	print 'b'
	Fetch Next From BomdetCur Into @Itemid,@Item,@FgQty,@RmitemId,@Rmitem,@Rmqty,@nLevel,@srno
End
Close BomdetCur
Deallocate BomdetCur
/*		Retrieving pending order, work order and stock of raw materials		End	*/

--Select * From #inventory
Update #inventory Set indent_qty=req_qty-pend_order-stock_avl+pending_wo+reorder
Update #inventory Set indent_qty=0 where indent_qty<0

--select * from #Bom Order by nLevel,srno
Select Item,rmitem,req_qty,stock_avl,pend_order,reorder ,pending_wo,indent_qty,mtype,It_code,IsSubBOM,pItem,order_qty,ware_nm=@ware_nm,pit_code from #inventory



Drop Table #GetStock
Drop table #inventory
GO
