CREATE PROCEDURE [dbo].[spWritePackageProgressLog]
(
    @PackageName         VARCHAR(MAX)
    , @EventType         VARCHAR(MAX)
    , @EventSource         VARCHAR(MAX)
    , @EventCode         VARCHAR(MAX)
    , @EventMessage     VARCHAR(MAX)
    , @JobID           INT
)
AS
BEGIN
	IF LEFT( @EventSource , 12 ) = 'Log Process.'
	BEGIN
		RETURN 0
	END
INSERT INTO dbo.PackageProgressLog(
    PackageName
    , EventType
    , EventSource
    , EventCode 
    , EventMessage
    , EventDate
    , JobID
)
VALUES ( SUBSTRING(@PackageName,1,50), SUBSTRING(@EventType,1,50), SUBSTRING(@EventSource,1,50), SUBSTRING(@EventCode,1,50), @EventMessage, GETDATE(),@JobID );
END
