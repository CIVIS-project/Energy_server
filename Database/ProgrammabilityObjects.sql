USE [Civis_Energy]
GO

/* Copyright 2016 - * by Concept Reply */
/* Authors: P. Dal Zovo, F. Cuscito */
/*Software developed within the scopes of the "CIVIS" EU Project http://www.civisproject.eu/ ( FP7-SMARTCITIES-2013 collaborative project, with cofunding of EU, Grant agreement no: 608774) */

USE [Civis_Energy]
GO
/****** Object:  UserDefinedTableType [dbo].[itemList]    Script Date: 6/23/2016 12:18:36 PM ******/
CREATE TYPE [dbo].[itemList] AS TABLE(
	[itemID] [nvarchar](50) NOT NULL
)
GO
/****** Object:  StoredProcedure [dbo].[dev_sp_compareMonthlyData]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[dev_sp_compareMonthlyData]

AS
BEGIN
DECLARE  @dsoMonthConsTable TABLE (apartmentID INT, Month Date, DSO_DRAW REAL, DSO_D_cov int, DSO_PROD REAL, DSO_P_cov int, DSO_FEEDIN REAL, DSO_F_cov int, S_CONS REAL, S_CONS_cov int, S_PROD REAL, S_PROD_cov int)
DECLARE @startMONTH date
set  @startMONTH = '2015-09-01'


  insert into @dsoMonthConsTable  (apartmentID , Month , DSO_DRAW , DSO_D_cov )  SELECT [ApartmentID]
      ,[Month]    
      ,sum(EnergyMeasure) as DSO_DRAW, sum([Datacoverage]) as coverage
  FROM [Civis_Energy].[dbo].[DSO_MonthlyElectricStats] 
  where [Cons_Prod_Feedin] ='C' and apartmentID in (SELECT [ApartmentID] FROM [Civis_Energy].[dbo].[Apartment] where DSO = 'CEDIS' )
   and  [Month] >= @startMONTH
    group by ApartmentID, [Month]

  insert into @dsoMonthConsTable  (apartmentID , Month , DSO_PROD , DSO_P_cov )  SELECT [ApartmentID]
      ,[Month]    
      ,sum(EnergyMeasure) , sum([Datacoverage]) 
  FROM [Civis_Energy].[dbo].[DSO_MonthlyElectricStats] 
  where [Cons_Prod_Feedin] ='P' and apartmentID in (SELECT [ApartmentID] FROM [Civis_Energy].[dbo].[Apartment] where DSO = 'CEDIS' )
   and  [Month] >= @startMONTH
    group by ApartmentID, [Month]

  insert into @dsoMonthConsTable  (apartmentID , Month , DSO_FEEDIN , DSO_F_cov )  SELECT [ApartmentID]
      ,[Month]    
      ,sum(EnergyMeasure) , sum([Datacoverage]) 
  FROM [Civis_Energy].[dbo].[DSO_MonthlyElectricStats] 
  where [Cons_Prod_Feedin] ='F' and apartmentID in (SELECT [ApartmentID] FROM [Civis_Energy].[dbo].[Apartment] where DSO = 'CEDIS' )
   and  [Month] >= @startMONTH
    group by ApartmentID, [Month]

  insert into @dsoMonthConsTable  (apartmentID , Month , S_CONS , S_CONS_cov )  
  SELECT [ApartmentID]
      ,[Month_StartDay]    
      ,floor(sum(EnergyMeasure)) as energy , sum([datacoverage])
  FROM [Civis_Energy].[dbo].[Sensors_MonthlyElectricStats] 
 where [SensorNumber] = 0 and apartmentID in (SELECT [ApartmentID] FROM [Civis_Energy].[dbo].[Apartment] where DSO = 'CEDIS' )
   and  [Month_StartDay] >= @startMONTH
    group by ApartmentID, [Month_StartDay]

       
  insert into @dsoMonthConsTable  (apartmentID , Month , S_PROD , S_PROD_cov )  
  SELECT [ApartmentID]
      ,[Month_StartDay]    
      ,floor(sum(EnergyMeasure)) as energy , sum([datacoverage])
  FROM [Civis_Energy].[dbo].[Sensors_MonthlyElectricStats] 
 where [SensorNumber] = 8 and apartmentID in (SELECT [ApartmentID] FROM [Civis_Energy].[dbo].[Apartment] where DSO = 'CEDIS' )
   and  [Month_StartDay] >= @startMONTH
    group by ApartmentID, [Month_StartDay]


  select apartmentID, Month , sum(DSO_DRAW) as DSO_DRAW, sum(DSO_D_cov) as DSO_DRAW_cov,  
             sum(DSO_PROD) as DSO_PROD, sum(DSO_P_cov) as DSO_P_cov,  
             sum(DSO_FEEDIN) as DSO_FEEDIN, sum(DSO_f_cov) as DSO_f_cov,  
                     sum(S_CONS) as S_CONS, sum(S_CONS_cov) as S_CONS_cov,   
                     sum(S_PROD) as S_PROD, sum(S_PROD_cov) as S_PROD_cov,  
                        sum(DSO_PROD) +  sum(DSO_DRAW)  - sum(DSO_FEEDIN) as DSO_DRAW,
                           case when (sum(S_CONS) >0 and sum(DSO_PROD) > 0)
                                        then 
                                        ((sum(DSO_PROD) +  sum(DSO_DRAW)  - sum(DSO_FEEDIN)) - sum(S_CONS)   )/ sum(S_CONS)
                                  when (sum(S_CONS) >0   and sum(DSO_PROD) is null)
                                        then 
                                        ((  sum(DSO_DRAW)   - sum(S_CONS)   )/ sum(S_CONS))
                           else NULL
                           end as ErrorOnNotNormalizedData,

                           case when (sum(S_CONS) >0 and sum(DSO_PROD) > 0)
                                        then 
                                        (((sum(DSO_PROD)/sum(DSO_P_cov)) +   (sum(DSO_DRAW)/ sum(DSO_D_cov))  - (sum(DSO_FEEDIN)/sum(DSO_f_cov))) - (sum(S_CONS)/sum(S_CONS_cov))   )/ (sum(S_CONS)/sum(S_CONS_cov))
                                  when (sum(S_CONS) >0   and sum(DSO_PROD) is null)
                                        then 
                                        ((  (sum(DSO_DRAW)/ sum(DSO_D_cov))    - (sum(S_CONS)/sum(S_CONS_cov))   )/ (sum(S_CONS)/sum(S_CONS_cov)))
                           else NULL
                           end as Error                      
   from @dsoMonthConsTable
    group by apartmentID, Month 
        --   having  sum(S_CONS_cov) > 2000000 -- per escludere casi di molti dati sensori mancanti
          having  apartmentID not in (111,77) --dati DSO di produzione mancanti
   order by  Error
END

GO
/****** Object:  StoredProcedure [dbo].[dev_sp_EnergyBetweenMoments]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[dev_sp_EnergyBetweenMoments]
	-- Add the parameters for the stored procedure here 
	@sensorNumber tinyint,
	@StartMoment datetimeoffset,
	@EndMoment datetimeoffset
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
	SELECT  [ApartmentID], 
		sum(SensorMeasure)/(SELECT DATEDIFF(SECOND, @StartMoment, @EndMoment))*3600.0 as avg,
		sum(SensorMeasure) as sum

	FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
	WHERE ([SensorNumber]=@sensorNumber) AND
		([ServerArrivalTime]>=@StartMoment) AND
		(ServerArrivalTime<=@EndMoment)
	group by  [ApartmentID]

END

GO
/****** Object:  StoredProcedure [dbo].[dev_sp_GETApartmentId]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Francesco Cuscito>
-- Create date: <2015-04-02>
-- Description:	<selects or creates an apartmentID into dbo.apartment table given a ContractID - POD data combination>
-- =============================================
CREATE PROCEDURE [dbo].[dev_sp_GETApartmentId]
	-- Add the parameters for the stored procedure here
		@POD varchar(30),
		@ContractID varchar(30),
		@id int =-1 OUTPUT,
		@FamilyID int = -1 OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

set @id = -1
set @FamilyID = -1

select apartmentID from [dbo].[Apartment]

where POD=@POD and contractID=@ContractID


IF @@ROWCOUNT > 0  /*se la coppia POD/ContractID è già registrata*/
	BEGIN 
		set @FamilyID=(SELECT FLOOR (2147483600)*RAND()) 
		set @id=(select apartmentID from [dbo].[Apartment]
		where POD=@POD and contractID=@ContractID)
		
	END
ELSE
		
		BEGIN
			set @FamilyID=(SELECT FLOOR (2147483600)*RAND()) 
			select apartmentID from [dbo].[Apartment]
			where contractID=@ContractID
			IF @@ROWCOUNT > 0
			    UPDATE [dbo].[Apartment]
					SET FamilyID= @FamilyID
				WHERE ApartmentID=apartmentID

			IF @@ROWCOUNT = 0  /*Se non esiste alcun utente con stesso ContractID già in tabella*/

			BEGIN

				select apartmentID from [dbo].[Apartment]
				where POD=@POD
				IF @@ROWCOUNT = 0 /*Se non esiste alcun utente con stesso POD già in tabella*/

					BEGIN

						INSERT INTO [dbo].[Apartment]   /*Crea una nuova riga nella tabella*/
							([DSO])
						VALUES
							('unknown')

						set @id=-1						/*a cui sarà assegnato un nuovo ApartmentID*/
						select @id = ( select top 1 [ApartmentID] from [dbo].[Apartment]  order by apartmentId DESC)
						UPDATE [dbo].[Apartment]
						SET FamilyID= @FamilyID
						WHERE ApartmentID=@id
					END
				ELSE
					set @id=-1						/*Se invece il ContractID o il POD è già presente, vuol dire che*/
			END
			ELSE										
				set @id=-1							/*la combinazione POD/ContractID specificata è errata*/	
		END

RETURN

END




GO
/****** Object:  StoredProcedure [dbo].[dev_sp_GetConsumptionByDayOffsets]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author: Francesco Cuscito>
-- Create date: <Create Date: 2015-03-13>
-- Description:	<Description: This SP calculates energy sums and averages for a selected sensor (sensorNumber) during a 
--				period of days going from "@StartDayOffset" days ago, to "EndDayOffset" days ago. >
--				Offsets from today: 0=today; 1=yesterday; 2=daybefore yesterday, etc
-- Example: EXEC [Civis_Energy].dbo.dev_sp_GetConsumptionByDayOffsets 2, 4, 1 calculates the sum and the average of energy
-- values associated to sensor #2 from 4 days ago to 1 days ago.
-- =============================================

CREATE PROCEDURE [dbo].[dev_sp_GetConsumptionByDayOffsets]
	-- Add the parameters for the stored procedure here 
	@sensorNumber tinyint,
	@StartDateOffset tinyint, 
	@EndDateOffset tinyint

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
	SELECT  [ApartmentID], 
		sum(SensorMeasure)/((@StartDateOffset-@EndDateOffset)*24.0) as avg,
		sum(SensorMeasure) as sum

	FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
	WHERE ([SensorNumber]=@sensorNumber) AND
		([ServerArrivalTime]>=CAST(DATEADD(day, DATEDIFF(day, @StartDateOffset, GETDATE()), 1) AS DATE)) AND
		([ServerArrivalTime]<CAST(DATEADD(day, DATEDIFF(day, @EndDateOffset, GETDATE()), 1) AS DATE))
	group by  [ApartmentID]

END

GO
/****** Object:  StoredProcedure [dbo].[dev_sp_GETNewApartmentId]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[dev_sp_GETNewApartmentId]
	-- Add the parameters for the stored procedure here
		@id int =-1 OUTPUT
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @id = -1
	select  @id = ( select top 1 [ApartmentID] from [dbo].[Apartment]  order by apartmentId DESC)
	SET @id = @id+1

	SET IDENTITY_INSERT [dbo].[Apartment] ON
	INSERT INTO [dbo].[Apartment]
		
		([ApartmentID], [DSO])
     VALUES
        (@id,'unknown')	

RETURN
	
END



GO
/****** Object:  StoredProcedure [dbo].[dev_sp_initApartmentIDandUserID]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[dev_sp_initApartmentIDandUserID]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--init apartments table with the some data coming from DSOs and a unique apartmentId

INSERT INTO [dbo].[Apartment]
          ( [DSO], [ContractID], [Tariff_code], [City], [POD])
 select distinct 'CEdiS' , [CdUtente], [tariffa], 'Storo', [POD]  FROM [Civis_Energy].[dbo].[CedisRawData] 
 Union
 (select distinct 'CEIS', contratto, [tariffa], 'San Lorenzo in Banale', [POD] FROM [Civis_Energy].[dbo].[CeisRawData]) 




END

GO
/****** Object:  StoredProcedure [dbo].[dev_sp_LastDaysConsumption]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[dev_sp_LastDaysConsumption]
	-- Add the parameters for the stored procedure here 
	@sensorNumber tinyint,
	@DateOffset tinyint

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;
	
    -- Insert statements for procedure here
	SELECT  [ApartmentID], 
		sum(SensorMeasure)/((@DateOffset+(SELECT DATEDIFF(SECOND, CAST(GETDATE() AS DATE), GETDATE()))/3600.0/24.0))/24.0 as avg,
		sum(SensorMeasure) as sum

	FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
	WHERE ([SensorNumber]=@sensorNumber) AND
		([ServerArrivalTime]>=(SELECT DATEADD(day, DATEDIFF(day, @DateOffset, GETDATE()), 0)))
	group by  [ApartmentID]

END

GO
/****** Object:  StoredProcedure [dbo].[sp_bulkCeisRawData]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_bulkCeisRawData] ( @filename nvarchar(400))
--
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE @sql NVARCHAR(4000) = 'BULK INSERT [dbo].[CeisRawData] FROM ''' + @fileName + ''' WITH ( FIELDTERMINATOR ='';'', 
FIRSTROW = 2,
ROWTERMINATOR =''\n'' ,
    ROWS_PER_BATCH = 10000 )';
EXEC(@sql);



END




GO
/****** Object:  StoredProcedure [dbo].[sp_Calc_ShiftableConsumption_MonthlyData]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Calc_ShiftableConsumption_MonthlyData]
	-- Add the parameters for the stored procedure here 

AS
BEGIN
/****** Script for SelectTopNRows command from SSMS  ******/

