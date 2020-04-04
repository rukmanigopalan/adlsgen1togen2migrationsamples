
CREATE procedure uspCompareGen1Gen2
as
begin

Drop table if exists dbo.Gen1Gen2Comparison

;With cteGen1Gen2Details AS
(
SELECT replace(g1.[path], '/DataWarehouse/', '') AS Gen1FilePath
	,g1.Length AS Gen1FileSize
	,g1.LastWriteTime AS Gen1FileLastModified
	,g2.Name AS Gen2FilePath
	,g2.Length AS Gen2FileSize
	,g2.LastModified AS Gen2FileLastModified
FROM [dbo].Gen1Inventory AS g1
LEFT JOIN [dbo].Gen2Inventory AS g2
	ON replace(g1.[path], '/DataWarehouse/', '') = g2.[Name]
)
SELECT *
	,CASE WHEN Gen1FilePath = Gen2FilePath THEN 1
		ELSE 0 END AS IsFileCopied
	,CASE WHEN Gen1FileSize = Gen2FileSize THEN 1
		ELSE 0 END AS IsFileSizeMatch
	,GETDATE() AS RowInsertedDate
INTO Gen1Gen2Comparison
FROM cteGen1Gen2Details
end
