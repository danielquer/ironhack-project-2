# ironhack-project-2
Analytics Project for Ironhack using Beelinguapp data

# Summary of the results
In the first model, people who use IOS are tend to subscribe more than Android Users with 1.64 coefficient and low p-value.
Users who were also triggering events such as EnterFcMore, Library Clicked, PlayNextParagraphFromBut, StartListening, 
TryToBuyNewPAct,sv__AAPageA,sv__AAPageF,sv__GoldPageF are tend to subscribe while some events such as sv__StoryDetails, sv__ProPageA,sv__NewPremiumAct have negative impact

In the second model, we have excluded IOS users but Android Users are not very effective in terms of the conversion as we also seen in the first model. We have got lower p_value on WelcomeCarouselDialog but it is not significant

In the third model we excluded purchases within 30 mins and thereby we have had only 65 purchases between 1st of November and today. We can see that sv__Libraries,PlayNextParagraph have positive impacts

Lastly, we have excluded the events that needs to be done before premium purchase and we have ended up with variables almost all have low p-value