declare @alreadyProcessed  datetimeoffset 
set @alreadyProcessed =  (select  max([StartDate]) from [Civis_Energy].[dbo].[ShiftableConsumption])
set @alreadyProcessed = (coalesce ( @alreadyProcessed, '2010-01-01 00:00:00.0000000 +00:00'))

declare @currentDate  datetimeoffset 
set @currentDate =  ( select sysdatetimeoffset() ) 


INSERT INTO [Civis_Energy].[dbo].[ShiftableConsumption]
		   ([ApartmentID]
		   ,[SensorNumber]
		   ,[SensorLabel]
		   ,[StartDate]
		   ,[Measure]
		   ,[Timeslot])
SELECT cons.[ApartmentID]  
, meters.SensorNumber
, meters.SensorLabel
,	CAST(CAST(DATEPART(yyyy,[ClientStartTime]) AS varchar(4))+'-'+CAST(DATEPART(MM, [ClientStartTime]) AS varchar(2))+'-01' AS DATE)  AS StartDate
, sum([SensorMeasure]) as Measure
,[TimeSlot]
  FROM [Civis_Energy].[dbo].[Sensors_electricityData] cons, [Civis_Energy].[dbo].[ApartmentMeters] meters
  where  cons.[ApartmentID] = meters.[ApartmentID]
	 and cons.[SensorNumber]  = meters.[SensorNumber]
	 and (meters.SensorLabel = 'Lavastoviglie' or meters.SensorLabel = 'Lavatrice')
	 and (DATEPART(yyyy,[ClientStartTime]) + DATEPART(MM,[ClientStartTime]) > DATEPART(yyyy,@alreadyProcessed) + DATEPART(MM,@alreadyProcessed) ) --CAST(DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) as datetimeoffset))
	 and (DATEPART(yyyy,[ClientStartTime]) + DATEPART(MM,[ClientStartTime]) < DATEPART(yyyy,@currentDate) + DATEPART(MM,@currentDate) )
  group by cons.[ApartmentID]  
    , meters.SensorNumber
	, meters.SensorLabel
	,CAST(CAST(DATEPART(yyyy,[ClientStartTime]) AS varchar(4))+'-'+CAST(DATEPART(MM, [ClientStartTime]) AS varchar(2))+'-01' AS DATE) 
	,[TimeSlot]
	

UPDATE [dbo].[ShiftableConsumption] 
set [dbo].[ShiftableConsumption].AllTimeslots =  (SELECT sum([Measure]) as tot
  FROM [Civis_Energy].[dbo].[ShiftableConsumption]  s
  	  where 
	  s.[ApartmentID] =  [dbo].[ShiftableConsumption].[ApartmentID] and
      s.[SensorNumber] =  [dbo].[ShiftableConsumption].[SensorNumber] and
      s.[SensorLabel] =  [dbo].[ShiftableConsumption].[SensorLabel] and
      s.[StartDate] =  [dbo].[ShiftableConsumption].[StartDate]
	--  and s.AllTimeslots is null
  group by 
      [ApartmentID]
      ,[SensorNumber]
      ,[SensorLabel]
      ,[StartDate]
	  )

	--  select * from [ShiftableConsumption]


exec [dbo].[sp_Detect_ShiftableConsumption_MonthlyData] @start = @alreadyProcessed;

	
END



GO
/****** Object:  StoredProcedure [dbo].[sp_Calc_ShiftableConsumption_MonthlyData_old]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Calc_ShiftableConsumption_MonthlyData_old]
	-- Add the parameters for the stored procedure here 

AS
BEGIN
/****** Script for SelectTopNRows command from SSMS  ******/
INSERT INTO [Civis_Energy].[dbo].[ShiftableConsumption]
		   ([ApartmentID]
		   ,[SensorNumber]
		   ,[SensorLabel]
		   ,[StartDate]
		   ,[Measure]
		   ,[Timeslot])
	
SELECT cons.[ApartmentID]  
, meters.SensorNumber
, meters.SensorLabel
,	CAST(CAST(DATEPART(yyyy,[ClientStartTime]) AS varchar(4))+'-'+CAST(DATEPART(MM, [ClientStartTime]) AS varchar(2))+'-01' AS DATE)  AS StartDate
, sum([SensorMeasure]) as Measure
,[TimeSlot]
  FROM [Civis_Energy].[dbo].[Sensors_electricityData] cons, [Civis_Energy].[dbo].[ApartmentMeters] meters
  where  cons.[ApartmentID] = meters.[ApartmentID]
	 and cons.[SensorNumber]  = meters.[SensorNumber]
	 and (meters.SensorLabel = 'Lavastoviglie' or meters.SensorLabel = 'Lavatrice')
	 and (cons.[ClientStartTime] >= CAST(DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0) as datetimeoffset))
  group by cons.[ApartmentID]  
    , meters.SensorNumber
	, meters.SensorLabel
	,CAST(CAST(DATEPART(yyyy,[ClientStartTime]) AS varchar(4))+'-'+CAST(DATEPART(MM, [ClientStartTime]) AS varchar(2))+'-01' AS DATE) 
	,[TimeSlot]
	

	
UPDATE [dbo].[ShiftableConsumption] 
set [dbo].[ShiftableConsumption].AllTimeslots =  (SELECT sum([Measure]) as tot
  FROM [Civis_Energy].[dbo].[ShiftableConsumption]  s
  	  where 
	  s.[ApartmentID] =  [dbo].[ShiftableConsumption].[ApartmentID] and
      s.[SensorNumber] =  [dbo].[ShiftableConsumption].[SensorNumber] and
      s.[SensorLabel] =  [dbo].[ShiftableConsumption].[SensorLabel] and
      s.[StartDate] =  [dbo].[ShiftableConsumption].[StartDate]
  group by 
      [ApartmentID]
      ,[SensorNumber]
      ,[SensorLabel]
      ,[StartDate]
	  )

exec [dbo].[sp_Detect_ShiftableConsumption_MonthlyData]
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CalcOverall_Cedis_DailyStats]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CalcOverall_Cedis_DailyStats]
	-- Add the parameters for the stored procedure here 

AS
BEGIN
	declare @fromDate datetimeoffset		/* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2000*/
	set @fromDate = isnull((
	SELECT TOP 1 Day 
	FROM [dbo].[CedisEnergiaCedutaAllaRete_Daily] 
	WHERE Day < CAST(GETDATE() AS DATE)
	order by  Day DESC), '2000-01-01')

	declare @toDate datetimeoffset			/* calcola l'ultimo momento per il quale sono presenti dati in CedisRawEnergiaCedutaAllaRete*/
	set @toDate = isnull((
	SELECT TOP 1 FineCampione 
	FROM [dbo].[CedisRawEnergiaCedutaAllaRete] 
	WHERE (CAST([FineCampione] AS DATE) < CAST(DateAdd(DD,-1,GETDATE() ) AS DATE))
	order by  FineCampione DESC), '2000-01-01')
	

	INSERT INTO [CedisEnergiaCedutaAllaRete_Daily]
	SELECT DISTINCT CAST(a.[InizioCampione] AS DATE) AS Day, b.[ApartmentID], SUM(DATEDIFF(second,a.InizioCampione,a.FineCampione)) AS datacoverage,  sum(a.[ANegCedutaAllaRete]) AS EnergyMeasure, sum(a.[ANegCedutaAllaRete])/SUM(DATEDIFF(second,a.InizioCampione,a.FineCampione))*3600, a.[TimeSlot], Max(abs(a.DatoRicostruito))
	FROM [CedisRawEnergiaCedutaAllaRete] a, Apartment b
	WHERE b.[ContractID]=a.KW_C_UTENTE and [InizioCampione]>=DATEADD(day,1,@fromDate) AND [FineCampione] <= @toDate and a.ANegCedutaAllaRete is not null
	group by CAST(a.[InizioCampione] AS DATE), b.ApartmentID, a.[TimeSlot]
	order by  b.ApartmentID, CAST(a.[InizioCampione] AS DATE), a.[TimeSlot]

	declare @fromDate1 datetimeoffset		/* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2000*/
	set @fromDate1 = isnull((
	SELECT TOP 1 Day 
	FROM [dbo].[CedisEnergiaPrelevataDallaRete_Daily] 
	WHERE Day < CAST(GETDATE() AS DATE)
	order by  Day DESC), '2000-01-01')

	declare @toDate1 datetimeoffset			/* calcola l'ultimo momento per il quale sono presenti dati in CedisRawEnergiaPrelevataDallaRete*/
	set @toDate1 = isnull((
	SELECT TOP 1 FineCampione 
	FROM [dbo].[CedisRawEnergiaPrelevataDallaRete] 
	WHERE (CAST([FineCampione] AS DATE) < CAST(DateAdd(DD,-1,GETDATE() ) AS DATE))
	order by  FineCampione DESC), '2000-01-01')
	
	INSERT INTO [CedisEnergiaPrelevataDallaRete_Daily]
	SELECT DISTINCT CAST(a.[InizioCampione] AS DATE) AS Day, b.[ApartmentID], SUM(DATEDIFF(second,a.InizioCampione,a.FineCampione)) AS datacoverage,  sum(a.[AposPrelevataDaRete]) AS EnergyMeasure, sum(a.[AposPrelevataDaRete])/SUM(DATEDIFF(second,a.InizioCampione,a.FineCampione))*3600, a.[TimeSlot], Max(abs(a.DatoRicostruito))
	FROM [CedisRawEnergiaPrelevataDallaRete] a, Apartment b
	WHERE b.[ContractID]=a.KW_C_UTENTE and [InizioCampione]>=DATEADD(day,1,@fromDate1) AND [FineCampione] <= @toDate1 and a.AposPrelevataDaRete is not null
	group by CAST(a.[InizioCampione] AS DATE), b.ApartmentID, a.[TimeSlot]
	order by  b.ApartmentID, CAST(a.[InizioCampione] AS DATE), a.[TimeSlot]

	declare @fromDate2 datetimeoffset		/* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2000*/
	set @fromDate2 = isnull((
	SELECT TOP 1 Day 
	FROM [dbo].[CedisEnergiaProdotta_Daily] 
	WHERE Day < CAST(GETDATE() AS DATE)
	order by  Day DESC), '2000-01-01')

	declare @toDate2 datetimeoffset			/* calcola l'ultimo momento per il quale sono presenti dati in CedisRawEnergiaProdotta*/
	set @toDate2 = isnull((
	SELECT TOP 1 FineCampione 
	FROM [dbo].[CedisRawEnergiaProdotta] 
	WHERE (CAST([FineCampione] AS DATE) < CAST(DateAdd(DD,-1,GETDATE() ) AS DATE))
	order by  FineCampione DESC), '2000-01-01')

	INSERT INTO [CedisEnergiaProdotta_Daily]
	SELECT DISTINCT CAST(a.[InizioCampione] AS DATE) AS Day, b.[ApartmentID], SUM(DATEDIFF(second,a.InizioCampione,a.FineCampione)) AS datacoverage,  sum(a.[AposEnProdotta]) AS EnergyMeasure, sum(a.[AposEnProdotta])/SUM(DATEDIFF(second,a.InizioCampione,a.FineCampione))*3600, a.[TimeSlot], Max(abs(a.DatoRicostruito))
	FROM [CedisRawEnergiaProdotta] a, Apartment b
	WHERE b.[ContractID]=a.KW_C_UTENTE and [InizioCampione]>=DATEADD(day,1,@fromDate2) AND [FineCampione] <= @toDate2 and a.AposEnProdotta is not null
	group by CAST(a.[InizioCampione] AS DATE), b.ApartmentID, a.[TimeSlot]
	order by  b.ApartmentID, CAST(a.[InizioCampione] AS DATE), a.[TimeSlot]
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CalcOverall_Cedis_MonthlyStats]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CalcOverall_Cedis_MonthlyStats]
	-- Add the parameters for the stored procedure here 

