If Exists (Select [Name] From SysObjects Where [Name]='Usp_Ent_Gen_MultiUnit_Stock' and xType='P')
Begin
	Drop Procedure Usp_Ent_Gen_MultiUnit_Stock
End
Go
Create Procedure [dbo].[Usp_Ent_Gen_MultiUnit_Stock]
@Edate SmallDateTime, 
@spl_cond Varchar(1000)
as 
set Nocount On

Declare @UOM_no Int,@qtystr Varchar(500),@i int,@Entry_ty Varchar(2),@Uom_desc Varchar(250),@ext_vou Bit,@exefld Varchar(200)
Declare @qtystr2 Varchar(1000),@qtystr3 Varchar(1000),@qtystr4 Varchar(1000),@Sqlcmd NVarchar(4000)
Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50),@TBLNAME2 as VARCHAR(50),@TBLNAME3 as VARCHAR(50)
	
	Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	Set @TBLNAME1 = '##TMP1'+@TBLNM
	Set @TBLNAME2 = '##TMP2'+@TBLNM
	Set @TBLNAME3 = '##TMP3'+@TBLNM
set @exefld=''
set @qtystr=''
set @qtystr2=''
set @qtystr3 =''
set @qtystr4=''
set @i=1
Select top 1 @UOM_no=Uom_no From Vudyog..co_mast where Dbname= db_name()

if @UOM_no>0
	While @i<@UOM_no
	Begin
		set @qtystr	=@qtystr+',Qty'+convert(Varchar(1),@i)
		set @qtystr2=@qtystr2+',BalQty'+convert(Varchar(1),@i)+'=sum(case when pmkey=''+'' then isnull(Qty'+convert(Varchar(1),@i)+',0) else -(isnull(Qty'+convert(Varchar(1),@i)+',0)) end )'	
		set @qtystr3=@qtystr3+' Or sum(case when pmkey=''+'' then isnull(Qty'+convert(Varchar(1),@i)+',0) else -(isnull(Qty'+convert(Varchar(1),@i)+',0)) end )>0'	
		set @qtystr4=@qtystr4+',Qty'+convert(Varchar(1),@i)+'=0'
		set @i=@i+1
		if Not Exists(Select [Name] From SysColumns where [Name]='Qty'+rtrim(convert(Varchar(1),@i)) and id=(Select Id from SysObjects Where xtype='U' and [Name]='OSITEM'))
		Begin
			set @exefld= 'Qty'+rtrim(convert(Varchar(1),@i))+' Numeric(18,4)'
			Execute Add_columns 'OSITEM',@exefld
			Execute Add_columns 'OSITEM',@exefld
		End

	End

	set @Sqlcmd='Select Entry_ty,Tran_cd,Itserial,Qty,It_code,Rate,pmkey,ware_nm,dc_no '
		+@qtystr+' Into '+@TBLNAME1+' From PtItem Where (Pmkey=''+'' or Pmkey=''-'') and 1=2 '
	Execute sp_Executesql @Sqlcmd	

Declare Entry_cursor Cursor for
Select Entry_ty,Uom_desc,Ext_vou From Lcode Where Bcode_nm='' and ext_vou=0
Union all Select top 1 Entry_ty,Uom_desc,Ext_vou From Lcode Where Bcode_nm='' and ext_vou=1


Open Entry_cursor
Fetch Next From Entry_cursor Into @Entry_ty,@Uom_desc,@ext_vou 

While @@Fetch_Status=0
Begin
	if @Uom_desc<>''
	Begin
		set @Sqlcmd='insert Into '+@TBLNAME1+' Select Entry_ty,Tran_cd,Itserial,Qty,It_code,Rate=0,pmkey,ware_nm,dc_no '
			+@qtystr+' From '+case when @ext_vou=1 then '' else @Entry_ty end +'Item Where (Pmkey=''+'' or Pmkey=''-'') '
		Execute sp_Executesql @Sqlcmd	
	end
	else
	Begin
		set @Sqlcmd='insert Into '+@TBLNAME1+' Select Entry_ty,Tran_cd,Itserial,Qty,It_code,Rate=0,pmkey,ware_nm,dc_no '
			+@qtystr4+' From '+case when @ext_vou=1 then '' else @Entry_ty end +'Item Where (Pmkey=''+'' or Pmkey=''-'') '
		Execute sp_Executesql @Sqlcmd	

	End	
	Fetch Next From Entry_cursor Into @Entry_ty,@Uom_desc,@ext_vou 
End
Close Entry_cursor
Deallocate Entry_cursor

