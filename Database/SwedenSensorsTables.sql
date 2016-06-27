USE [Civis_Energy_Sweden]
GO
/****** Object:  Table [dbo].[Energimolnet_Data]    Script Date: 6/27/2016 5:37:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Energimolnet_Data](
	[ApartmentID] [varchar](50) NOT NULL,
	[StartTimestamp] [datetimeoffset](7) NOT NULL,
	[EndTimestamp] [datetimeoffset](7) NOT NULL,
	[EnergyMeasure] [float] NOT NULL,
	[Cons_Prod] [char](1) NOT NULL,
 CONSTRAINT [PK_Energimolnet_Data] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[StartTimestamp] ASC,
	[Cons_Prod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MaxCube_Data]    Script Date: 6/27/2016 5:37:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MaxCube_Data](
	[ApartmentID] [nvarchar](50) NOT NULL,
	[ClientTimestamp] [datetimeoffset](7) NOT NULL,
	[MaxCubeID] [nvarchar](10) NOT NULL,
	[RoomID] [nvarchar](50) NOT NULL,
	[TargetTemperature] [real] NOT NULL,
	[ActualTemperature] [real] NOT NULL,
	[RoomLabel] [nvarchar](20) NULL,
 CONSTRAINT [PK_OEM_Data] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[ClientTimestamp] ASC,
	[MaxCubeID] ASC,
	[RoomID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Smappee_Data]    Script Date: 6/27/2016 5:37:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Smappee_Data](
	[ApartmentID] [nvarchar](50) NOT NULL,
	[StartTimestamp] [datetimeoffset](7) NOT NULL,
	[EndTimestamp] [datetimeoffset](7) NOT NULL,
	[SmappeeID] [bigint] NOT NULL,
	[SensorMeasure] [float] NOT NULL,
 CONSTRAINT [PK_SmappeeData] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[StartTimestamp] ASC,
	[SmappeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Energimolnet_Data] ADD  DEFAULT ('C') FOR [Cons_Prod]
GO