AS
BEGIN
	declare @fromDate date		/* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2000*/
	set @fromDate = isnull((
	SELECT TOP 1 Month 
	FROM [dbo].[DSO_MonthlyElectricStats] 
	WHERE Month < CAST(GETDATE() AS DATE) and DSO='CEDIS' and Cons_Prod_Feedin='F'
	order by  Month DESC), '2000-01-01')

	set @fromDate = CAST(CAST(DATEPART(yyyy,@fromDate) AS varchar(4))+'-'+CAST(DATEPART(MM, @fromDate)+1 AS varchar(2))+'-01' AS DATE)

	declare @toDate date			/* calcola l'ultimo momento per il quale sono presenti dati*/
	set @toDate = isnull((
	SELECT TOP 1 CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE) AS Monthstart 
	FROM [dbo].[CedisEnergiaCedutaAllaRete_Daily] 
	order by Monthstart DESC), '2000-01-01')

	INSERT INTO DSO_MonthlyElectricStats
	SELECT DISTINCT 
		[ApartmentID],
		'CEDIS' AS DSO,
		CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE)  AS Month,
		sum(EnergyMeasure)/sum(DataCoverage)*3600,
		SUM(EnergyMeasure) AS Energy,	
		[Timeslot],
		'F' AS Cons_Prod_FeedIn,
		SUM(DataCoverage),
		SUM(InferredSampleNumber)
	FROM [Civis_Energy].[dbo].[CedisEnergiaCedutaAllaRete_Daily] 
	WHERE Day>=@fromDate AND Day <@toDate
	group by [ApartmentID], CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE) , TimeSlot
	order by [ApartmentID], [Month], [TimeSlot]

	declare @fromDate1 date		/* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2000*/
	set @fromDate1 = isnull((
	SELECT TOP 1 Month 
	FROM [dbo].[DSO_MonthlyElectricStats] 
	WHERE Month < CAST(GETDATE() AS DATE) and DSO='CEDIS' and Cons_Prod_Feedin='C'
	order by  Month DESC), '2000-01-01')

	set @fromDate1 = CAST(CAST(DATEPART(yyyy,@fromDate1) AS varchar(4))+'-'+CAST(DATEPART(MM, @fromDate1)+1 AS varchar(2))+'-01' AS DATE)

	declare @toDate1 date			/* calcola l'ultimo momento per il quale sono presenti dati*/
	set @toDate1 = isnull((
	SELECT TOP 1 CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE) AS Monthstart 
	FROM [dbo].[CedisEnergiaPrelevataDallaRete_Daily] 
	order by Monthstart DESC), '2010-01-01')

	INSERT INTO DSO_MonthlyElectricStats
	SELECT DISTINCT 
		[ApartmentID],
		'CEDIS' AS DSO,
		CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE)  AS Month,
		sum(EnergyMeasure)/sum(DataCoverage)*3600,
		SUM(EnergyMeasure) AS Energy,	
		[Timeslot],
		'C' AS Cons_Prod_FeedIn,
		SUM(DataCoverage),
		SUM(InferredSampleNumber)
	FROM [Civis_Energy].[dbo].[CedisEnergiaPrelevataDallaRete_Daily] 
	WHERE Day>=@fromDate1 AND Day <@toDate1
	group by [ApartmentID], CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE) , TimeSlot
	order by [ApartmentID], [Month], [TimeSlot]

	declare @fromDate2 date		/* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2000*/
	set @fromDate2 = isnull((
	SELECT TOP 1 Month 
	FROM [dbo].[DSO_MonthlyElectricStats] 
	WHERE Month < CAST(GETDATE() AS DATE) and DSO='CEDIS' and Cons_Prod_Feedin='P'
	order by  Month DESC), '2000-01-01')

	set @fromDate2 = CAST(CAST(DATEPART(yyyy,@fromDate2) AS varchar(4))+'-'+CAST(DATEPART(MM, @fromDate2)+1 AS varchar(2))+'-01' AS DATE)

	declare @toDate2 date			/* calcola l'ultimo momento per il quale sono presenti dati*/
	set @toDate2 = isnull((
	SELECT TOP 1 CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE) AS Monthstart 
	FROM [dbo].[CedisEnergiaProdotta_Daily] 
	order by Monthstart DESC), '2010-01-01')

	INSERT INTO DSO_MonthlyElectricStats
	SELECT DISTINCT 
		[ApartmentID],
		'CEDIS' AS DSO,
		CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE)  AS Month,
		sum(EnergyMeasure)/sum(DataCoverage)*3600,
		SUM(EnergyMeasure) AS Energy,	
		[Timeslot],
		'P' AS Cons_Prod_FeedIn,
		SUM(DataCoverage),
		SUM(InferredSampleNumber)
	FROM [Civis_Energy].[dbo].[CedisEnergiaProdotta_Daily] 
	WHERE Day>=@fromDate2 AND Day <@toDate2
	group by [ApartmentID], CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE) , TimeSlot
	order by [ApartmentID], [Month], [TimeSlot]
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CalcOverallDailyElectricStats]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author: Francesco Cuscito>
-- Create date: <Create Date: 2015-03-23>
-- Description:	<Description: This SP calculates energy sums and averages for an apartment in each of the three timeslots F1/F2/F3 
--				defined by Italian Energy Authority. The Sensors_DailyElectricStats is updated starting from the last value 
--				uptaded in the previous call of the Stored Procedure>
-- =============================================

CREATE PROCEDURE [dbo].[sp_CalcOverallDailyElectricStats]
	-- Add the parameters for the stored procedure here 

AS
BEGIN
	declare @fromDate datetimeoffset		/* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2010*/
	set @fromDate = isnull((
	SELECT TOP 1 Day 
	FROM [dbo].[Sensors_DailyElectricStats] 
	WHERE Day < CAST(GETDATE() AS datetimeoffset)
	order by  Day DESC), '2010-01-01')

	declare @toDate datetimeoffset			/* calcola l'ultimo momento per il quale sono presenti dati*/
	set @toDate = isnull((
	SELECT TOP 1 ClientStopTime 
	FROM [dbo].[Sensors_electricityData] 
	WHERE (CAST([ClientStopTime] AS DATE) < CAST(GETDATE()  AS DATE))
	order by  ClientStopTime DESC), '2010-01-01')
	

	INSERT INTO [Sensors_DailyElectricStats]
	SELECT DISTINCT CAST([ClientStopTime] AS DATE) AS Date, [ApartmentID], SUM(DATEDIFF(second,ClientStartTime,ClientStopTime)) AS datacoverage,  [SensorNumber], [TimeSlot] ,  sum([SensorMeasure]) AS EnergyMeasure, sum([SensorMeasure])/SUM(DATEDIFF(second,ClientStartTime,ClientStopTime))*3600, [ConsVsProd]
	FROM [dbo].[Sensors_electricityData]
	WHERE   [ClientStartTime]>=DATEADD(day,1,@fromDate) AND [ClientStopTime] <= @toDate 
			AND (NTPsynched=1 OR NTPsynched=3)
			--from here conditions added to keep into account the RadioErrorIndex and discart not reliable samples - 04/12/2015
			AND (
			(((RadioErrorIndex=3 and SensorMeasure/(DATEDIFF(ss,ClientStartTime,ClientStopTime)/3600.0)<600.0) or RadioErrorIndex<3) and SensorMeasure/(DATEDIFF(ss,ClientStartTime,ClientStopTime)/3600.0)<6600.0 and SensorNumber=0) 
			or
			(((RadioErrorIndex=3 and SensorMeasure/(DATEDIFF(ss,ClientStartTime,ClientStopTime)/3600.0)<=300.0) or RadioErrorIndex<3) and SensorMeasure/(DATEDIFF(ss,ClientStartTime,ClientStopTime)/3600.0)<=3850.0 and SensorNumber!=0 and SensorNumber!=8)
			or
			(((RadioErrorIndex=4 and SensorMeasure/(DATEDIFF(ss,ClientStartTime,ClientStopTime)/3600.0)<=2000.0) or RadioErrorIndex<4) and SensorMeasure/(DATEDIFF(ss,ClientStartTime,ClientStopTime)/3600.0)<6600.0 and SensorNumber=8)
			)
	group by CAST([ClientStopTime] AS DATE), [ApartmentID], [SensorNumber], [TimeSlot], [ConsVsProd]
	order by  [ApartmentID], CAST([ClientStopTime] AS DATE), [SensorNumber], [ConsVsProd], [TimeSlot]



END



GO
/****** Object:  StoredProcedure [dbo].[sp_CalcOverallDailyElectricStats-old]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CalcOverallDailyElectricStats-old]
	-- Add the parameters for the stored procedure here 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;
 
    -- Insert statements for procedure here
	--declare @fromDate datetimeoffset
	--set @fromDate = isnull((
	--SELECT TOP 1 MaxTimestamp 
	--FROM [dbo].[Sensors_DailyElectricStats] 
	--WHERE (CAST([MaxTimestamp] AS DATE) < CAST(GETDATE() AS DATE))
	--order by  MaxTimestamp DESC), '2010-01-01')

	--declare @toDate datetimeoffset
	--set @toDate = isnull((
	--SELECT TOP 1 ClientStopTime 
	--FROM [dbo].[Sensors_electricityData] 
	--WHERE (CAST([ClientStopTime] AS DATE) < CAST(GETDATE() AS DATE))
	--order by  ClientStopTime DESC), '2010-01-01')
	

	--INSERT INTO [Sensors_DailyElectricStats]
	--SELECT CAST([ClientStopTime] AS DATE) AS Date, min(ClientStopTime) , max(ClientStopTime), [ApartmentID], [SensorNumber], [TimeSlot] ,  sum([SensorMeasure]) AS EnergyMeasure, SUM(SensorMeasure)/24.0 AS AveragePowerMeasure, [ConsVsProd]
	--FROM [dbo].[Sensors_electricityData]
	--WHERE [ClientStopTime]>@fromDate AND [ClientStopTime] <= @toDate
	--group by CAST([ClientStopTime] AS DATE), [ApartmentID], [SensorNumber], [TimeSlot], [ConsVsProd]
	--order by  [ApartmentID], CAST([ClientStopTime] AS DATE), [SensorNumber], [ConsVsProd], [TimeSlot]



END



GO
/****** Object:  StoredProcedure [dbo].[sp_CalcOverallMonthlyElectricStats]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:          <Author: Francesco Cuscito>
-- Create date: <Create Date: 2015-09-23; Modified on 2015-12-02>
-- Description:     <Description: This SP calculates energy sums and averages for an apartment in each of the three timeslots F1/F2/F3
--                         defined by Italian Energy Authority. The Sensors_MonthlyElectricStats table is updated starting from the last value
--                         uptaded in the previous call of the Stored Procedure>
-- =============================================
 
CREATE PROCEDURE [dbo].[sp_CalcOverallMonthlyElectricStats]
       -- Add the parameters for the stored procedure here
       @run_time int -- 0  if executed the on first launch of the platform, 1 for successive runs
AS
BEGIN
       declare @fromDate datetimeoffset        /* seleziona l'ultimo giorno per cui la SP è già stata applicata a partire dal 2010*/
       set @fromDate = isnull((
       SELECT TOP 1 Month_StartDay
       FROM [dbo].[Sensors_MonthlyElectricStats]
       WHERE Month_StartDay < CAST(GETDATE() AS DATE)
       order by  Month_StartDay DESC), '2010-01-01')

	   declare @lastMonthEndDay nvarchar(5)  --conterrà l'ultimo giorno dell'ultimo mese completato nella forma 'MM-dd'
	   declare @lastMonth nvarchar(2)		 --conterrà il numero cardinale dell'ultimo mese completato
	   declare @currentMonth int			 --conterrà il numero cardinale del mese corrente
	   declare @yearOfLastMonthEndDay nvarchar(4)  --conterrà l'anno associato all'ultimo giorno dell'ultimo mese completato
	   
	   set @currentMonth= isnull((				--calcola il mese corrente nella tabella delle statistiche giornaliere
       SELECT TOP 1 DATEPART(MM, Day)
       FROM [dbo].[Sensors_DailyElectricStats]
       order by Day DESC), 1)
	   
	   /*inizia ora il calcolo della data dell'ultimo giorno che si dovrà considerare per generare statistiche mensili*/

	   -- questo if seleziona l'anno dell'ultimo mese completamente trascorso considerando che se siamo a gennaio, l'ultimo
	   -- mese completato è dell'anno precedente
	   if @currentMonth=1 set @yearOfLastMonthEndDay=(SELECT TOP 1 CAST(DATEPART(yyyy,Day)-1 AS varchar(4)) as Year
													  FROM [dbo].[Sensors_DailyElectricStats]
													  ORDER by Year DESC) 
	   else set @yearOfLastMonthEndDay=(SELECT TOP 1 CAST(DATEPART(yyyy,Day) AS varchar(4)) as Year
													  FROM [dbo].[Sensors_DailyElectricStats]
													  ORDER by Year DESC)

	   if @currentMonth=1 
			BEGIN
				set @lastMonthEndDay='12-31'  --se siamo a gennaio, l'ultimo mese si è completato il 31/12 
				set @lastMonth='12'
			END
	   else 
	   BEGIN
		   set @lastMonth=CAST(@currentMonth-1 AS nvarchar(2))
		   if @currentMonth=3   --se siamo a Marzo, l'ultimo mese si è completato il 28 o il 29 febbraio
				BEGIN
					set @lastMonthEndDay='02-28'
					if CAST(@yearOfLastMonthEndDay AS int)%4=0   --metodo approssimato per determinare anno bisestile
					set @lastMonthEndDay='02-29'
				END
				--se siamo a maggio, luglio, ottobre o dicembre, l'ultimo mese si è completato il 30 del mese precedente
		   else if (@currentMonth=5 or @currentMonth=7 or @currentMonth=10 or @currentMonth= 12) set @lastMonthEndDay=CAST(@currentMonth-1 AS nvarchar(2))+'-30'
		   else set @lastMonthEndDay=CAST(@currentMonth-1 AS nvarchar(2))+'-31'  --altrimenti il 31 del mese precedente
	   END
	   
 
       declare @toDate datetimeoffset                 /* calcola la data completa dell'ultimo giorno del mese appena completato  */
       set @toDate = @yearOfLastMonthEndDay+'-'+@lastMonthEndDay
 
		/* si calcolano ora le statistiche mensili dalla data di partenza a quella di fine e li si inseriscono in tabella*/
       INSERT INTO Sensors_MonthlyElectricStats
       SELECT DISTINCT
             CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE)  AS Month_StartDay,
             [ApartmentID],
             SUM(datacoverage),
             [SensorNumber],
             [Timeslot],
             SUM(EnergyMeasure) AS Energy,
             sum(EnergyMeasure)/sum(datacoverage)*3600,
             ConsVsProd
       FROM [Civis_Energy].[dbo].[Sensors_DailyElectricStats]
       WHERE Day>=DATEADD(month,1,@fromDate) AND Day <=@toDate
       group by [ApartmentID], CAST(CAST(DATEPART(yyyy,Day) AS varchar(4))+'-'+CAST(DATEPART(MM, Day) AS varchar(2))+'-01' AS DATE) , SensorNumber, TimeSlot, ConsVsProd
       order by [ApartmentID], [Month_StartDay], [SensorNumber], [ConsVsProd], [TimeSlot]
 
       IF @run_time=0   --non dovrebbe più essere necessario: da rimuovere
             DELETE FROM [dbo].[Sensors_MonthlyElectricStats]
             Where Month_StartDay=@toDate
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CalcRecoveredTimeSlot]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author: Francesco Cuscito>
-- Create date: <Create Date: 2015-10-22>
-- Description:	<Description: This SP calculates the timeslot associated to a sample in the Cedis raw data tables>
-- =============================================

CREATE PROCEDURE [dbo].[sp_CalcRecoveredTimeSlot]
	-- Add the parameters for the stored procedure here 
	-- Add the parameters for the stored procedure here 
