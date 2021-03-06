DROP PROCEDURE [USP_REP_ST_BILLM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rupesh Prajapati.
-- Create date: 26/09/2009
-- Description:	This Stored procedure is useful to generate Sales Tax Invoice .
-- Modification Date/By/Reason: 02/10/2009 Rupesh Prajapati. Modified Progressive Total.
-- Modification Date/By/Reason: 22/04/2010 Shrikant S. for TKT-6
-- Modification Date/By/Reason: 13/05/2010 Ajay Jaiswal for TKT-461
-- Modification Date/By/Reason: 28/03/2011 Amrendra Singh for TKT-6868
-- Modification Date/By/Reason: 28/09/2011 Shrikant S. for TKT-9486
-- Modification Date/By/Reason: 02/12/2011 Satish pal for bug-664
-- Modification Date/By/Reason: 10/01/2012 Shrikant S. for Bug-1460(Multi UOM qty fields are require in default)	
-- Modification Date/By/Reason: 26/04/2012 Shrikant S. for Bug-3609(To calculate the progressive total yearwise)
-- Modification Date/By/Reason: 21/09/2012 Sachin N. S. for bug-5164(Added Service tax Sr No. field)
-- Modification Date/By/Reason: 08/10/2013 Archana K. for Bug-19983(multiple-report formats - For Manufacturing)
-- Modification Date/By/Reason: 26/03/2014 Pankaj B. for Bug-19983(multiple-report formats - For Manufacturing)

-- Remark: 
-- =============================================
CREATE PROCEDURE [USP_REP_ST_BILLM]
	@ENTRYCOND NVARCHAR(254)
	AS
--Declare @SQLCOMMAND as NVARCHAR(4000),@TBLCON as NVARCHAR(4000),@SQLCOMMAND1 NVARCHAR(4000),@ParmDefinition NVARCHAR(500),@SQLCOMMAND2 NVARCHAR(4000)--Commented by Archana K. on 08/10/13 for Bug-19983 
Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)--Changed by Archana K. on 08/10/13 for Bug-19883
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)
	
	SET @TBLCON=RTRIM(@ENTRYCOND)
	--->Progressive Total
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)

--	select @date=date,@inv_no=inv_no,@inv_sr=inv_sr from stmain where entry_ty=@ent and tran_cd=@trn --Commented by Shrikant S. on 22/04/2010 for TKT-6 

		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact
-- Added By Shrikant S. on 26/04/2012 for Bug-3609		--Start
Declare @sta_dt datetime, @end_dt datetime 
set @SQLCOMMAND1='select top 1 @sta_dt=sta_dt,@end_dt=end_dt from vudyog..co_mast where dbname=db_name() and ( select top 1 stmain.date  from stmain inner join stitem on (stmain.tran_cd=stitem.tran_cd) where '+@TBLCON+' ) between sta_dt and end_dt '	
set @ParmDefinition =N' @sta_dt datetime Output, @end_dt datetime Output'
EXECUTE sp_executesql @SQLCOMMAND1,@ParmDefinition,@sta_dt=@sta_dt Output, @end_dt=@end_dt Output
-- Added By Shrikant S. on 26/04/2012 for Bug-3609		--End

