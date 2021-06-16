One of the more confusing aspects of releasing iOS apps on the App Store has to be phased releases. There is pretty sparse (and confusing at that) documentation which leaves much room for questions – which in turn lead to more questions still. My aim with this post is to help clarify some core tenets of this process and hopefully spare you and your team the confusion that has come to myself and my team.

Let's start by establishing some principles:

1. Only one version of your app can be on the App Store at any given time.
2. A phased release lets you slowly allow users to **auto-update** to a new version at a slow percentage.
3. New users and manual updaters can _always_ get your newest version from the App Store.

When you decide to phase a release ([Apple Documentation](https://help.apple.com/app-store-connect/#/dev3d65fcee1)), you're specifying the percentage of users who will be auto-updated to that release. The cadence is over 7 phases (1%, 2%, 5%, 10%, 20%, 50%, and 100%). Generally one phase equates to one day, but the release can be paused on a phase for up to 30 days. The happy path is making a release that gets phased without problem over 7 days and you're done.

Let's run through a scenario where things go on the not-so-happy path and see what happens.

Say we have an app and version 5.1 which is at 100%; new users and all updates will get this version. On Monday we release 5.2 using the phased release. This means that 1% of automatic updates will receive v5.2, but new downloads and manual updates can be performed to get 5.2 as well.

On Tuesday (phase 2, which is 2%) we identify an issue with 5.2 and decide to pause the rollout. This will stop the automatic updates from happening to 5.2 (but again, new users and manual updaters can get it). We identify a fix and submit it with version 5.2.1. That release also gets phased. So what happens now? We've had 5.1 available to everyone, 5.2 at a 2% automatic update, and now 5.2.1. Here's what happens:

* 5.2 gets replaced on the App Store with 5.2.1: new users and manual updaters can only get to 5.2.1.
* 5.2 also completes its phasing, but no additional users can get to it (see principle #1 above).
* 5.2.1 begins a new phase – it does not replace the phasing of 5.2 that we had in place already – and it is at 1% at release.
* There will be some subset of users on version 5.2 who will not be auto-updated to 5.2.1 for "some amount of time".
    * It is likely possible for a user to have been in the first 1% of 5.2, and also to be in the final 50% of 5.2.1 (the documentation is _very unclear_ about this).

Phased releases can be a great tool to help control the rollout of new versions of your app. Before we had them we just had to make a release that went to everyone and had no control over that cadence at all. But there are some nuances that can easily trip up app developers and their teams alike. I hope this has been a helpful walkthrough in the life of a phased app release and brings clarity to questions that you may have encountered along the way.