AS
BEGIN	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE Sensors_electricityRecover
	SET TimeSlot='F3'
	WHERE TimeSlot is null and ((CAST(ClientStopTime AS Time)<'07:00' 
								or CAST(ClientStopTime AS Time)>='23:00' 
								or dbo.fn_isHoliday(CAST(ClientStopTime AS Date))=1))
	UPDATE Sensors_electricityRecover
	SET TimeSlot='F2'
	WHERE TimeSlot is null and ((CAST(ClientStopTime AS Time)>='07:00' and CAST(ClientStopTime AS Time)<'08:00') 
							or (CAST(ClientStopTime AS Time)>='19:00' and CAST(ClientStopTime AS Time)<'23:00') 
							and dbo.fn_isHoliday(CAST(ClientStopTime AS Date))=0)
	UPDATE Sensors_electricityRecover
	SET TimeSlot='F1'
	WHERE TimeSlot is null and (CAST(ClientStopTime AS Time)>='08:00' and CAST(ClientStopTime AS Time)<'19:00' 
								and datename(DW,CAST(ClientStopTime AS Date)) != 'Saturday' 
								and dbo.fn_isHoliday(CAST(ClientStopTime AS Date))=0)
	UPDATE Sensors_electricityRecover
	SET TimeSlot='F2'
	WHERE TimeSlot is null and (CAST(ClientStopTime AS Time)>='08:00' and CAST(ClientStopTime AS Time)<'19:00' 
								and datename(DW,CAST(ClientStopTime AS Date)) = 'Saturday' 
								and dbo.fn_isHoliday(CAST(ClientStopTime AS Date))=0)

END

GO
/****** Object:  StoredProcedure [dbo].[sp_CalcTimeSlot]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author: Francesco Cuscito>
-- Create date: <Create Date: 2015-10-22>
-- Description:	<Description: This SP calculates the timeslot associated to a sample in the Cedis raw data tables>
-- =============================================

CREATE PROCEDURE [dbo].[sp_CalcTimeSlot]
	-- Add the parameters for the stored procedure here 
	-- Add the parameters for the stored procedure here 
	@DataTable nvarchar(100)
AS
BEGIN	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	EXEC ('UPDATE ' + @DataTable +'
	SET TimeSlot=''F3''
	WHERE TimeSlot is null and ((CAST(InizioCampione AS Time)<''07:00'' 
								or CAST(InizioCampione AS Time)>=''23:00'' 
								or dbo.fn_isHoliday(CAST(InizioCampione AS Date))=1))')
	EXEC ('UPDATE ' + @DataTable +'
	SET TimeSlot=''F2''
	WHERE TimeSlot is null and ((CAST(InizioCampione AS Time)>=''07:00'' and CAST(InizioCampione AS Time)<''08:00'') 
							or (CAST(InizioCampione AS Time)>=''19:00'' and CAST(InizioCampione AS Time)<''23:00'') 
							and dbo.fn_isHoliday(CAST(InizioCampione AS Date))=0)')
	EXEC ('UPDATE ' + @DataTable +'
	SET TimeSlot=''F1''
	WHERE TimeSlot is null and (CAST(InizioCampione AS Time)>=''08:00'' and CAST(InizioCampione AS Time)<''19:00'' 
								and datename(DW,CAST(InizioCampione AS Date)) != ''Saturday'' 
								and dbo.fn_isHoliday(CAST(InizioCampione AS Date))=0)')
	EXEC ('UPDATE ' + @DataTable +'
	SET TimeSlot=''F2''
	WHERE TimeSlot is null and (CAST(InizioCampione AS Time)>=''08:00'' and CAST(InizioCampione AS Time)<''19:00'' 
								and datename(DW,CAST(InizioCampione AS Date)) = ''Saturday'' 
								and dbo.fn_isHoliday(CAST(InizioCampione AS Date))=0)')

END
GO
/****** Object:  StoredProcedure [dbo].[sp_Detect_ShiftableConsumption_MonthlyData]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Detect_ShiftableConsumption_MonthlyData] @start datetimeoffset
	-- Add the parameters for the stored procedure here 

AS
BEGIN
/****** Script for SelectTopNRows command from SSMS  ******/

INSERT INTO [dbo].[DetectedSituation]
           ([SituationID]
           ,[ApartmentID]
           ,[TimeStart]
          -- ,[TimeStop]
           ,[Information]
			 ,[Accepted]
           ,[TimeDetected])