--Added by Shrikant S. on 22/04/2010 for TKT-6 --------Start --For Progressive Total
	Select Entry_ty,Tran_cd=0,Date,inv_no,itserial=space(6) Into #stmain from stmain Where 1=0
	Create NonClustered Index Idx_tmpStmain On #stmain (Entry_ty asc, Tran_cd Asc, Itserial asc)

		set @sqlcommand='Insert Into #stmain Select stmain.Entry_ty,stmain.Tran_cd,stmain.date,stmain.inv_no,stitem.itserial from stmain Inner Join stitem on (stmain.Entry_ty=stitem.Entry_ty and stmain.Tran_cd=stitem.Tran_cd) Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand

		if @pformula<>''  
		Begin
			----select progtotal=(cast (0 as numeric(17,0))),inv_no,Tran_Cd=0 into #progtot from stmain where 1=2
			----select progtotal=(cast (0 as numeric(17,0))),inv_no,Tran_Cd=0 into #progtot1 from stmain where 1=2
			select progtotal=(cast (0 as numeric(17,0))),inv_no,Tran_Cd=0,progcurrtotal=(cast (0 as numeric(17,0))) into #progtot from stmain where 1=2 ---added by satish pal for bug 664 dt.02/12/2011
			select progtotal=(cast (0 as numeric(17,0))),inv_no,Tran_Cd=0,progcurrtotal=(cast (0 as numeric(17,0))) into #progtot1 from stmain where 1=2---added by satish pal for bug 664 dt.02/12/2011
				Declare ProgTotalcur Cursor for
				Select Entry_ty,Tran_cd,Date,Inv_no from #stmain Group by Entry_ty,Tran_cd,Date,Inv_no
				Open ProgTotalcur 
				Fetch Next From ProgTotalcur Into @Entry_ty,@Tran_cd,@Date,@Inv_no 
				While @@Fetch_Status=0
				Begin
					print 's1'
					/* Finding the Sum of the Closing of the previous Day */ 
					set @SQLCOMMAND1='select @Sum=sum(isnull('+rtrim(@pformula)+',0)) from stmain inner join stitem on (stmain.tran_cd=stitem.tran_cd)  '	
					set @SQLCOMMAND1=@SQLCOMMAND1+' '+'Where stmain.Date <'''+Convert(Varchar(50),@Date)+''' '
					if (rtrim(@progcond)<>'') begin set @SQLCOMMAND1=rtrim(@SQLCOMMAND1)+' and '+rtrim(@progcond) end
					set @SQLCOMMAND1=rtrim(@SQLCOMMAND1)+' and stmain.date between '''+convert(varchar(50),@sta_dt)+''' and '''+convert(varchar(50),@end_dt)+''' '	-- Added By Shrikant S. on 26/04/2012 for Bug-3609
					-- Added By Shrikant S. on 26/04/2012 for Bug-3609		
					set @ParmDefinition =N' @Sum Numeric(19,2) Output'
					EXECUTE sp_executesql @SQLCOMMAND1,@ParmDefinition,@Sum=@Progtotal OUTPUT
					print @SQLCOMMAND1
					Insert Into #progtot1 values(isnull(@Progtotal,0),@Inv_no,@Tran_cd,isnull(@Progcurrtotal,0))				
					/* Finding the Sum of the Closing of the previous Day */ 
					print 's2'
					/* Finding the Sum of the Present Day */ 
					set @SQLCOMMAND1='select @Sum=sum(isnull('+rtrim(@pformula)+',0)) from stmain inner join stitem on (stmain.tran_cd=stitem.tran_cd)  '	
					set @SQLCOMMAND1=@SQLCOMMAND1+' '+'Where stmain.Date ='''+Convert(Varchar(50),@Date)+'''  and stmain.Tran_cd<'+convert(Varchar(10),@Tran_cd)
					if (rtrim(@progcond)<>'') begin set @SQLCOMMAND1=rtrim(@SQLCOMMAND1)+' and '+rtrim(@progcond) end
					set @ParmDefinition =N' @Sum Numeric(19,2) Output'
					EXECUTE sp_executesql @SQLCOMMAND1,@ParmDefinition,@Sum=@Progtotal OUTPUT
					print @Progtotal

					--Added by satish Pal for bug 664 dt.02/12/2011
					set @SQLCOMMAND2='select @Sum=sum(isnull('+rtrim(@pformula)+',0)) from stmain inner join stitem on (stmain.tran_cd=stitem.tran_cd)  '	
					set @SQLCOMMAND2=@SQLCOMMAND2+' '+'Where  stmain.Tran_cd='+convert(Varchar(10),@Tran_cd)
					if (rtrim(@progcond)<>'') begin set @SQLCOMMAND2=rtrim(@SQLCOMMAND2)+' and '+rtrim(@progcond) end
					set @ParmDefinition =N' @Sum Numeric(19,2) Output'
					EXECUTE sp_executesql @SQLCOMMAND2,@ParmDefinition,@Sum=@Progcurrtotal OUTPUT
					--end by satish Pal for bug 664 dt.02/12/2011
					----Insert Into #progtot1 values(isnull(@Progtotal,0)+isnull(@progopamt,0),@Inv_no,@Tran_cd)
					Insert Into #progtot1 values(isnull(@Progtotal,0)+isnull(@progopamt,0),@Inv_no,@Tran_cd,isnull(@Progcurrtotal,0)+isnull(@progopamt,0))---added by satish pal for bug 664 dt.02/12/2011		
					/* Finding the Sum of the Present Day */ 

					---Insert Into #progtot Select sum(isnull(progtotal,0)),Inv_no,Tran_cd from #progtot1 Group by Inv_no,Tran_cd
					Insert Into #progtot Select sum(isnull(progtotal,0)),Inv_no,Tran_cd,isnull(@Progcurrtotal,0) from #progtot1 Group by Inv_no,Tran_cd ---added by satish pal for bug 664 dt.02/12/2011		
					Delete from #progtot1
					
				Fetch Next From ProgTotalcur Into @Entry_ty,@Tran_cd,@Date,@Inv_no 
				End
				Close ProgTotalcur
				Deallocate ProgTotalcur
		End
--Added by Shrikant S. on 22/04/2010 for TKT-6 --------End

-- Added By Shrikant S. on 10/01/2012 for Bug-1460		--Start
Declare @uom_desc as Varchar(100),@len int,@fld_nm varchar(10),@fld_desc Varchar(10),@count int,@stkl_qty Varchar(100)

select @uom_desc=isnull(uom_desc,'') from vudyog..co_mast where dbname =rtrim(db_name())
Create Table #qty_desc (fld_nm varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, fld_desc varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
set @len=len(@uom_desc)
set @stkl_qty=''
If @len>0 
Begin
	while @len>0
	Begin
		set @fld_nm=substring(@uom_desc,1,charindex(':',@uom_desc)-1)
		set @uom_desc=substring(@uom_desc,charindex(':',@uom_desc)+1,@len)
		set @stkl_qty= @stkl_qty +', '+'STITEM.'+@fld_nm

		if @len>0 and charindex(';',@uom_desc)=0
		begin
			set @uom_desc=@uom_desc
			set @fld_desc=@uom_desc
			SET @len=0
		End
		else
		begin
				set @fld_desc=substring(@uom_desc,1,charindex(';',@uom_desc)-1)
				set @uom_desc=substring(@uom_desc,charindex(';',@uom_desc)+1,@len)
				set @len=len(@uom_desc)
		End
		insert into #qty_desc values (@fld_nm,@fld_desc)
	End
End
Else
Begin
	set @stkl_qty=',STITEM.QTY'
End
---Added by Archana K. on 08/10/13 for Bug-19983 start
Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)
Select case when att_file=1 then 'STMAIN.'+RTRIM(FLD_NM) else 'STITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='ST'
union all
Select case when att_file=1 then 'STMAIN.'+RTRIM(FLD_NM) else 'STITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='ST'
	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,STMAIN.INV_SR,STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE,STMAIN.U_TIMEP,STMAIN.U_TIMEP1 ,STMAIN.U_REMOVDT,STMAIN.U_EXPLA,STMAIN.U_EXRG23II,STMAIN.U_RG2AMT,STMAIN.EXAMT,STITEM.EXAMT AS IT_EXAMT,STITEM.U_BASDUTY,STITEM.U_CESSPER,STMAIN.U_CESSAMT,STITEM.U_CESSAMT AS IT_CESSAMT'
	SET @QueryString =@QueryString+',STITEM.U_HCESSPER,STMAIN.U_HCESAMT,STITEM.U_HCESAMT AS IT_HCESSAMT,STMAIN.U_DELIVER,STMAIN.DUE_DT,STMAIN.U_CLDT,STMAIN.U_CHALNO,STMAIN.U_CHALDT,STMAIN.U_PONO,STMAIN.U_PODT,STMAIN.U_LRNO,STMAIN.U_LRDT,STMAIN.U_DELI,STMAIN.U_VEHNO,STITEM.GRO_AMT AS IT_GROAMT,STMAIN.GRO_AMT GRO_AMT1,STMAIN.TAX_NAME,STITEM.TAX_NAME AS IT_TAXNAME,STMAIN.TAXAMT,STITEM.TAXAMT AS IT_TAXAMT,STMAIN.NET_AMT,STMAIN.U_PLASR,STMAIN.U_RG23NO,STMAIN.U_RG23CNO,STITEM.U_PKNO'+@stkl_qty+',STITEM.RATE,STITEM.U_ASSEAMT,STITEM.U_MRPRATE,STITEM.U_EXPDESC,STITEM.U_APPACK,STITEM.PACKSIZE1, cast (STITEM.NARR AS VARCHAR(2000)) AS NARR,STITEM.TOT_EXAMT'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.IDMARK,IT_MAST.RATEUNIT,IT_MAST.HSNCODE,IT_mast.U_ITPARTCD'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',MailName=(CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)'
	SET @QueryString =@QueryString+',AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.S_TAX,AC_MAST.I_TAX,AC_MAST.C_TAX,AC_MAST.ECCNO,AC_MAST.PHONE,AC_MAST.EMAIL,AC_MAST.STATE,AC_MAST.CONTACT,AC_MAST.U_VENCODE,AC_MAST1.ADD1 ADD11,AC_MAST1.ADD2 ADD22,AC_MAST1.ADD3 ADD33,AC_MAST1.CITY CITY1,AC_MAST1.ZIP ZIP1,AC_MAST1.S_TAX S_TAX1,AC_MAST1.I_TAX I_TAX1,AC_MAST1.C_TAX C_TAX1,AC_MAST1.ECCNO ECCNO1,AC_MAST1.PHONE PHONE1,AC_MAST1.EMAIL EMAIL1,AC_MAST1.STATE STATE1,AC_MAST1.CONTACT CONTACT1,AC_MAST1.U_VENCODE U_VENCODE1,STITEM.ITSERIAL'
	SET @QueryString =@QueryString+',STMAIN.tcsamt,STMAIN.tds_tp,Stitem.Tariff,STMAIN.roundoff'
	SET @QueryString =@QueryString+',mChapno=cast(isnull(substring((Select '''', '''' +rtrim(chapno) From Stitem Inner Join It_mast on (Stitem.It_code=It_mast.It_code) Where stitem.Entry_ty=stmain.Entry_ty and stitem.tran_cd=stmain.Tran_cd Group by chapno Order By chapno For XML Path('''')),2,2000),'''') as Varchar)'
	SET @QueryString =@QueryString+',mEIT_NAME=cast(isnull(substring((Select '''', '''' +rtrim(eit_name) From Stitem Inner Join It_mast on (Stitem.It_code=It_mast.It_code) Where stitem.Entry_ty=stmain.Entry_ty and stitem.tran_cd=stmain.Tran_cd Group by Eit_name Order By Eit_name For XML Path('''')),2,2000),'''') as Varchar(2000))'
	SET @QueryString =@QueryString+',progtotal=isnull(d.progtotal,0)'
	SET @QueryString =@QueryString+',Progcurrtotal=isnull(d.Progcurrtotal,0),Stmain.ServTxSrNo'
set @Tot_flds =''
Declare addi_flds cursor for
Select flds,fld_nm,att_file,data_ty from #tmpFlds
Open addi_flds
Fetch Next from addi_flds Into @fld,@fld_nm1,@att_file,@fld_type
While @@Fetch_Status=0
Begin
	if  charindex(@fld,@QueryString)=0
	begin
		-- Bug-19983 start
		if  charindex(@fld_type,'text')<>0
			begin
			 Set @Tot_flds=@Tot_flds+','+'CONVERT(VARCHAR(500),'+@fld+') AS '+substring(@fld,charindex('.',@fld)+1,len(@fld))  
			end
		else
		-- Bug-19983 end		
		begin
			Set @Tot_flds=@Tot_flds+','+@fld   -- Bug-19983
		end
	End
	Fetch Next from addi_flds Into @fld,@fld_nm1,@att_file,@fld_type 
End
Close addi_flds 
Deallocate addi_flds 
declare @sql as nvarchar(max)
print 'a'
print @QueryString
SET @SQLCOMMAND=''
set @sql= cAST(REPLICATE(@Tot_flds,4000) as nvarchar(100))
print @tot_flds
print '2222'
print @sql 
print '3333'
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM STMAIN' -- Bug-19983
 --SET @SQLCOMMAND =  @QueryString+@Tot_flds+' FROM STMAIN' -- Bug-19983
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD AND STMAIN.ENTRY_TY=STITEM.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN #stmain ON (STITEM.TRAN_CD=#stmain.TRAN_CD and STITEM.Entry_ty=#stmain.entry_ty and STITEM.ITSERIAL=#stmain.itserial) '
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_NAME=STMAIN.U_DELIVER)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' Left join #progtot d on (stmain.Tran_cd=d.Tran_cd)'	
SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY STMAIN.INV_SR,STMAIN.INV_NO'
execute sp_executesql @sqlcommand
GO
