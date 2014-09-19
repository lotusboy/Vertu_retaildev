/*
Developer Name   : Mick Nicholson (BrightGen Ltd)
Deployment Date  : 
Description      : After insert trigger on EmailMessage
*/ 
trigger EmailMessageAfterInsert on EmailMessage (after insert) {

	List <EmailMessage> newInboundEmails = new List<EmailMessage>();
	for (EmailMessage newEmail : trigger.new)
	{
		if (newEmail.Incoming)
		{
			newInboundEmails.add(newEmail);
		}
	}
	//Check to see if this emailMessage has been added to a closed case. If so create a new case and reassign this message 
	if (newInboundEmails.size() > 0)
	{
		EmailMessageUtils.checkForClosedCases(newInboundEmails);
	}
}