SELECT  
     replace(convert(varchar,[StartDate]),' 00:00:00.0000000 +0','-') + convert(varchar,   [ApartmentID]) +  '_' + convert(varchar,  sensorNumber) +  '_Shift_' + [SensorLabel]--+ convert(varchar, getdate(), 126) +
		 ,[ApartmentID]
     -- ,[SensorNumber]
      ,[StartDate]
      ,convert(varchar, 100 * [Measure]/[AllTimeslots]) + '% di consumi ('+ convert(varchar,[Measure]) + ' W) ' + [SensorLabel] + ' in fascia F1'
	  +  case 

			when  --casa indipendente e a casa nel weekend
				ApartmentID  in (select ApartmentID from [CivisUsers].[dbo].[UsersData] where [1#1 Building type] =1 or [1#1 Building type] =2 ) 
			then  '| spostare consumi a sera/notte'
			else  '| spostare consumi alla sera ' end
	  + case
			when  --a casa nel weekend
				ApartmentID not in (select ApartmentID from [CivisUsers].[dbo].[UsersData] where( [3#6 people at home NON-WORKING DAYS7 - 10] =1 and 
				[3#6 people at home NON-WORKING DAYS10 - 13] = 1 and
				[3#6 people at home NON-WORKING DAYS13 - 16]= 1 and
				[3#6 people at home NON-WORKING DAYS16 - 19]= 1 and
				[3#6 people at home NON-WORKING DAYS19 - 21] = 1))
			then  '| spostare consumi a giorni festivi o prefestivi (F2-3)'
		else  '' end
	 , NULL
	  ,getdate()
  FROM [Civis_Energy].[dbo].[ShiftableConsumption]
 where [Timeslot] = 'F1'
 and [AllTimeslots] > 0
 and Measure / [AllTimeslots]  > 0.5
 and  [ApartmentID] not in (SELECT  [ApartmentID] FROM [Civis_Energy].[dbo].[Apartment] where PV = 1)
 and [StartDate] > @start
	
END


GO
/****** Object:  StoredProcedure [dbo].[sp_Detect_ShiftableConsumption_MonthlyData_old]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Detect_ShiftableConsumption_MonthlyData_old]
	-- Add the parameters for the stored procedure here 

AS
BEGIN
/****** Script for SelectTopNRows command from SSMS  ******/

INSERT INTO [dbo].[DetectedSituation]
           ([SituationID]
           ,[ApartmentID]
           ,[TimeStart]
          -- ,[TimeStop]
           ,[Information]
			 ,[Accepted]
           ,[TimeDetected])
SELECT  
     replace(convert(varchar,[StartDate]),' 00:00:00.0000000 +0','-') + convert(varchar,   [ApartmentID]) +  '_' + convert(varchar,  sensorNumber) +  '_' + [SensorLabel]--+ convert(varchar, getdate(), 126) +
		 ,[ApartmentID]
     -- ,[SensorNumber]
      ,[StartDate]
      ,convert(varchar, 100 * [Measure]/[AllTimeslots]) + '% di consumi ('+ convert(varchar,[Measure]) + ' W) ' + [SensorLabel] + ' in fascia F1'
	 , NULL
	  ,getdate()
  FROM [Civis_Energy].[dbo].[ShiftableConsumption]
 where [Timeslot] = 'F1'
 and [AllTimeslots] > 0
 and Measure / [AllTimeslots]  > 0.5
 and  [ApartmentID] not in (SELECT  [ApartmentID] FROM [Civis_Energy].[dbo].[Apartment] where PV = 1)
	
END


GO
/****** Object:  StoredProcedure [dbo].[sp_DetectOverheating]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DetectOverheating]
	-- Add the parameters for the stored procedure here
	@DateFirst DateTimeoffset(7), -- = '2015-05-26 16:00:21 +02:00',
    @DateLast DateTimeoffset(7), -- = '2015-05-26 17:00:21 +02:00',
	@externalTemperatureThreshold real = 12, --default value for Trentino
	@internalDayTemperatureThreshold real = 20,
	@internalNightTemperatureThreshold real = 18,
	@DayHourStart int = 5, --daytime (23-5), nighttime (23-5)
	@DayHourEnd int = 23,
	@nightDuration  DateTimeoffset(7) ='06:00:00'
AS
BEGIN
	delete from [dbo].[DetectedOverheating]
	delete from esternalTemperatureTable

	insert into esternalTemperatureTable
	SELECT         [PositionID],avg([Temperature]), min([ClientTimestamp]), max([ClientTimestamp])
  FROM  [dbo].[OEM_Data]
  where 
 --  outdoor temperature minor than @externalTemperatureThreshold and  
 SensorNumber = 33 and --external sensor
  [Temperature] < @externalTemperatureThreshold 
  and [Temperature] < 40 -- to avoid wrong failure in case the tmperature sensor issue providing 85 error value occurs again
  and [NTPsynched] = 1
  and [ClientTimestamp] between @DateFirst and @DateLast
  group by ApartmentID,  positionID

  
if  (   ( DATEPART(hour,@DateFirst) >= @DayHourStart and DATEPART(hour,@DateFirst) < @DayHourEnd) ) 
BEGIN
print 'daytime' 
print @DateFirst 
insert into [dbo].[DetectedOverheating]
SELECT    convert(varchar, [ApartmentID])  + '_' + replace(convert(varchar,@DateFirst),'.0000000 +0','-') + 'DayOverHeating'
		, [ApartmentID]
	 ,@DateFirst slotStart
	  ,@DateLast slotEnd
     -- ,min([ClientTimestamp])
     -- ,max([Temperature])
	--  ,min([Temperature])
	--  ,avg([Temperature])
      , 'area' + convert(varchar,[PositionID])
	  ,'-'
	  , null
	  , ''
	 
  FROM  [dbo].[OEM_Data],
  esternalTemperatureTable ext
  where ext.extPositionID = [PositionID] and [NTPsynched]=1 
  and [ClientTimestamp] between @DateFirst and @DateLast
  and  SensorNumber = 32 and --internal sensor
  [Temperature] < 40 --and-- to avoid wrong failure in case the tmperature sensor issue providing 85 error value occurs again
 --  outdoor temperature minor than 12°C and    
 --( --( [Temperature] > @internalNightTemperatureThreshold and ( DATEPART(hour,[ClientTimestamp]) <=5 or DATEPART(hour,[ClientTimestamp]) >= 23) ) or -- nighttime (23-5)
  --( --[Temperature] > @internalDayTemperatureThreshold and 
  --( DATEPART(hour,[ClientTimestamp]) > @DayHourStart or DATEPART(hour,[ClientTimestamp]) < @DayHourEnd) ))
group by ApartmentID, PositionID
having avg([Temperature]) >  @internalDayTemperatureThreshold 


-- select * from esternalTemperatureTable
-- select * from [DetectedOverheating]

--insert into detected situation 
--update DetectedSituation


--caso1 no more dayoverheating
UPDATE [dbo].[DetectedSituation2]
set [dbo].DetectedSituation2.TimeStop =   @DateFirst
 where  [dbo].[DetectedSituation2].TimeStop is null 
     and SituationID like '%DayOverHeating' 
 and ApartmentID not in 
   (select ApartmentID from  [dbo].[DetectedOverheating] where SituationID like '%DayOverheating')


--caso 2 no open alert yet, open new
insert into DetectedSituation2
SELECT [SituationID]
      ,[ApartmentID]
      ,[TimeStart]
      ,null --[TimeStop]
      ,[Information]
      ,[Accepted]
      ,[TimeStop]
      ,[Additional_info]
  FROM  [dbo].[DetectedOverheating] where ApartmentID not in
   (select ApartmentID from  [dbo].[DetectedSituation2] where  (timestop is null) and SituationID like '%DayOverheating')

--caso 3  open alert already


--
if (DATEPART(hour,@DateFirst) = @DayHourStart) --it's day --terminate open NightOverheating alert
UPDATE [dbo].[DetectedSituation2]
set [dbo].DetectedSituation2.TimeStop = @DateFirst
 where  [dbo].[DetectedSituation2].TimeStop is null 
     and SituationID like '%NightOverHeating' 

END--end daytime analysis

else if  (   ( DATEPART(hour,@DateFirst) >= @DayHourEnd or DATEPART(hour,@DateFirst) < @DayHourEnd) ) 

BEGIN --nighttime

if (DATEPART(hour,@DateFirst) = @DayHourEnd) --it's night terminate open DayOverheating alert
UPDATE [dbo].[DetectedSituation2]
set [dbo].DetectedSituation2.TimeStop =  @DateFirst --ToDateTimeOffset(   @DateFirst - CONVERT(datetime, @nightDuration), DATEPART(TZOFFSET,  @DateFirst)) 
 where  [dbo].[DetectedSituation2].TimeStop is null 
     and SituationID like '%DayOverHeating' 


print 'nighttime' 
print @DateFirst 
insert into [dbo].[DetectedOverheating]
SELECT    convert(varchar, [ApartmentID])  + '_' + replace(convert(varchar,@DateFirst),'.0000000 +0','-') + 'NightOverHeating'
		, [ApartmentID]
	 ,@DateFirst slotStart
	  ,@DateLast slotEnd
     -- ,min([ClientTimestamp])
     -- ,max([Temperature])
	--  ,min([Temperature])
	--  ,avg([Temperature])
      , 'area' + convert(varchar,[PositionID])
	  ,'-'
	  , null
	  , ''
  FROM  [dbo].[OEM_Data],
  esternalTemperatureTable ext
  where ext.extPositionID = [PositionID] and [NTPsynched]=1 
  and [ClientTimestamp] between @DateFirst and @DateLast
  and  SensorNumber = 32 and --internal sensor
  [Temperature] < 40 -- to avoid wrong failure in case the tmperature sensor issue providing 85 error value occurs again
 --  outdoor temperature minor than 12°C and    
-- ( --( [Temperature] > @internalNightTemperatureThreshold and ( DATEPART(hour,[ClientTimestamp]) <=5 or DATEPART(hour,[ClientTimestamp]) >= 23) ) or -- nighttime (23-5)
 -- ( --[Temperature] > @internalDayTemperatureThreshold and 
 -- ( DATEPART(hour,[ClientTimestamp]) < @DayHourStart or DATEPART(hour,[ClientTimestamp]) < @DayHourEnd) ))
group by ApartmentID, PositionID
having avg([Temperature]) >  @internalNightTemperatureThreshold 


-- select * from esternalTemperatureTable
-- select * from [DetectedOverheating]

--insert into detected situation 
--update DetectedSituation


--caso1 no more nightoverheating
UPDATE [dbo].[DetectedSituation2]
set [dbo].DetectedSituation2.TimeStop =   @DateFirst
 where  [dbo].[DetectedSituation2].TimeStop is null 
     and SituationID like '%NightOverHeating' 
	and ApartmentID not in 
   (select ApartmentID from  [dbo].[DetectedOverheating] where SituationID like '%NightOverheating')


--caso 2 no open alert yet, open new
insert into DetectedSituation2
SELECT [SituationID]
      ,[ApartmentID]
      ,[TimeStart]
      ,null --[TimeStop]
      ,[Information]
      ,[Accepted]
      ,[TimeStop]
      ,[Additional_info]
  FROM  [dbo].[DetectedOverheating] where ApartmentID not in
   (select ApartmentID from  [dbo].[DetectedSituation2] where  (timestop is null) and SituationID like '%NightOverheating')

--caso 3  open alert already




END

--select @DateFirst
--select * from  [dbo].[DetectedOverheating]
--select * from [DetectedSituation2]

END



GO
/****** Object:  StoredProcedure [dbo].[sp_extractAverageData]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_extractAverageData]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
SELECT 
      AVG([SensorMeasure])
  FROM [dbo].[Sensors_electricityData] s
  WHERE 
  (s.[ClientStartTime]> '2015-03-10 00:00:00.0 +01:00') 
  AND (s.[ApartmentID]='CIVIS00000001')

END



GO
/****** Object:  StoredProcedure [dbo].[sp_extractCeisData]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author: P. Dal Zovo, modified: F. Cuscito for F1/F2/F3 durations in the current month>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_extractCeisData]
    -- Add the parameters for the stored procedure here

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	

delete from [dbo].[CEIS_MonthlyElectricStats]
delete from [dbo].[CeisRawDataDiff]

declare @currentMonth tinyint
declare @startDay date
declare @dayOfWeek tinyint
declare @monthLenght tinyint

--ciascun mese è visto come 4 settimane intere più 1-2-3 giorni aggiuntivi (a seconda del mese), che possono cadere di lun-ven. o di sabato o di domenica
declare @a tinyint	--numero di giorni aggiuntivi rispetto alle 4 settimane che cadono di lun-ven
declare @b tinyint  --numero di giorni aggiuntivi che cadono di sabato
declare @c tinyint  --numero di giorni aggiuntivi che cadono di domenica
declare @x1 tinyint  --numero di giorni festivi nel mese corrente che cade tra lun e venerdì
declare @x2 tinyint  --numero di giorni festivi nel mese che cade di sabato
declare @currentYear int
declare @Pasquetta date
declare @durationF1 float
declare @durationF2 float
declare @durationF3 float
	
set @startDay= CONVERT ( date, (SELECT TOP 1 [data lettura] FROM [dbo].[CeisRawData] order by [data lettura] DESC),103) --trasforma la data di lettura in datetime format
set @startDay=DATEADD(MM,-1,@startDay)  -- le letture CEIS sono effettuate il primo giorno del mese successivo, quindi si riferiscono al mese precedente
set @currentMonth= DATEPART (MM, @startday) -- calcola il mese corrente


set @dayOfWeek= DATEPART(dw, @startday) --calcola quale sia il giorno della settimana (lun, mart, mer...) del primo giorno del mese
set @currentYear=DATEPART(yy, @startday)  -- calcola l'anno corrente
set @Pasquetta=dbo.fn_Pasquetta(@currentYear) -- determina la data di Pasquetta nell'anno corrente
set @x1=0  --inizializza le variabili 
set @x2=0


if (dbo.fn_IsLeapYear(@startDay)=0 and @currentMonth=2) set @monthLenght=28  --se è febbraio e l'anno non è bisestile il mese è di 28 giorni
ELSE 
	BEGIN
		if (dbo.fn_IsLeapYear(@startDay)=1 and @currentMonth=2) set @monthLenght=29  -- se è bisestile è di 29
		ELSE
		BEGIN 
			if (@currentMonth=4 or @currentMonth=6 or @currentMonth=9 or @currentMonth=11) set @monthLenght=30  -- Aprile, Giugno, Settembre e Novembre: 30 giorni
			else set @monthLenght=31  --tutti gli altri mesi 31 giorni
		END
	END

IF (@monthLenght=28)  
	BEGIN
		set @a=0  set @b=0  set @c=0  --non ci sono giorni aggiuntivi
	END
ELSE 
	BEGIN
	IF (@monthLenght=29)	--se l'anno è bisestile calcola i parametri a,b,c per da associare al 29imo giorno
		BEGIN
			IF ((@dayOfWeek!=1) and (@dayOfWeek!=7))  --se il mese è cominciato di sabato o domenica
				BEGIN 
					set @a=1  set @b=0  set @c=0	--il giorno aggiuntivo è di lun-ven quindi @a=1
				END
			ELSE 
				BEGIN 
					IF (@dayOfWeek!=7)
					BEGIN 
						set @a=0  set @b=1  set @c=0
					END
					ELSE
					BEGIN 
						set @a=0  set @b=0  set @c=1
					END
				END
		END
	ELSE
		IF (@monthLenght=30)  --calcola i parametri a,b,c nel caso di mese di 30 giorni
			BEGIN
				IF ((@dayOfWeek!=1) and (@dayOfWeek!=7) and (@dayOfWeek!=6))
					BEGIN 
						set @a=2  set @b=0  set @c=0
					END 
				IF (@dayOfWeek=6)
						BEGIN 
							set @a=1  set @b=1  set @c=0
						END
				IF (@dayOfWeek=7)
						BEGIN 
							set @a=0  set @b=1  set @c=1
						END
				IF (@dayOfWeek=1)
						BEGIN 
							set @a=1  set @b=0  set @c=1
						END
			END	
		ELSE   -- --calcola i parametri a,b,c nel caso di mese di 31 giorni
			BEGIN
				IF ((@dayOfWeek=2) or (@dayOfWeek=3) or (@dayOfWeek=4))
					BEGIN 
						set @a=3  set @b=0  set @c=0
					END 
				IF (@dayOfWeek=5)
						BEGIN 
							set @a=2  set @b=1  set @c=0
						END
				IF (@dayOfWeek=6 or @dayOfWeek=7)
						BEGIN 
							set @a=1  set @b=1  set @c=1
						END
				IF (@dayOfWeek=1)
						BEGIN 
							set @a=2  set @b=0  set @c=1
						END
			END	
	END

--calcoliamo ora i giorni festivi di lun-ven (x1) o di sabato (x2) presenti nel mese in corso
IF @currentMonth=1  --se è gennaio si verifica in che giorno cadano il 1° e 6 gennaio
	BEGIN
		if DATEPART(dw, @startDay)=7 set @x2=@x2+1  --1 gennaio
		else if(DATEPART(dw, @startDay)!=1) set @x1=@x1+1
		if DATEPART(dw, DATEADD(dd,5,@startDay))=7 set @x2=@x2+1  --6 gennaio
		else if(DATEPART(dw, DATEADD(dd,5,@startDay))!=1) set @x1=@x1+1
	END
IF (@currentMonth=3 or @currentMonth=4)
	BEGIN	
		if @Pasquetta!=CONVERT(DATE,'2015-04-01',102)
			BEGIN
				if DATEPART(dw, DATEADD(dd,-1,@Pasquetta))=7 set @x2=@x2+1  --Pasqua
				else if(DATEPART(dw, DATEADD(dd,-1,@Pasquetta))!=1) set @x1=@x1+1
				if DATEPART(dw, @Pasquetta)=7 set @x2=@x2+1  --Pasquetta
				else if(DATEPART(dw, @Pasquetta)!=1) set @x1=@x1+1
			END
		ELSE  --nel caso particolare di Pasqua il 30 marzo e Pasquetta 1 Aprile
			IF @currentMonth=3 
				BEGIN
					if DATEPART(dw, DATEADD(dd,-1,@Pasquetta))=7 set @x2=@x2+1  --Pasqua
					else if(DATEPART(dw, DATEADD(dd,-1,@Pasquetta))!=1) set @x1=@x1+1
				END
			ELSE  --mese in considerazione: aprile
				BEGIN
					if DATEPART(dw, @Pasquetta)=7 set @x2=@x2+1  --Pasquetta
					else if(DATEPART(dw, @Pasquetta)!=1) set @x1=@x1+1
				END
		IF @currentMonth=4
			BEGIN
				if DATEPART(dw, DATEADD(dd,24,@startDay))=7 set @x2=@x2+1  --25 Aprile
				else if(DATEPART(dw, DATEADD(dd,24,@startDay))!=1) set @x1=@x1+1
			END
	END
IF @currentMonth=6 
	BEGIN
		if DATEPART(dw, DATEADD(dd,1,@startDay))=7 set @x2=@x2+1  --2 giugno
		else if(DATEPART(dw, DATEADD(dd,1,@startDay))!=1) set @x1=@x1+1
	END
IF @currentMonth=8 
	BEGIN
		if DATEPART(dw, DATEADD(dd,14,@startDay))=7 set @x2=@x2+1  --15 Agosto
		else if(DATEPART(dw, DATEADD(dd,14,@startDay))!=1) set @x1=@x1+1
	END
IF @currentMonth=11
	BEGIN
		if DATEPART(dw, @startDay)=7 set @x2=@x2+1  --1 Novembre
		else if(DATEPART(dw, @startDay)!=1) set @x1=@x1+1
	END
IF @currentMonth=12
	BEGIN
		if DATEPART(dw, DATEADD(dd,7,@startDay))=7 set @x2=@x2+1  --8 Dicembre
		else if(DATEPART(dw, DATEADD(dd,7,@startDay))!=1) set @x1=@x1+1
		if DATEPART(dw, DATEADD(dd,24,@startDay))=7 set @x2=@x2+1  --25 Dicembre
		else if(DATEPART(dw, DATEADD(dd,24,@startDay))!=1) set @x1=@x1+1
		if DATEPART(dw, DATEADD(dd,25,@startDay))=7 set @x2=@x2+1  --26 Dicembre
		else if(DATEPART(dw, DATEADD(dd,25,@startDay))!=1) set @x1=@x1+1
	END

--vengono calcolate ora le duration di ciscuna fascia oraria, considerando 4 settimane intere per ciascun mese e @a+@b+@c
--giorni in più, a seconda dei mesi (Feb-> @a+@b+@c=0 o @a+@b+@c=1 se bisestile), Gen-> @a+@b+@c=3 ,etc considerando
--se ci sono x1 giorni festivi che cadono tra lunedì e venerdì e x2 giorni festivi che cadono di sabato.

set @durationF1=(20+@a-@x1)*39600.0
set @durationF2=(20+@a-@x1)*18000 +(4+@b-@x2)*57600.0
set @durationF3=(20+@a-@x1)*28800 +(4+@b-@x2)*28800+(4+@c+@x1+@x2)*86400.0


--Compute differences from the previous month
insert into [dbo].[CeisRawDataDiff]
	select
	a.[ApartmentID],
	r.[POD]  ,
	r.[contratto] ,
	r.[tariffa] ,
	r.[matricola]  ,
	r.[scambio/produzione],
	r.[data lettura] ,
	r.[unita misura] ,
	r.[Attiva F1] - prev.[Attiva F1] ,
	r.[Attiva F2] - prev.[Attiva F2],
	r.[Attiva F3] - prev.[Attiva F3],
	r.[Attiva totale] - prev.[Attiva totale] ,
	r.[unita di misura] ,
	(r.[Attiva F1] - prev.[Attiva F1])/@durationF1*3600.0,
	(r.[Attiva F2] - prev.[Attiva F2])/@durationF2*3600.0,
	(r.[Attiva F3] - prev.[Attiva F3])/@durationF3*3600.0,
	r.[Immissione F1] - prev.[Immissione F1] ,
	r.[Immissione F2] - prev.[Immissione F2] ,
	r.[Immissione F3] - prev.[Immissione F3] ,
	r.[Immissione totale]  - r.[Immissione totale]  

 FROM [Civis_Energy].[dbo].[CeisRawData] r,
	  [Civis_Energy].[dbo].[CeisRawDataPreviousMonth] prev,
      [dbo].[Apartment] a
  where   
  a.[ContractID] = r.[contratto] and
  a.[DSO] = 'CEIS' and 
  r.[contratto] = prev.[contratto] 
  and r.[matricola] = prev.[matricola]
  and r.[scambio/produzione] = prev.[scambio/produzione]





--PRODUZIONE
-- si effettua SUM poiché sono possibili molteplici contatori di produzione (e.g. IT140E00005036) per stesso POD / contratto 
insert into [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
       a.apartmentID AS [ApartmentID]
      ,DATEADD(mm,-1, convert(date, s.[data lettura], 103)) AS [Month]
      ,CAST(sum(s.[Immissione totale]) as float) AS [OverallEnergy]
      ,CAST(sum (s.[Immissione F1]) as float) as [F1Energy]
      ,CAST(sum (s.[Immissione F2]) as float) as [F2Energy]
      ,CAST(sum (s.[Immissione F3]) as float) as [F3Energy] 
      ,CAST(sum(s.[Immissione totale]) as float)/(@durationF1+@durationF2+@durationF3)*3600.0 AS [Power]
      ,'P' AS [Cons_Prod_Feedin] 

  FROM [Civis_Energy].[dbo].[CeisRawDataDiff] s,
        [dbo].[Apartment] a
  where   
  a.[ContractID] = s.[contratto]
  AND ( s.[scambio/produzione] ='P')
  group by a.[ApartmentID],  s.[data lettura]

--FEEDIN
   insert into [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
        a.apartmentID AS [ApartmentID]
      ,DATEADD(mm,-1, convert(date, s.[data lettura], 103)) AS [Month]
      ,CAST(sum(s.[Immissione totale]) as float) AS [OverallEnergy]
      ,CAST(sum (s.[Immissione F1]) as float) as [F1Energy]
      ,CAST(sum (s.[Immissione F2]) as float) as [F2Energy]
      ,CAST(sum (s.[Immissione F3]) as float) as [F3Energy] 
      ,CAST(sum(s.[Immissione totale]) as float)/(@durationF1+@durationF2+@durationF3)*3600.0 AS [Power]
      ,'F'	as [Cons_Prod_Feedin] 

  FROM [Civis_Energy].[dbo].[CeisRawDataDiff] s,
        [dbo].[Apartment] a
  where   
  a.[ContractID] = s.[contratto]
  AND (s.[scambio/produzione] ='S') 
  group by a.[ApartmentID],  s.[data lettura]

--CONSUMO
insert into [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
        a.apartmentID AS [ApartmentID]
      ,DATEADD(mm,-1, convert(date, s.[data lettura], 103)) AS [Month] 
      ,CAST(s.[Attiva totale] + sum (p.[Immissione totale]) - s.[Immissione totale] as float) AS [OverallEnergy]
      ,CAST(s.[Attiva F1] + sum (p.[Immissione F1]) - s.[Immissione F1] as float) AS [F1Energy]
      ,CAST(s.[Attiva F2] + sum (p.[Immissione F2]) - s.[Immissione F2] as float) AS [F2Energy]
      ,CAST(s.[Attiva F3] + sum (p.[Immissione F3]) - s.[Immissione F3] as float) AS [F3Energy]
      ,CAST(sum(s.[Attiva totale]) as float)/(@durationF1+@durationF2+@durationF3)*3600.0 as [Power]
      ,'C'	AS [Cons_Prod_Feedin] 

  FROM [Civis_Energy].[dbo].[CeisRawDataDiff] s,
        [dbo].[Apartment] a,
       [Civis_Energy].[dbo].[CeisRawDataDiff] p
  where 
     a.[ContractID] = s.[contratto]
  AND 
  (s.[contratto] = p.[contratto]) 
  AND ( s.[data lettura] = p.[data lettura] ) 
  AND( p.[scambio/produzione] ='P')
  AND ( s.[scambio/produzione] ='S')
  group by a.[ApartmentID],  s.[data lettura], s.[Attiva totale], s.[Immissione totale],
  s.[Attiva F1],  s.[Immissione F1],
  s.[Attiva F2],  s.[Immissione F2],
  s.[Attiva F3],  s.[Immissione F3]


  insert into [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
       a.ApartmentID as [ApartmentID]
      ,DATEADD(mm,-1, convert(date, s.[data lettura], 103)) AS [Month] 
      ,CAST(s.[Attiva totale] as float) AS [OverallEnergy]
      ,CAST(s.[Attiva F1] as float) as [F1Energy]
      ,CAST(s.[Attiva F2] as float) as [F2Energy]
      ,CAST(s.[Attiva F3] as float) as [F3Energy]
      ,CAST(sum(s.[Attiva totale]) as float)/(@durationF1+@durationF2+@durationF3)*3600.0 AS [Power]
      ,'C' AS [Cons_Prod_Feedin] 

  FROM [Civis_Energy].[dbo].[CeisRawDataDiff] s,
        [dbo].[Apartment] a,
       [Civis_Energy].[dbo].[CeisRawDataDiff] p
  where 
     a.[ContractID] = s.[contratto]
  AND ( s.[scambio/produzione] ='')
  group by a.[ApartmentID],  s.[data lettura], s.[Attiva totale], s.[Immissione totale],
  s.[Attiva F1],  s.[Immissione F1],
  s.[Attiva F2],  s.[Immissione F2],
  s.[Attiva F3],  s.[Immissione F3]
  
  --Self production AUTOCONSUMO
--insert into [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats] 
--    SELECT distinct 
--        a.apartmentID AS [ApartmentID]
--      , convert(datetime,  s.[data lettura], 103) AS [Month] 
--      ,p.[Immissione totale] - s.[Immissione totale] AS [OverallEnergy]
--      ,p.[Immissione F1] - s.[Immissione F1] as [F1Energy]
--      ,p.[Immissione F2] - s.[Immissione F2] as [F2Energy]
--      , p.[Immissione F3] - s.[Immissione F3] as [F3Energy]
--        ,p.[Potenza F1] -   s.[Potenza F1] as [Power]  -- forse non ha senso
--      ,'S'		--[Cons_Prod_Feedin] 

--  FROM [Civis_Energy].[dbo].[CeisRawData] s,
--        [dbo].[Apartment] a,
--       [Civis_Energy].[dbo].[CeisRawData] p
--  where 
--     a.[ContractID] = s.[contratto]
--    AND (s.[contratto] = p.[contratto]) 
--  AND ( s.[data lettura] = p.[data lettura] ) 
--  AND( p.[scambio/produzione] ='P')
--  AND ( s.[scambio/produzione] ='S')



    -- filling [dbo].[DSO_MonthlyElectricStats] from intermediate table

    insert into  [dbo].[DSO_MonthlyElectricStats]
    SELECT distinct 
        apartmentID AS [ApartmentID]
       ,'CEIS' as [DSO]
       ,[Month]
       ,[F1Energy]/@durationF1*3600.0 as [AveragePowerMeasure]
       ,[F1Energy] as [EnergyMeasure]
       ,'F1' as [TimeSlot]
       ,[Cons_Prod_Feedin]
	   ,NULL
	   ,0
   FROM [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats]
   where [Cons_Prod_Feedin] = 'C' or [Cons_Prod_Feedin] = 'P' or [Cons_Prod_Feedin] = 'F'


    insert into  [dbo].[DSO_MonthlyElectricStats]
    SELECT distinct 
        apartmentID AS [ApartmentID]
       ,'CEIS' as [DSO]
       ,[Month]
       ,[F2Energy]/@durationF2*3600.0 as [AveragePowerMeasure]
       ,[F2Energy] as [EnergyMeasure]
       ,'F2' as [TimeSlot]
       ,[Cons_Prod_Feedin]
	   ,NULL
	   ,0
   FROM [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats]
   where [Cons_Prod_Feedin] = 'C' or [Cons_Prod_Feedin] = 'P' or [Cons_Prod_Feedin] = 'F'

    insert into  [dbo].[DSO_MonthlyElectricStats]
    SELECT distinct 
        apartmentID AS [ApartmentID]
       ,'CEIS' as [DSO]
       ,[Month]
       ,[F3Energy]/@durationF3*3600.0 as [AveragePowerMeasure]
       ,[F3Energy] as [EnergyMeasure]
       ,'F3' as [TimeSlot]
       ,[Cons_Prod_Feedin]
	   ,NULL
	   ,0
   FROM [Civis_Energy].[dbo].[CEIS_MonthlyElectricStats]
   where [Cons_Prod_Feedin] = 'C' or [Cons_Prod_Feedin] = 'P' or [Cons_Prod_Feedin] = 'F'




 DELETE  FROM [Civis_Energy].[dbo].[CeisRawDataPreviousMonth]

 insert into  [dbo].[CeisRawDataPreviousMonth]
    SELECT * from  [Civis_Energy].[dbo].[CeisRawData]


 DELETE  FROM [Civis_Energy].[dbo].[CeisRawData]  
 
END

/*
Il contatore di scambio misura l’energia scambiata nel punto di connessione tra la rete CEIS e l’utenza elettrica del cliente finale.
Il contatore di produzione misura l’energia scambiata tra l’utenza elettrica del cliente finale e l’impianto di produzione ad essa collegato.

Per il contatore di scambio:
- l’energia attiva F1, F2, F3 è l’energia prelevata dalla rete CEIS quando il consumo dell’impianto elettrico interno all’utenza non è interamente coperto dall’autoproduzione;
- l’energia immessa F1, F2, F3 è l’energia che l’impianto elettrico interno all’utenza cede alla rete CEIS quando l’autoproduzione eccede il fabbisogno.

Per il contatore di produzione;
- l’energia attiva F1, F2, F3 è l’energia utilizzata dall’inverter (ed eventuali altre apparecchiature) per far funzionare l’impianto di produzione; tale energia è già transitata dal contatore di scambio e misurata come energia prelevata dalla rete CEIS;
- l’energia immessa F1, F2, F3 è l’energia generata dall’impianto di produzione e trasferita all’impianto elettrico interno all’utenza per l’autoconsumo e/o l’immissione nella rete CEIS, che sarà misurata dal contatore di scambio.
*/

GO
/****** Object:  StoredProcedure [dbo].[sp_extractCeisData_old]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_extractCeisData_old]
    -- Add the parameters for the stored procedure here

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	

delete from [dbo].[CEIS_MonthlyElectricStats]

--PRODUZIONE
-- si effettua SUM poiché sono possibili molteplici contatori di produzione (e.g. IT140E00005036) per stesso POD / contratto 
insert into [dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
        a.apartmentID AS [ApartmentID]
                --wrong	datename(mm,s.[data lettura])
      , convert(datetime,  s.[data lettura], 103) AS [Month] 
      ,sum(s.[Immissione totale]) AS [OverallEnergy]
      ,sum (s.[Immissione F1]) as [F1Energy]
      ,sum (s.[Immissione F2]) as [F2Energy]
      ,sum (s.[Immissione F3]) as [F3Energy] 
        ,sum (s.[Potenza F1]) as [Power] 
      ,'P' AS [Cons_Prod_Feedin] 

  FROM [dbo].[CeisRawData] s,
        [dbo].[Apartment] a
  where   
  a.[ContractID] = s.[contratto]
  AND ( s.[scambio/produzione] ='P')
  group by [ApartmentID],  s.[data lettura]

--FEEDIN
   insert into [dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
        a.apartmentID AS [ApartmentID]
      , convert(datetime,  s.[data lettura], 103) AS [Month] 
      ,s.[Immissione totale] AS [OverallEnergy]
      ,s.[Immissione F1] as [F1Energy]
      ,s.[Immissione F2] as [F2Energy]
      ,s.[Immissione F3] as [F3Energy]
         ,s.[Potenza F1] as [Power] 
      ,'F'	as [Cons_Prod_Feedin] 

  FROM [dbo].[CeisRawData] s,
        [dbo].[Apartment] a
  where   
  a.[ContractID] = s.[contratto]
  AND (s.[scambio/produzione] ='S') 

--CONSUMO
insert into [dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
        a.apartmentID AS [ApartmentID]
      , convert(datetime,  s.[data lettura], 103) AS [Month] 
      ,s.[Attiva totale] + sum (p.[Immissione totale]) - s.[Immissione totale] AS [OverallEnergy]
      ,s.[Attiva F1] + sum (p.[Immissione F1]) - s.[Immissione F1] as [F1Energy]
      ,s.[Attiva F2] + sum (p.[Immissione F2]) - s.[Immissione F2] as [F2Energy]
      ,s.[Attiva F3] + sum (p.[Immissione F3]) - s.[Immissione F3] as [F3Energy]
         ,sum(s.[Potenza F1]) as [Power] 
      ,'C'	AS [Cons_Prod_Feedin] 

  FROM [dbo].[CeisRawData] s,
        [dbo].[Apartment] a,
       [dbo].[CeisRawData] p
  where 
     a.[ContractID] = s.[contratto]
  AND 
  (s.[contratto] = p.[contratto]) 
  AND ( s.[data lettura] = p.[data lettura] ) 
  AND( p.[scambio/produzione] ='P')
  AND ( s.[scambio/produzione] ='S')
  group by [ApartmentID],  s.[data lettura], s.[Attiva totale], s.[Immissione totale],
  s.[Attiva F1],  s.[Immissione F1],
  s.[Attiva F2],  s.[Immissione F2],
  s.[Attiva F3],  s.[Immissione F3]

  insert into [dbo].[CEIS_MonthlyElectricStats] 
    SELECT distinct 
        a.apartmentID AS [ApartmentID]
      , convert(datetime,  s.[data lettura], 103) AS [Month] 
      ,s.[Attiva totale] AS [OverallEnergy]
      ,s.[Attiva F1] as [F1Energy]
      ,s.[Attiva F2] as [F2Energy]
      ,s.[Attiva F3] as [F3Energy]
         ,s.[Potenza F1] as [Power] 
      ,'C' AS [Cons_Prod_Feedin] 

  FROM [dbo].[CeisRawData] s,
        [dbo].[Apartment] a,
       [dbo].[CeisRawData] p
  where 
     a.[ContractID] = s.[contratto]
  AND ( s.[scambio/produzione] ='')

  --Self production AUTOCONSUMO
--insert into [dbo].[CEIS_MonthlyElectricStats] 
--    SELECT distinct 
--        a.apartmentID AS [ApartmentID]
--      , convert(datetime,  s.[data lettura], 103) AS [Month] 
--      ,p.[Immissione totale] - s.[Immissione totale] AS [OverallEnergy]
--      ,p.[Immissione F1] - s.[Immissione F1] as [F1Energy]
--      ,p.[Immissione F2] - s.[Immissione F2] as [F2Energy]
--      , p.[Immissione F3] - s.[Immissione F3] as [F3Energy]
--        ,p.[Potenza F1] -   s.[Potenza F1] as [Power]  -- forse non ha senso
--      ,'S'		--[Cons_Prod_Feedin] 

--  FROM [dbo].[CeisRawData] s,
--        [dbo].[Apartment] a,
--       [dbo].[CeisRawData] p
--  where 
--     a.[ContractID] = s.[contratto]
--    AND (s.[contratto] = p.[contratto]) 
--  AND ( s.[data lettura] = p.[data lettura] ) 
--  AND( p.[scambio/produzione] ='P')
--  AND ( s.[scambio/produzione] ='S')



    -- filling [dbo].[DSO_MonthlyElectricStats] from intermediate table

    insert into  [dbo].[DSO_MonthlyElectricStats]
    SELECT distinct 
        apartmentID AS [ApartmentID]
       ,'CEIS' as [DSO]
       ,[Month]
       ,[Power] as [AveragePowerMeasure]
       ,[F1Energy] as [EnergyMeasure]
       , 'F1' as [TimeSlot]
       , [Cons_Prod_Feedin]
   FROM [dbo].[CEIS_MonthlyElectricStats]
   where [Cons_Prod_Feedin] = 'C' or [Cons_Prod_Feedin] = 'P' or [Cons_Prod_Feedin] = 'F'


    insert into  [dbo].[DSO_MonthlyElectricStats]
    SELECT distinct 
        apartmentID AS [ApartmentID]
       ,'CEIS' as [DSO]
       ,[Month]
       ,[Power] as [AveragePowerMeasure]
       ,[F2Energy] as [EnergyMeasure]
       , 'F2' as [TimeSlot]
       , [Cons_Prod_Feedin]
   FROM [dbo].[CEIS_MonthlyElectricStats]
   where [Cons_Prod_Feedin] = 'C' or [Cons_Prod_Feedin] = 'P' or [Cons_Prod_Feedin] = 'F'

    insert into  [dbo].[DSO_MonthlyElectricStats]
    SELECT distinct 
        apartmentID AS [ApartmentID]
       ,'CEIS' as [DSO]
       ,[Month]
       ,[Power] as [AveragePowerMeasure]
       ,[F3Energy] as [EnergyMeasure]
       , 'F3' as [TimeSlot]
       , [Cons_Prod_Feedin]
   FROM [dbo].[CEIS_MonthlyElectricStats]
   where [Cons_Prod_Feedin] = 'C' or [Cons_Prod_Feedin] = 'P' or [Cons_Prod_Feedin] = 'F'
    
    /*
Il contatore di scambio misura l’energia scambiata nel punto di connessione tra la rete CEIS e l’utenza elettrica del cliente finale.
Il contatore di produzione misura l’energia scambiata tra l’utenza elettrica del cliente finale e l’impianto di produzione ad essa collegato.

Per il contatore di scambio:
- l’energia attiva F1, F2, F3 è l’energia prelevata dalla rete CEIS quando il consumo dell’impianto elettrico interno all’utenza non è interamente coperto dall’autoproduzione;
- l’energia immessa F1, F2, F3 è l’energia che l’impianto elettrico interno all’utenza cede alla rete CEIS quando l’autoproduzione eccede il fabbisogno.

Per il contatore di produzione;
- l’energia attiva F1, F2, F3 è l’energia utilizzata dall’inverter (ed eventuali altre apparecchiature) per far funzionare l’impianto di produzione; tale energia è già transitata dal contatore di scambio e misurata come energia prelevata dalla rete CEIS;
- l’energia immessa F1, F2, F3 è l’energia generata dall’impianto di produzione e trasferita all’impianto elettrico interno all’utenza per l’autoconsumo e/o l’immissione nella rete CEIS, che sarà misurata dal contatore di scambio.
*/
END






GO
/****** Object:  StoredProcedure [dbo].[sp_GET_ContractID]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Francesco Cuscito>
-- Create date: <2015-06-26>
-- Description:	<selects the DSO value associated to a certain ApartmentID>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GET_ContractID]
	-- Add the parameters for the stored procedure here
		@ApartmentID int,
		@ContractID varchar(15)='NULL'  OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SET @ContractID = '';

SELECT [ContractID]    
FROM [Civis_Energy].[dbo].[Apartment]  
WHERE ApartmentID=@ApartmentID


IF @@ROWCOUNT > 0  /*se l'ApartmentID è presente nel DB*/
	BEGIN 
		SET @ContractID=(SELECT [ContractID]    
		FROM [Civis_Energy].[dbo].[Apartment]  
		WHERE ApartmentID=@ApartmentID)	
	END
ELSE	
		SET @ContractID='NULL'			/*l'ApartmentID specificato non esiste nel DB*/	

RETURN

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GET_DSO]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Francesco Cuscito>
-- Create date: <2015-06-26>
-- Description:	<selects the DSO value associated to a certain ApartmentID>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GET_DSO]
	-- Add the parameters for the stored procedure here
		@ApartmentID int,
		@DSO varchar(10)='NULL'  OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SET @DSO = '';

SELECT [DSO]    
FROM [Civis_Energy].[dbo].[Apartment]  
WHERE ApartmentID=@ApartmentID


IF @@ROWCOUNT > 0  /*se l'ApartmentID è presente nel DB*/
	BEGIN 
		SET @DSO=(SELECT [DSO]    
		FROM [Civis_Energy].[dbo].[Apartment]  
		WHERE ApartmentID=@ApartmentID)	
	END
ELSE	
		SET @DSO='NULL'			/*l'ApartmentID specificato non esiste nel DB*/	

RETURN

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GET_Historical_Weather]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GET_Historical_Weather]
	@City varchar(50),
	@Start datetimeoffset,
	@End datetimeoffset
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT
      [PubDate]
      ,[ForecastRefTime01]
      , cast ([Clouds01]	      as varchar(8)) as [Clouds01]
      , cast ([Temperature01]	      as varchar(8)) as [Temperature01]
      , cast ([Precipitation01]	      as varchar(8)) as [Precipitation01]
      , cast ([Humidity01]	      as varchar(8)) as [Humidity01]
 /*     , cast ([ForecastRefTime02]	      as varchar(8)) as [ForecastRefTime02]
      , cast ([Clouds02]	      as varchar(8)) as [Clouds02]
      , cast ([Temperature02]	      as varchar(8)) as [Temperature02]
      , cast ([Precipitation02]	      as varchar(8)) as [Precipitation02]
      , cast ([Humidity02]	      as varchar(8)) as [Humidity02]
      , cast ([ForecastRefTime03]	      as varchar(8)) as [ForecastRefTime03]
      , cast ([Clouds03]	      as varchar(8)) as [Clouds03]
      , cast ([Temperature03]	      as varchar(8)) as [Temperature03]
      , cast ([Precipitation03]	      as varchar(8)) as [Precipitation03]
      , cast ([Humidity03]	      as varchar(8)) as [Humidity03]
      , cast ([ForecastRefTime04]	      as varchar(8)) as [ForecastRefTime04]
      , cast ([Clouds04]	      as varchar(8)) as [Clouds04]
      , cast ([Temperature04]	      as varchar(8)) as [Temperature04]
      , cast ([Precipitation04]	      as varchar(8)) as [Precipitation04]
      , cast ([Humidity04]	      as varchar(8)) as [Humidity04]
      , cast ([ForecastRefTime05]	      as varchar(8)) as [ForecastRefTime05]
      , cast ([Clouds05]	      as varchar(8)) as [Clouds05]
      , cast ([Temperature05]	      as varchar(8)) as [Temperature05]
      , cast ([Precipitation05]	      as varchar(8)) as [Precipitation05]
      , cast ([Humidity05]	      as varchar(8)) as [Humidity05]
      , cast ([ForecastRefTime06]	      as varchar(8)) as [ForecastRefTime06]
      , cast ([Clouds06]	      as varchar(8)) as [Clouds06]
      , cast ([Temperature06]	      as varchar(8)) as [Temperature06]
      , cast ([Precipitation06]	      as varchar(8)) as [Precipitation06]
      , cast ([Humidity06]	      as varchar(8)) as [Humidity06]
      , cast ([ForecastRefTime07]	      as varchar(8)) as [ForecastRefTime07]
      , cast ([Clouds07]	      as varchar(8)) as [Clouds07]
      , cast ([Temperature07]	      as varchar(8)) as [Temperature07]
      , cast ([Precipitation07]	      as varchar(8)) as [Precipitation07]
      , cast ([Humidity07]	      as varchar(8)) as [Humidity07]
      , cast ([ForecastRefTime08]	      as varchar(8)) as [ForecastRefTime08]
      , cast ([Clouds08]	      as varchar(8)) as [Clouds08]
      , cast ([Temperature08]	      as varchar(8)) as [Temperature08]
      , cast ([Precipitation08]	      as varchar(8)) as [Precipitation08]
      , cast ([Humidity08]	      as varchar(8)) as [Humidity08]*/
      , [ForecastRefTime09]	 as [ForecastRefTime09]
      , cast ([Clouds09]	      as varchar(8)) as [Clouds09]
      , cast ([Temperature09]	      as varchar(8)) as [Temperature09]
      , cast ([Precipitation09]	      as varchar(8)) as [Precipitation09]
      , cast ([Humidity09]	      as varchar(8)) as [Humidity09]
/*      , cast ([ForecastRefTime10]	      as varchar(8)) as [ForecastRefTime10]
      , cast ([Clouds10]	      as varchar(8)) as [Clouds10]
      , cast ([Temperature10]	      as varchar(8)) as [Temperature10]
      , cast ([Precipitation10]	      as varchar(8)) as [Precipitation10]
      , cast ([Humidity10]	      as varchar(8)) as [Humidity10]
      , cast ([ForecastRefTime11]	      as varchar(8)) as [ForecastRefTime11]
      , cast ([Clouds11]	      as varchar(8)) as [Clouds11]
      , cast ([Temperature11]	      as varchar(8)) as [Temperature11]
      , cast ([Precipitation11]	      as varchar(8)) as [Precipitation11]
      , cast ([Humidity11]	      as varchar(8)) as [Humidity11]
      , cast ([ForecastRefTime12]	      as varchar(8)) as [ForecastRefTime12]
      , cast ([Clouds12]	      as varchar(8)) as [Clouds12]
      , cast ([Temperature12]	      as varchar(8)) as [Temperature12]
      , cast ([Precipitation12]	      as varchar(8)) as [Precipitation12]
      , cast ([Humidity12]	      as varchar(8)) as [Humidity12] */
      , [Sunrise]
      , [Sunset]

  FROM [Civis_Energy].[dbo].[WeatherForecast] w
	 WHERE  w.City = @City and w.PubDate between @Start and @End
	 ORDER BY w.PubDate desc
	 FOR XML PATH('Forecast'),root('Weather');
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GET_MetersByApartment]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GET_MetersByApartment]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select 
(SELECT a.ApartmentID as "ApartmentID",
 (SELECT c.SensorNumber as sensorNumber,
  [SensorType] as [sensorType],
  [MeasureUnit] as [measureUnit],
  [SensorLabel] as label,
        [LastSampleTimestamp] as [lastSampleTimestamp]
  FROM [Civis_Energy].[dbo].[ApartmentMeters] c
  WHERE a.ApartmentID =  c.ApartmentID 
  ORDER BY ApartmentID
  FOR XML PATH('sensor'), type
 ) as 'sensors'

from [Civis_Energy].[dbo].[ApartmentMeters] a
group by a.apartmentID

for xml path('UsagePoint'), type
)
for xml path('content'),  root('entry');

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GET_Weather]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Paola Dal Zovo, Reply>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GET_Weather]
	@City varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT top 1 [PubDate]
      ,[ForecastRefTime01] as RefTime
      ,cast([Clouds01] as varchar(8)) as Clouds
	  ,cast([Temperature01] as varchar(8)) as Temperature
      ,cast ([Precipitation01] as  varchar(8)) as [Precipitation]
      ,cast([Humidity01] as  varchar(8)) as [Humidity]
	   ,[Sunrise]
      ,[Sunset]
	--   ,cast([Sunset] as  datetimeoffset) as [sunsetwithtimezone]
  FROM [Civis_Energy].[dbo].[WeatherForecast] w
	 WHERE  w.City = @City
	 ORDER BY w.PubDate desc
	 FOR XML PATH('content'),root('entry');
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GET_Weather_old]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Paola Dal Zovo, Reply>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GET_Weather_old]
	@City varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT top 1 [PubDate]
      ,[ForecastRefTime01]
      ,cast([Clouds01] as varchar(8)) as Clouds
	  ,cast([Temperature01] as varchar(8)) as Temperature01
      ,cast ([Precipitation01] as  varchar(8)) as [Precipitation01]
      ,cast([Humidity01] as  varchar(8)) as [Humidity01]
	   ,[Sunrise]
      ,[Sunset]
	   ,cast([Sunset] as  datetimeoffset) as [sunsetwithtimezone]
  FROM [Civis_Energy].[dbo].[WeatherForecast] w
	 WHERE  w.City = @City
	 ORDER BY w.PubDate desc
	 FOR XML PATH('content'),root('entry');
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GETApartmentId]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Francesco Cuscito>
-- Create date: <2015-04-02>
-- Description:	<selects or creates an apartmentID into dbo.apartment table given a ContractID - POD data combination>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GETApartmentId]
	-- Add the parameters for the stored procedure here
		@POD varchar(30),
		@ContractID varchar(30),
		@id int =-1 OUTPUT,
		@FamilyID int = -1 OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

