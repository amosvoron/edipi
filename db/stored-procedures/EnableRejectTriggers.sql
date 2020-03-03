
/*
Object:				dbo.EnableRejectTriggers
Description:		Enable the data modification reject triggers.
*/

CREATE PROCEDURE [dbo].[EnableRejectTriggers]
AS

ENABLE TRIGGER dbo.Row_RejectTrigger ON [dbo].[Row];
ENABLE TRIGGER ipi.IP_RejectTrigger ON [ipi].[IP];
ENABLE TRIGGER ipi.IPMembership_RejectTrigger ON [ipi].[IPMembership];
ENABLE TRIGGER ipi.IPMembershipTerritory_RejectTrigger ON [ipi].[IPMembershipTerritory];
ENABLE TRIGGER ipi.IPName_RejectTrigger ON [ipi].[IPName];
ENABLE TRIGGER ipi.IPNameUsage_RejectTrigger ON [ipi].[IPNameUsage];
ENABLE TRIGGER ipi.IPNationality_RejectTrigger ON [ipi].[IPNationality];
ENABLE TRIGGER ipi.IPStatus_RejectTrigger ON [ipi].[IPStatus];

EXEC dbo.FastPrint 'Reject triggers are enabled.';

GO


