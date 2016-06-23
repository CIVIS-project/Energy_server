USE [Civis_Energy]
GO

/* Copyright 2016 - * by Concept Reply */
/* Authors: P.. Dal Zovo, F. Cuscito */
/*Software developed within the scopes of the "CIVIS" EU Project http://www.civisproject.eu/ (FP7-SMARTCITIES-2013 collaborative project, with cofunding of EU, Grant agreement no: 608774) */


/****** Object:  Table [dbo].[Apartment]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Apartment](
	[ApartmentID] [int] IDENTITY(1,1) NOT NULL,
	[FamilyID] [int] NULL,
	[DSO] [varchar](10) NOT NULL,
	[ContractID] [varchar](30) NULL,
	[POD] [varchar](30) NULL,
	[Tariff_code] [nvarchar](12) NULL,
	[Dwellers] [int] NULL,
	[PV] [bit] NULL,
	[City] [varchar](30) NULL,
	[KitType] [tinyint] NULL,
 CONSTRAINT [PK_Apartment] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ApartmentMeters]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApartmentMeters](
	[ApartmentID] [int] NOT NULL,
	[SensorNumber] [smallint] NOT NULL,
	[SensorType] [smallint] NULL,
	[MeasureUnit] [varchar](5) NULL,
	[SensorLabel] [varchar](20) NULL,
	[LastSampleTimestamp] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ApartmentMeters] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[SensorNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Communities]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Communities](
	[ApartmentID] [int] NOT NULL,
	[CommunityID] [nchar](10) NOT NULL,
	[MembershipStart] [datetime] NOT NULL,
	[MembershipEnd] [datetime] NULL,
 CONSTRAINT [PK_Communities] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[CommunityID] ASC,
	[MembershipStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DetectedOverheating]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetectedOverheating](
	[SituationID] [nvarchar](50) NOT NULL,
	[ApartmentID] [nvarchar](50) NULL,
	[TimeStart] [datetimeoffset](7) NULL,
	[TimeStop] [datetimeoffset](7) NULL,
	[Information] [nvarchar](200) NULL,
	[Accepted] [nchar](20) NULL,
	[TimeDetected] [datetime] NULL,
	[Additional_info] [nvarchar](100) NULL,
 CONSTRAINT [PK_DetectedOverheating] PRIMARY KEY CLUSTERED 
(
	[SituationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DetectedSituation]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetectedSituation](
	[SituationID] [nvarchar](50) NOT NULL,
	[ApartmentID] [int] NULL,
	[TimeStart] [datetimeoffset](7) NULL,
	[TimeStop] [datetimeoffset](7) NULL,
	[Information] [nvarchar](200) NULL,
	[Accepted] [nchar](20) NULL,
	[TimeDetected] [datetime] NULL,
	[Additional_info] [nvarchar](100) NULL,
 CONSTRAINT [PK_DetectedSituation_new] PRIMARY KEY CLUSTERED 
(
	[SituationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DetectedSituation2]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetectedSituation2](
	[SituationID] [nvarchar](50) NOT NULL,
	[ApartmentID] [int] NULL,
	[TimeStart] [datetimeoffset](7) NULL,
	[TimeStop] [datetimeoffset](7) NULL,
	[Information] [nvarchar](200) NULL,
	[Accepted] [nchar](20) NULL,
	[TimeDetected] [datetime] NULL,
	[Additional_info] [nvarchar](100) NULL,
 CONSTRAINT [PK_DetectedSituation2] PRIMARY KEY CLUSTERED 
(
	[SituationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DSO_MonthlyElectricStats]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DSO_MonthlyElectricStats](
	[ApartmentID] [nvarchar](50) NOT NULL,
	[DSO] [nvarchar](20) NOT NULL,
	[Month] [date] NOT NULL,
	[AveragePowerMeasure] [float] NOT NULL,
	[EnergyMeasure] [float] NOT NULL,
	[TimeSlot] [char](2) NOT NULL,
	[Cons_Prod_Feedin] [char](1) NOT NULL,
	[Datacoverage] [int] NULL,
	[InferredSampleNumber] [int] NULL,
 CONSTRAINT [PK_DSO_MonthlyElectricStats] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[Month] ASC,
	[TimeSlot] ASC,
	[Cons_Prod_Feedin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EsternalTemperatureTable]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EsternalTemperatureTable](
	[extPositionID] [int] NULL,
	[extTemperature] [real] NULL,
	[startTime] [datetimeoffset](7) NULL,
	[endTime] [datetimeoffset](7) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HeatingData]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HeatingData](
	[ApartmentID] [int] NOT NULL,
	[ClientTimestamp] [datetimeoffset](7) NOT NULL,
	[ServerArrivalTime] [datetimeoffset](7) NOT NULL,
	[SensorNumber] [tinyint] NOT NULL,
	[SensorMeasure] [float] NOT NULL,
	[NTPsynched] [tinyint] NOT NULL,
	[RealTime_Transm] [bit] NOT NULL,
 CONSTRAINT [PK_HeatingData] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[ClientTimestamp] ASC,
	[SensorNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NewDetectedSituation]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewDetectedSituation](
	[SituationID] [nvarchar](50) NOT NULL,
	[ApartmentID] [int] NULL,
	[TimeStart] [datetimeoffset](7) NULL,
	[TimeStop] [datetimeoffset](7) NULL,
	[Information] [nvarchar](200) NULL,
	[Accepted] [nchar](20) NULL,
	[TimeDetected] [datetimeoffset](7) NULL,
	[Additional_info] [nvarchar](100) NULL,
 CONSTRAINT [PK_NewDetectedSituation] PRIMARY KEY CLUSTERED 
(
	[SituationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OEM_Data]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OEM_Data](
	[ApartmentID] [int] NOT NULL,
	[ClientTimestamp] [datetimeoffset](7) NOT NULL,
	[ServerArrivalTime] [datetimeoffset](7) NOT NULL,
	[Temperature] [real] NOT NULL,
	[SensorNumber] [int] NOT NULL,
	[PositionID] [int] NOT NULL,
	[NTPsynched] [tinyint] NOT NULL,
	[RealTime_Transm] [bit] NOT NULL,
 CONSTRAINT [PK_OEM_Data] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[ClientTimestamp] ASC,
	[SensorNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sensors_DailyElectricStats]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensors_DailyElectricStats](
	[Day] [date] NOT NULL,
	[ApartmentID] [int] NOT NULL,
	[datacoverage] [int] NOT NULL,
	[SensorNumber] [tinyint] NOT NULL,
	[TimeSlot] [nvarchar](2) NOT NULL,
	[EnergyMeasure] [float] NOT NULL,
	[AveragePower] [float] NOT NULL,
	[ConsVsProd] [bit] NOT NULL,
 CONSTRAINT [PK_Sensors_DailyElectricStats] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[ApartmentID] ASC,
	[SensorNumber] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sensors_electricityData]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensors_electricityData](
	[ApartmentID] [int] NOT NULL,
	[ClientStartTime] [datetimeoffset](7) NOT NULL,
	[ClientStopTime] [datetimeoffset](7) NOT NULL,
	[ServerArrivalTime] [datetimeoffset](7) NOT NULL,
	[SensorNumber] [tinyint] NOT NULL,
	[SensorMeasure] [real] NOT NULL,
	[ConsVsProd] [bit] NOT NULL,
	[RealTime_Transm] [bit] NOT NULL,
	[NTPsynched] [tinyint] NOT NULL,
	[TimeSlot] [nvarchar](2) NOT NULL,
	[RadioErrorIndex] [tinyint] NULL,
 CONSTRAINT [PK_Sensors_electricityData] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[ClientStopTime] ASC,
	[SensorNumber] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sensors_MonthlyElectricStats]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensors_MonthlyElectricStats](
	[Month_StartDay] [date] NOT NULL,
	[ApartmentID] [int] NOT NULL,
	[datacoverage] [int] NOT NULL,
	[SensorNumber] [tinyint] NOT NULL,
	[TimeSlot] [nvarchar](2) NOT NULL,
	[EnergyMeasure] [float] NOT NULL,
	[AveragePower] [float] NOT NULL,
	[ConsVsProd] [bit] NOT NULL,
 CONSTRAINT [PK_Sensors_MonthlyElectricStats] PRIMARY KEY CLUSTERED 
(
	[Month_StartDay] ASC,
	[ApartmentID] ASC,
	[SensorNumber] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ShiftableConsumption]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShiftableConsumption](
	[ApartmentID] [int] NOT NULL,
	[SensorNumber] [smallint] NOT NULL,
	[SensorLabel] [varchar](20) NOT NULL,
	[StartDate] [datetimeoffset](7) NOT NULL,
	[Measure] [float] NOT NULL,
	[Timeslot] [nvarchar](2) NOT NULL,
	[AllTimeslots] [float] NULL,
 CONSTRAINT [PK_ShiftableConsumption] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[SensorNumber] ASC,
	[SensorLabel] ASC,
	[StartDate] ASC,
	[Timeslot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TariffType]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TariffType](
	[TariffType] [varchar](10) NOT NULL,
	[TimeSlot] [varchar](2) NOT NULL,
	[Price] [float] NOT NULL,
 CONSTRAINT [PK_TARIFFTYPE] PRIMARY KEY CLUSTERED 
(
	[TariffType] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WeatherForecast]    Script Date: 6/23/2016 12:10:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WeatherForecast](
	[City] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[PubDate] [datetime] NOT NULL,
	[ForecastRefTime01] [datetime] NOT NULL,
	[Clouds01] [float] NOT NULL,
	[Temperature01] [float] NOT NULL,
	[Precipitation01] [float] NOT NULL,
	[Humidity01] [float] NOT NULL,
	[ForecastRefTime02] [datetime] NOT NULL,
	[Clouds02] [float] NOT NULL,
	[Temperature02] [float] NOT NULL,
	[Precipitation02] [float] NOT NULL,
	[Humidity02] [float] NOT NULL,
	[ForecastRefTime03] [datetime] NOT NULL,
	[Clouds03] [float] NOT NULL,
	[Temperature03] [float] NOT NULL,
	[Precipitation03] [float] NOT NULL,
	[Humidity03] [float] NOT NULL,
	[ForecastRefTime04] [datetime] NOT NULL,
	[Clouds04] [float] NOT NULL,
	[Temperature04] [float] NOT NULL,
	[Precipitation04] [float] NOT NULL,
	[Humidity04] [float] NOT NULL,
	[ForecastRefTime05] [datetime] NOT NULL,
	[Clouds05] [float] NOT NULL,
	[Temperature05] [float] NOT NULL,
	[Precipitation05] [float] NOT NULL,
	[Humidity05] [float] NOT NULL,
	[ForecastRefTime06] [datetime] NOT NULL,
	[Clouds06] [float] NOT NULL,
	[Temperature06] [float] NOT NULL,
	[Precipitation06] [float] NOT NULL,
	[Humidity06] [float] NOT NULL,
	[ForecastRefTime07] [datetime] NOT NULL,
	[Clouds07] [float] NOT NULL,
	[Temperature07] [float] NOT NULL,
	[Precipitation07] [float] NOT NULL,
	[Humidity07] [float] NOT NULL,
	[ForecastRefTime08] [datetime] NOT NULL,
	[Clouds08] [float] NOT NULL,
	[Temperature08] [float] NOT NULL,
	[Precipitation08] [float] NOT NULL,
	[Humidity08] [float] NOT NULL,
	[ForecastRefTime09] [datetime] NOT NULL,
	[Clouds09] [float] NOT NULL,
	[Temperature09] [float] NOT NULL,
	[Precipitation09] [float] NOT NULL,
	[Humidity09] [float] NOT NULL,
	[ForecastRefTime10] [datetime] NOT NULL,
	[Clouds10] [float] NOT NULL,
	[Temperature10] [float] NOT NULL,
	[Precipitation10] [float] NOT NULL,
	[Humidity10] [float] NOT NULL,
	[ForecastRefTime11] [datetime] NOT NULL,
	[Clouds11] [float] NOT NULL,
	[Temperature11] [float] NOT NULL,
	[Precipitation11] [float] NOT NULL,
	[Humidity11] [float] NOT NULL,
	[ForecastRefTime12] [datetime] NOT NULL,
	[Clouds12] [float] NOT NULL,
	[Temperature12] [float] NOT NULL,
	[Precipitation12] [float] NOT NULL,
	[Humidity12] [float] NOT NULL,
	[Sunrise] [datetime] NOT NULL,
	[Sunset] [datetime] NOT NULL,
 CONSTRAINT [PK_WeatherForecast] PRIMARY KEY CLUSTERED 
(
	[City] ASC,
	[PubDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ApartmentMeters]  WITH CHECK ADD  CONSTRAINT [FK_ApartmentMeters_Apartment] FOREIGN KEY([ApartmentID])
REFERENCES [dbo].[Apartment] ([ApartmentID])
GO
ALTER TABLE [dbo].[ApartmentMeters] CHECK CONSTRAINT [FK_ApartmentMeters_Apartment]
GO
