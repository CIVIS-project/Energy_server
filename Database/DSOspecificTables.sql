USE [Civis_Energy]
GO

/* Copyright 2016 - * by Concept Reply */
/* Authors: P.. Dal Zovo, F. Cuscito */
/*Software developed within the scopes of the "CIVIS" EU Project http://www.civisproject.eu/ ( FP7-SMARTCITIES-2013 collaborative project, with cofunding of EU, Grant agreement no: 608774) */

USE [Civis_Energy]
GO
/****** Object:  Table [dbo].[CedisEnergiaCedutaAllaRete_Daily]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisEnergiaCedutaAllaRete_Daily](
	[Day] [date] NOT NULL,
	[ApartmentID] [int] NOT NULL,
	[DataCoverage] [int] NULL,
	[EnergyMeasure] [real] NULL,
	[AveragePower] [real] NULL,
	[TimeSlot] [varchar](2) NOT NULL,
	[InferredSampleNumber] [int] NULL,
 CONSTRAINT [PK_CedisEnergiaCedutaAllaRete_Daily] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[ApartmentID] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisEnergiaPrelevataDallaRete_Daily]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisEnergiaPrelevataDallaRete_Daily](
	[Day] [date] NOT NULL,
	[ApartmentID] [int] NOT NULL,
	[DataCoverage] [int] NULL,
	[EnergyMeasure] [real] NULL,
	[AveragePower] [real] NULL,
	[TimeSlot] [varchar](2) NOT NULL,
	[InferredSampleNumber] [int] NULL,
 CONSTRAINT [PK_CedisEnergiaPrelevataDallaRete_Daily] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[ApartmentID] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisEnergiaProdotta_Daily]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisEnergiaProdotta_Daily](
	[Day] [date] NOT NULL,
	[ApartmentID] [int] NOT NULL,
	[DataCoverage] [int] NULL,
	[EnergyMeasure] [real] NULL,
	[AveragePower] [real] NULL,
	[TimeSlot] [varchar](2) NOT NULL,
	[InferredSampleNumber] [int] NULL,
 CONSTRAINT [PK_CedisEnergiaProdotta_Daily] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[ApartmentID] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisRawEnergiaCedutaAllaRete]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisRawEnergiaCedutaAllaRete](
	[KW_C_UTENTE] [int] NOT NULL,
	[StatoCampione] [smallint] NULL,
	[DatoRicostruito] [int] NULL,
	[InizioCampione] [datetime] NOT NULL,
	[FineCampione] [datetime] NOT NULL,
	[ANegCedutaAllaRete] [real] NULL,
	[Timeslot] [varchar](2) NULL,
 CONSTRAINT [PK_CedisRawEnergiaCedutaAllaRete_1] PRIMARY KEY CLUSTERED 
(
	[KW_C_UTENTE] ASC,
	[InizioCampione] ASC,
	[FineCampione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisRawEnergiaCedutaAllaReteTotaleGiorno]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisRawEnergiaCedutaAllaReteTotaleGiorno](
	[KW_C_UTENTE] [int] NOT NULL,
	[KW_POD] [nvarchar](14) NULL,
	[MatricolaConcentratore] [varchar](13) NULL,
	[Concentratore] [varchar](50) NULL,
	[Tariffa] [varchar](4) NULL,
	[DescrTariffa] [varchar](255) NULL,
	[PotenzaImp] [real] NULL,
	[Contatore] [varchar](50) NULL,
	[ANegCedutaAllaRete] [real] NULL,
	[Giorno] [varchar](10) NOT NULL,
	[NrRighe] [int] NULL,
	[ConsumoGiorno] [float] NULL,
	[DiffConsumo] [float] NULL,
 CONSTRAINT [PK_CedisRawEnergiaCedutaAllaReteTotaleGiorno] PRIMARY KEY CLUSTERED 
(
	[KW_C_UTENTE] ASC,
	[Giorno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisRawEnergiaPrelevataDallaRete]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisRawEnergiaPrelevataDallaRete](
	[KW_C_UTENTE] [int] NOT NULL,
	[StatoCampione] [smallint] NULL,
	[DatoRicostruito] [int] NULL,
	[InizioCampione] [datetime] NOT NULL,
	[FineCampione] [datetime] NOT NULL,
	[AposPrelevataDaRete] [real] NULL,
	[TimeSlot] [varchar](2) NULL,
 CONSTRAINT [PK_CedisRawEnergiaPrelevataDallaRete_1] PRIMARY KEY CLUSTERED 
(
	[KW_C_UTENTE] ASC,
	[InizioCampione] ASC,
	[FineCampione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisRawEnergiaPrelevataDallaReteTotaleGiorno]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisRawEnergiaPrelevataDallaReteTotaleGiorno](
	[KW_C_UTENTE] [int] NOT NULL,
	[KW_POD] [nvarchar](14) NULL,
	[MatricolaConcentratore] [varchar](13) NULL,
	[Concentratore] [varchar](50) NULL,
	[Tariffa] [varchar](4) NULL,
	[DescrTariffa] [varchar](255) NULL,
	[PotenzaImp] [real] NULL,
	[Contatore] [varchar](50) NULL,
	[AposPrelevataDaRete] [real] NULL,
	[Giorno] [varchar](10) NOT NULL,
	[NrRighe] [int] NULL,
	[ConsumoGiorno] [float] NULL,
	[DiffConsumo] [float] NULL,
 CONSTRAINT [PK_CedisRawEnergiaPrelevataDallaReteTotaleGiorno] PRIMARY KEY CLUSTERED 
(
	[KW_C_UTENTE] ASC,
	[Giorno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisRawEnergiaProdotta]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisRawEnergiaProdotta](
	[KW_C_UTENTE] [int] NOT NULL,
	[StatoCampione] [smallint] NULL,
	[DatoRicostruito] [int] NULL,
	[InizioCampione] [datetime] NOT NULL,
	[FineCampione] [datetime] NOT NULL,
	[AposEnProdotta] [real] NULL,
	[TimeSlot] [varchar](2) NULL,
 CONSTRAINT [PK_CedisRawEnergiaProdotta_1] PRIMARY KEY CLUSTERED 
(
	[KW_C_UTENTE] ASC,
	[InizioCampione] ASC,
	[FineCampione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CedisRawEnergiaProdottaTotaleGiorno]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CedisRawEnergiaProdottaTotaleGiorno](
	[KW_C_UTENTE] [int] NOT NULL,
	[KW_POD] [nvarchar](14) NULL,
	[MatricolaConcentratore] [varchar](13) NULL,
	[Concentratore] [varchar](50) NULL,
	[Tariffa] [varchar](4) NULL,
	[DescrTariffa] [varchar](255) NULL,
	[PotenzaImp] [real] NULL,
	[Contatore] [varchar](50) NULL,
	[AposEnProdotta] [real] NULL,
	[Giorno] [varchar](10) NOT NULL,
	[NrRighe] [int] NULL,
	[ProduzioneGiorno] [float] NULL,
	[DiffProduzione] [float] NULL,
 CONSTRAINT [PK_CedisRawEnergiaProdottaTotaleGiorno] PRIMARY KEY CLUSTERED 
(
	[KW_C_UTENTE] ASC,
	[Giorno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CEIS_MonthlyElectricStats]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CEIS_MonthlyElectricStats](
	[ApartmentID] [int] NOT NULL,
	[Month] [date] NOT NULL,
	[OverallEnergy] [float] NOT NULL,
	[F1Energy] [float] NOT NULL,
	[F2Energy] [float] NOT NULL,
	[F3Energy] [float] NOT NULL,
	[Power] [float] NULL,
	[Cons_Prod_Feedin] [char](1) NOT NULL,
 CONSTRAINT [PK_CEIS_MonthlyElectricStats] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[Month] ASC,
	[Cons_Prod_Feedin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CeisRawData]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CeisRawData](
	[POD] [varchar](50) NOT NULL,
	[contratto] [varchar](50) NOT NULL,
	[tariffa] [varchar](50) NULL,
	[matricola] [varchar](50) NOT NULL,
	[scambio/produzione] [varchar](1) NOT NULL,
	[data lettura] [varchar](20) NOT NULL,
	[unita misura] [varchar](10) NULL,
	[Attiva F1] [bigint] NULL,
	[Attiva F2] [bigint] NULL,
	[Attiva F3] [bigint] NULL,
	[Attiva totale] [bigint] NULL,
	[unita di misura] [varchar](10) NULL,
	[Potenza F1] [float] NULL,
	[Potenza F2] [float] NULL,
	[Potenza F3] [float] NULL,
	[Immissione F1] [bigint] NULL,
	[Immissione F2] [bigint] NULL,
	[Immissione F3] [bigint] NULL,
	[Immissione totale] [bigint] NULL,
 CONSTRAINT [PK_CeisRawData] PRIMARY KEY CLUSTERED 
(
	[contratto] ASC,
	[matricola] ASC,
	[scambio/produzione] ASC,
	[data lettura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CeisRawDataDiff]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CeisRawDataDiff](
	[ApartmentID] [int] NOT NULL,
	[POD] [varchar](50) NOT NULL,
	[contratto] [varchar](50) NULL,
	[tariffa] [varchar](50) NULL,
	[matricola] [varchar](50) NOT NULL,
	[scambio/produzione] [varchar](1) NOT NULL,
	[data lettura] [varchar](20) NOT NULL,
	[unita misura] [varchar](10) NULL,
	[Attiva F1] [bigint] NULL,
	[Attiva F2] [bigint] NULL,
	[Attiva F3] [bigint] NULL,
	[Attiva totale] [bigint] NULL,
	[unita di misura] [varchar](10) NULL,
	[Potenza F1] [float] NULL,
	[Potenza F2] [float] NULL,
	[Potenza F3] [float] NULL,
	[Immissione F1] [bigint] NULL,
	[Immissione F2] [bigint] NULL,
	[Immissione F3] [bigint] NULL,
	[Immissione totale] [bigint] NULL,
 CONSTRAINT [PK_CeisRawDataDiff] PRIMARY KEY CLUSTERED 
(
	[ApartmentID] ASC,
	[matricola] ASC,
	[scambio/produzione] ASC,
	[data lettura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CeisRawDataPreviousMonth]    Script Date: 6/23/2016 12:17:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CeisRawDataPreviousMonth](
	[POD] [varchar](50) NOT NULL,
	[contratto] [varchar](50) NOT NULL,
	[tariffa] [varchar](50) NULL,
	[matricola] [varchar](50) NOT NULL,
	[scambio/produzione] [varchar](1) NOT NULL,
	[data lettura] [varchar](20) NOT NULL,
	[unita misura] [varchar](10) NULL,
	[Attiva F1] [bigint] NULL,
	[Attiva F2] [bigint] NULL,
	[Attiva F3] [bigint] NULL,
	[Attiva totale] [bigint] NULL,
	[unita di misura] [varchar](10) NULL,
	[Potenza F1] [float] NULL,
	[Potenza F2] [float] NULL,
	[Potenza F3] [float] NULL,
	[Immissione F1] [bigint] NULL,
	[Immissione F2] [bigint] NULL,
	[Immissione F3] [bigint] NULL,
	[Immissione totale] [bigint] NULL,
 CONSTRAINT [PK_CeisRawDataPreviousMonth] PRIMARY KEY CLUSTERED 
(
	[contratto] ASC,
	[matricola] ASC,
	[scambio/produzione] ASC,
	[data lettura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