set @id = -1
set @FamilyID = -1

select apartmentID from [dbo].[Apartment]

where POD=@POD and contractID=@ContractID


IF @@ROWCOUNT > 0  /*se la coppia POD/ContractID è già registrata*/
	BEGIN 
		set @FamilyID=(SELECT FLOOR (2147483600)*RAND()) 
		set @id=(select apartmentID from [dbo].[Apartment]
		where POD=@POD and contractID=@ContractID)
		
		select apartmentID from [dbo].[Apartment]
		where contractID=@ContractID
		IF @@ROWCOUNT > 0
		    UPDATE [dbo].[Apartment]
			SET FamilyID= @FamilyID
			WHERE ApartmentID=@id
	END
ELSE
		
		BEGIN
			select apartmentID from [dbo].[Apartment]
			where contractID=@ContractID
			IF @@ROWCOUNT = 0  /*Se non esiste alcun utente con stesso ContractID già in tabella*/

			BEGIN

				select apartmentID from [dbo].[Apartment]
				where POD=@POD
				IF @@ROWCOUNT = 0 /*Se non esiste alcun utente con stesso POD già in tabella*/

					BEGIN

						INSERT INTO [dbo].[Apartment]   /*Crea una nuova riga nella tabella*/
							([DSO])
						VALUES
							('unknown')

						set @id=-1						/*a cui sarà assegnato un nuovo ApartmentID*/
						select @id = ( select top 1 [ApartmentID] from [dbo].[Apartment]  order by apartmentId DESC)
						UPDATE [dbo].[Apartment]
						SET FamilyID= @FamilyID
						WHERE ApartmentID=@id
					END
				ELSE
					set @id=-1						/*Se invece il ContractID o il POD è già presente, vuol dire che*/
			END
			ELSE										
				set @id=-1							/*la combinazione POD/ContractID specificata è errata*/	
		END

