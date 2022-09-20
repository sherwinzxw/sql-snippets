CREATE TABLE [dbo].[metadata_control_landing](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceServerName] [varchar](255) NULL,
	[SourceDatabaseName] [varchar](255) NULL,
	[SourceTableSchemaName] [varchar](32) NULL,
	[SourceTableName] [varchar](255) NULL,
	[IsFullLoadFlag] [bit] NULL,
	[IsDeltaLoadFlag] [bit] NULL,
	[DeltaLoadWatermarkColumnName] [varchar](255) NULL,
	[DeltaLoadWatermarkColumnType] [varchar](32) NULL,
	[IsActiveFlag] [bit] NOT NULL,
	[DeltaLoadLastDateTimeWaterMarkValue] [datetime] NULL,
	[DeltaLoadLastIntegerWaterMarkValue] [int] NULL,
	[LastDataLoadExecutionDateTime] [datetime] NULL,
	[LastFullLoadRowCounts] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[metadata_control_landing] ADD  DEFAULT ('dbo') FOR [SourceTableSchemaName]
GO

ALTER TABLE [dbo].[metadata_control_landing] ADD  DEFAULT ((1)) FOR [IsFullLoadFlag]
GO

ALTER TABLE [dbo].[metadata_control_landing] ADD  DEFAULT ((0)) FOR [IsDeltaLoadFlag]
GO


