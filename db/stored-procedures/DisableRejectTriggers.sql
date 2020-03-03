
/*
Object:				dbo.DisableRejectTriggers
Description:		Disable the data modification reject triggers.
*/
CREATE PROCEDURE [dbo].[DisableRejectTriggers]
AS

DISABLE TRIGGER dbo.Row_RejectTrigger ON [dbo].[Row];
DISABLE TRIGGER ipi.IP_RejectTrigger ON [ipi].[IP];
DISABLE TRIGGER ipi.IPMembership_RejectTrigger ON [ipi].[IPMembership];
DISABLE TRIGGER ipi.IPMembershipTerritory_RejectTrigger ON [ipi].[IPMembershipTerritory];
DISABLE TRIGGER ipi.IPName_RejectTrigger ON [ipi].[IPName];
DISABLE TRIGGER ipi.IPNameUsage_RejectTrigger ON [ipi].[IPNameUsage];
DISABLE TRIGGER ipi.IPNationality_RejectTrigger ON [ipi].[IPNationality];
DISABLE TRIGGER ipi.IPStatus_RejectTrigger ON [ipi].[IPStatus];

EXEC dbo.FastPrint 'Reject triggers are disabled.';


GO