RETURN

END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetConsumptionByDayOffsets]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author: Francesco Cuscito>
-- Create date: <Create Date: 2015-03-13>
-- Description:	<Description: This SP calculates energy sums and averages for a selected sensor (channel) during a 
--				period of days going from "@StartDayOffset" days ago, to "EndDayOffset" days ago. >
--				Offsets from today: 0=today; 1=yesterday; 2=daybefore yesterday, etc
-- Example: EXEC [Civis_Energy].dbo.dev_sp_GetConsumptionByDayOffsets 2, 4, 1 calculates the sum and the average of energy
-- values associated to sensor #2 from 4 days ago to 1 days ago.
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetConsumptionByDayOffsets]
	-- Add the parameters for the stored procedure here 
	@sensorNumber tinyint,
	@StartDateOffset tinyint, 
	@EndDateOffset tinyint

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
	SELECT  [ApartmentID], 
		sum(SensorMeasure)/((@StartDateOffset-@EndDateOffset)*24.0) as avg,
		sum(SensorMeasure) as sum

	FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
	WHERE ([SensorNumber]=@sensorNumber) AND
		([ServerArrivalTime]>=CAST(DATEADD(day, DATEDIFF(day, @StartDateOffset, GETDATE()), 1) AS DATE)) AND
		([ServerArrivalTime]<CAST(DATEADD(day, DATEDIFF(day, @EndDateOffset, GETDATE()), 1) AS DATE))
	group by  [ApartmentID]