set @sqlcmd=''
set @sqlcmd=@sqlcmd+' '+'Select a.entry_ty,a.Date,rules=case when a.[rule]=''NON-MODVATABLE'' THEN a.[rule] ELSE (Case when a.[rule]='''' then '''' else ''MODVATABLE'' end) END ,a.Tran_cd,b.Qty,b.pmkey,Ware_nm'
set @sqlcmd=@sqlcmd+' '+',i.It_code,i.It_name,ItType=i.[Type],itgrp=i.[group] ,i.itgrid,UpdateFlg=convert(bit,0),a.u_gcssr,b.Rate'+@qtystr
set @sqlcmd=@sqlcmd+' '+'Into '+@TBLNAME2+' from '+@TBLNAME1+' b '
set @sqlcmd=@sqlcmd+' '+'Inner Join Stkl_vw_Main a on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.Tran_cd)'
set @sqlcmd=@sqlcmd+' '+'Inner Join It_Mast i on (i.It_code=b.It_code)'
set @sqlcmd=@sqlcmd+' '+'Where a.Date <= '''+convert(Varchar(50),@Edate)+''' and a.[rule] Not in (''ANNEXURE V'')'
set @sqlcmd=@sqlcmd+' '+@spl_cond 
SET @sqlcmd=@sqlcmd+' '+' AND a.APGEN='+CHAR(39)+'YES'+CHAR(39)
SET @sqlcmd=@sqlcmd+' '+' AND b.DC_NO='+CHAR(39)+' '+CHAR(39)
SET @sqlcmd=@sqlcmd+' '+'Order By a.[Rule],i.[Type],i.It_name,b.Ware_nm'
--print @sqlcmd
Execute sp_Executesql @sqlcmd


SET @sqlcmd=''
SET @sqlcmd=@sqlcmd+' '+'Select BalQty=sum(case when pmkey=''+'' then Qty else -Qty end )'
SET @sqlcmd=@sqlcmd+' '+',Rate,rules,It_code,It_Name,ItType,Ware_nm,itgrid,itgrp,UpdateFlg'
SET @sqlcmd=@sqlcmd+' '+',u_gcssr'+@qtystr2+' Into '+@TBLNAME3+' from '+@TBLNAME2 
SET @sqlcmd=@sqlcmd+' '+'Group By rules,It_code,It_Name,ItType,Ware_nm,itgrid,itgrp,UpdateFlg,u_gcssr,Rate'
SET @sqlcmd=@sqlcmd+' '+'Having sum(case when pmkey=''+'' then Qty else -Qty end )<>0'
SET @sqlcmd=@sqlcmd+' '+@qtystr3
SET @sqlcmd=@sqlcmd+' '+'Order by rules,u_gcssr,ItType,It_Name,Ware_nm'
Execute sp_Executesql @sqlcmd

SET @sqlcmd=''
SET @sqlcmd=@sqlcmd+' '+'Update '+@TBLNAME3
SET @sqlcmd=@sqlcmd+' '+'set balqty=(Case when abs(a.balqty)<=abs(b.balqty) then a.balqty+(a.balqty * -1) else a.balqty+(b.balqty * -1) end) from '+@TBLNAME3+' a'
SET @sqlcmd=@sqlcmd+' '+'inner join (select * from '+@TBLNAME3+'  where rules ='''') b on  a.it_code=b.it_code'
SET @sqlcmd=@sqlcmd+' '+'where a.rules in ('''',''NON-MODVATABLE'')'
Execute sp_Executesql @sqlcmd

SET @sqlcmd='delete from '+@TBLNAME3+' where rules='''' and balqty=0'
Execute sp_Executesql @sqlcmd

SET @sqlcmd=''
SET @sqlcmd=@sqlcmd+' '+'Update '+@TBLNAME3
SET @sqlcmd=@sqlcmd+' '+'set balqty=(Case when abs(a.balqty)<=abs(b.balqty) then a.balqty+(a.balqty * -1) else a.balqty+(b.balqty * -1) end) from '+@TBLNAME3+' a '
SET @sqlcmd=@sqlcmd+' '+'inner join (select * from '+@TBLNAME3+' where rules ='''') b on  a.it_code=b.it_code'
SET @sqlcmd=@sqlcmd+' '+'where a.rules in ('''',''MODVATABLE'')'

SET @sqlcmd='delete from '+@TBLNAME3+' where rules='''' and balqty=0'
Execute sp_Executesql @sqlcmd

SET @sqlcmd='select * from '+@TBLNAME3+' where balqty<>0'
Execute sp_Executesql @sqlcmd




set @Sqlcmd='Drop Table '+@TBLNAME1
Execute sp_Executesql @Sqlcmd	

set @Sqlcmd='Drop Table '+@TBLNAME2
Execute sp_Executesql @Sqlcmd	

set @Sqlcmd='Drop Table '+@TBLNAME3
Execute sp_Executesql @Sqlcmd	


