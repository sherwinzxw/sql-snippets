CREATE TABLE [dbo].[dbo.metadata_control_conformance](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceServerName] [varchar](255) NULL,
	[SourceDatabaseName] [varchar](255) NULL,
	[SourceTableSchemaName] [varchar](32) NULL,
	[SourceTableName] [varchar](255) NULL,
	[SourceColumnName] [varchar](255) NULL,
	[TargetColumnName] [varchar](255) NULL,
	[TargetColumnType] [varchar](255) NULL,
	[ActiveFlag] [bit] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[dbo.metadata_control_conformance] ADD  DEFAULT ((1)) FOR [ActiveFlag]
GO