END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetCurrentElectricityConsProd]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author: Paola Dal Zovo>
-- Create date: <Create Date: 2015-12-30>
-- Description:	<Description: This SP return the electricity consumption and production in the last half hour ( @timespan = 30 ), normalized over 30 minutes. >
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetCurrentElectricityConsProd]


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
DECLARE  @consumptionTable TABLE (apartmentID INT, consumption REAL,  consumptionTimeSpan INT, production REAL, productionTimeSpan INT)
DECLARE @timespan  int = 30  

insert into  @consumptionTable 
SELECT [ApartmentID]
      ,sum([SensorMeasure])
	  ,datediff(SECOND, min([ClientStartTime]),max([ClientStopTime])) as consumptionTimeSpan,
	  0,0
  FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
  where SensorNumber = 0
	and datediff(minute,ClientStartTime, SYSUTCDATETIME() ) <  @timespan
  group by ApartmentID, SensorNumber

  union 

  SELECT [ApartmentID]
      ,0
	  ,-1,
	  0,0
  FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
  where SensorNumber = 0  group by ApartmentID, SensorNumber
	having datediff(minute,max(ClientStartTime), SYSUTCDATETIME() ) >  @timespan




  insert into  @consumptionTable 
SELECT [ApartmentID]
      ,0,0
	  ,sum([SensorMeasure]) as production
	  ,datediff(SECOND, min([ClientStartTime]),max([ClientStopTime])) as productionTimeSpan
  FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
  where SensorNumber = 8
	and datediff(minute,ClientStartTime, SYSUTCDATETIME() ) <  @timespan
  group by ApartmentID, SensorNumber

  select apartmentID, 
  sum(consumption) as consumptionT,  
  sum(consumptionTimeSpan) as consTimeSpan, 
	CASE 
            WHEN (sum(consumptionTimeSpan) > 0 )
               THEN  sum(consumption) * ( @timespan *60) / sum(consumptionTimeSpan) 
               ELSE 0 
       END as Consumption,
  sum(production) as productionT, 
  sum(productionTimeSpan) as prodTimeSpan, 
  	CASE 
            WHEN (sum(ProductionTimeSpan) > 0 )
               THEN   sum(Production) * ( @timespan *60) / sum(ProductionTimeSpan) 
			  ELSE 0
       END as Production
--  ,sum(production) *  sum(productionTimeSpan) /   sum( consumptionTimeSpan) as normalizedCons
  from  @consumptionTable
   where apartmentID in ( SELECT [ApartmentID]   FROM [Civis_Energy].[dbo].[ApartmentMeters] where SensorNumber = 8)
  group by apartmentID

END






GO
/****** Object:  StoredProcedure [dbo].[sp_GetCurrentElectricityConsProd_old]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author: Paola Dal Zovo>
-- Create date: <Create Date: 2015-12-30>
-- Description:	<Description: This SP return the electricity consumption and production in the last half hour ( @timespan = 30 ), normalized over 30 minutes. >
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetCurrentElectricityConsProd_old]


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
DECLARE  @consumptionTable TABLE (apartmentID INT, consumption REAL,  consumptionTimeSpan INT, production REAL, productionTimeSpan INT)
DECLARE @timespan  int = 30  

insert into  @consumptionTable 
SELECT [ApartmentID]
      ,sum([SensorMeasure])
	  ,datediff(SECOND, min([ClientStartTime]),max([ClientStopTime])) as consumptionTimeSpan,
	  0,0
  FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
  where SensorNumber = 0
	and datediff(minute,ClientStartTime, SYSUTCDATETIME() ) <  @timespan
  group by ApartmentID, SensorNumber


  insert into  @consumptionTable 
SELECT [ApartmentID]
      ,0,0
	  ,sum([SensorMeasure]) as production
	  ,datediff(SECOND, min([ClientStartTime]),max([ClientStopTime])) as productionTimeSpan
  FROM [Civis_Energy].[dbo].[Sensors_electricityData] 
  where SensorNumber = 8
	and datediff(minute,ClientStartTime, SYSUTCDATETIME() ) <  @timespan
  group by ApartmentID, SensorNumber

  select apartmentID, 
  sum(consumption) as consumptionT,  
  sum(consumptionTimeSpan) as consTimeSpan, 
	CASE 
            WHEN (sum(consumptionTimeSpan) > 0 )
               THEN  sum(consumption) * ( @timespan *60) / sum(consumptionTimeSpan) 
               ELSE 0 
       END as Consumption,
  sum(production) as productionT, 
  sum(productionTimeSpan) as prodTimeSpan, 
  	CASE 
            WHEN (sum(ProductionTimeSpan) > 0 )
               THEN   sum(Production) * ( @timespan *60) / sum(ProductionTimeSpan) 
			  ELSE 0
       END as Production
--  ,sum(production) *  sum(productionTimeSpan) /   sum( consumptionTimeSpan) as normalizedCons
  from  @consumptionTable
  group by apartmentID

END






GO
/****** Object:  StoredProcedure [dbo].[sp_GETNewApartmentId]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GETNewApartmentId]
	-- Add the parameters for the stored procedure here
		@id int =-1 OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	 INSERT INTO [dbo].[Apartment]
        ([DSO])
     VALUES
        ('unknown')
		
set @id = -1
select  @id = ( select top 1 [ApartmentID] from [dbo].[Apartment]  order by apartmentId DESC)

RETURN
END



GO
/****** Object:  StoredProcedure [dbo].[sp_GETupdateCommunityBelonging]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<>
-- Create date: <>
-- Description:	<set/update community belonging for a given apartmentID>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GETupdateCommunityBelonging]
    -- Add the parameters for the stored procedure here
        @ApartmentID int,
        @Communities AS  [dbo].[itemList]  READONLY
--http://stackoverflow.com/questions/11102358/how-to-pass-an-array-into-a-sql-server-stored-procedure		
    
AS
BEGIN

  SET NOCOUNT ON;

	--declare		@Communities   [dbo].[itemList]  
 --   insert into @Communities (itemID) values (12)
  -- declare	@ApartmentID int
 --   set @ApartmentID = 998
 -- SELECT itemID FROM @Communities; 

	declare @now datetime
	set @now =   GETDATE( )

	-- 
	UPDATE [dbo].[Communities]
		SET [MembershipEnd] = @now
	WHERE [ApartmentID] = @ApartmentID
	and [CommunityID] not in (select  itemID FROM @Communities); 

    INSERT INTO [dbo].[Communities]
		 (apartmentID, CommunityID, [MembershipStart]) 
				select @ApartmentID , itemID, @now FROM @Communities where (itemID not in
						(select  CommunityID FROM Communities where [ApartmentID]= @ApartmentID and [MembershipEnd] IS  NULL  )); 

END





GO
/****** Object:  StoredProcedure [dbo].[sp_POSTapartmData]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Francesco Cuscito>
-- Create date: <2015-04-03>
-- Description:	<inserts data provided by installator about dwellers, kitType and PV presence for a certain apartmentID>
-- =============================================
CREATE PROCEDURE [dbo].[sp_POSTapartmData]
	-- Add the parameters for the stored procedure here
		@ApartmentID int,
		@dwellers int,
		@kitType smallint,
		@PV bit
		
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	UPDATE [dbo].[Apartment]
	SET dwellers= @dwellers,
		kitType=@kitType,
		PV=@PV
	WHERE apartmentID=@ApartmentID

END




GO
/****** Object:  StoredProcedure [dbo].[sp_POSTsensorsConf]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Francesco Cuscito>
-- Create date: <2015-04-03>
-- Description:	<inserts data provided by installator about sensors present in a certain apartmentID>
-- =============================================
CREATE PROCEDURE [dbo].[sp_POSTsensorsConf]
	-- Add the parameters for the stored procedure here
		@ApartmentID int,
		@SensorNumber smallint,
		@SensorType smallint,
		@SensorLabel varchar(20)
		
	
AS
BEGIN

	declare @MeasUnit varchar(8)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @SensorType<30
		SET @MeasUnit='Wh'
	ELSE IF @SensorType=31
		SET @MeasUnit='m3'
	ELSE IF ((@SensorType>31) and (@SensorType<34))
		SET @MeasUnit='°C'
	ELSE IF @SensorType>33
		SET @MeasUnit='kCal'
		
	INSERT INTO [dbo].[apartmentMeters]
		(ApartmentID, SensorNumber, SensorType, SensorLabel, MeasureUnit)
	VALUES
		(@ApartmentID, @SensorNumber, @SensorType, @SensorLabel, @MeasUnit)


END




GO
/****** Object:  UserDefinedFunction [dbo].[fn_isHoliday]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_isHoliday](@date DATE)
RETURNS  bit
AS
BEGIN

DECLARE @holiday bit 
SET @holiday = 0
IF datename(DW,@date) = 'Sunday' SET @holiday = 1
ELSE
IF (@date='2015-04-06' or @date='2016-03-28' or @date='2017-03-17' or @date='2018-04-02' 
or @date='2019-04-22' or @date='2020-04-13' or @date='2021-04-05' or @date='2022-04-18' 
or @date='2023-04-10' or @date='2024-04-01' or @date='2025-04-21')
SET @holiday = 1
ELSE
IF ( (Month(@date)=1 and (day(@date)=1 or day(@date)=6))   or 
     (Month(@date)=4 and day(@date)=25) or 
	 (Month(@date)=6 and day(@date)=2)  or
	 (Month(@date)=8 and day(@date)=15) or 
	 (Month(@date)=11 and day(@date)=1) or 
	 (Month(@date)=12 and (day(@date)=25 or day(@date)=26))) 
	 SET @holiday=1

RETURN @holiday
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_IsLeapYear]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_IsLeapYear] ( @pDate DATE )
RETURNS BIT
AS
BEGIN

    IF (YEAR( @pDate ) % 4 = 0 AND YEAR( @pDate ) % 100 != 0) OR
        YEAR( @pDate ) % 400 = 0
        RETURN 1

    RETURN 0

END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_Pasquetta]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_Pasquetta] ( @currentYear int )
RETURNS DATE
AS
BEGIN
	declare @pasquettaDay date
    IF (@currentYear=2016) set @pasquettaDay=CONVERT(date, '2016-03-28' ,102)
	IF (@currentYear=2017) set @pasquettaDay=CONVERT(date, '2017-03-17' ,102)
	IF (@currentYear=2018) set @pasquettaDay=CONVERT(date, '2018-04-02' ,102)
	IF (@currentYear=2019) set @pasquettaDay=CONVERT(date, '2019-04-22' ,102)
	IF (@currentYear=2020) set @pasquettaDay=CONVERT(date, '2020-04-13' ,102)
	IF (@currentYear=2021) set @pasquettaDay=CONVERT(date, '2021-04-05' ,102)
	IF (@currentYear=2022) set @pasquettaDay=CONVERT(date, '2022-04-18' ,102)
	IF (@currentYear=2023) set @pasquettaDay=CONVERT(date, '2023-04-10' ,102)
	IF (@currentYear=2024) set @pasquettaDay=CONVERT(date, '2024-04-01' ,102)
	IF (@currentYear=2025) set @pasquettaDay=CONVERT(date, '2025-04-21' ,102)
    RETURN @pasquettaDay

END

GO
/****** Object:  View [dbo].[vCost_DSO_Monthly]    Script Date: 6/23/2016 12:18:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vCost_DSO_Monthly]
AS
SELECT        ApartmentID, DSO, t.TariffType as Tariff, Month, EnergyMeasure as Energy, EnergyMeasure * t.Price as Cost, s.TimeSlot --,  EnergyMeasure, AveragePowerMeasure,  Cons_Prod_Feedin
FROM          dbo.DSO_MonthlyElectricStats s, [dbo].[TariffType] t
WHERE		 s.TimeSlot = t.TimeSlot and s.DSO = t.TariffType and s.Cons_Prod_Feedin='C'

UNION

SELECT        ApartmentID, DSO, t.TariffType as Tariff, Month, sum(EnergyMeasure) as Energy, sum (EnergyMeasure * t.Price) as Cost, 'Overall' --s.TimeSlot,  EnergyMeasure, AveragePowerMeasure,  Cons_Prod_Feedin
FROM          dbo.DSO_MonthlyElectricStats s, [dbo].[TariffType] t
WHERE		 s.TimeSlot = t.TimeSlot and s.DSO = t.TariffType and s.Cons_Prod_Feedin='C'
group by ApartmentID, DSO, t.TariffType,  Month

GO
