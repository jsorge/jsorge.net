I’ve been quite slow in developing Scorebook for the past month. Mostly due to [personal reasons](http://jsorge.net/2014/12/11/goodbye-twins/), but I’ve also been trying to think of what to do next on it. I’ve gotten some good feedback from users and now have a list of feature enhancements that should make Scorebook more interesting to more people.

Before I talk about some future plans, let’s look back a bit.

While Scorebook is my first shipping app that I’ve brought to market, it was long in development. I got the hankering to make it almost 3 years ago – when I didn’t know how to write really any code. Looking back at my Day One journal I got the idea back in early March, 2012. At that point I had never seen a line of code in an iOS app. Fast forward to June 2014. I just completed my certificate at UW and set out to build Scorebook. The project file was created on June 26, 2014.

I never spent more than a few hours at a time writing any code, and mostly the time was chunked up into 30 minutes here, or an hour there. I regularly attend [NSCoders](http://www.meetup.com/xcoders/) and got some good work done in the few hours at the coffee house and talking with the other folks who attend there. Side note: if you’re a developer and not in a community with other folks who work on similar things, you’re doing it wrong. Don’t be an island.

6208 lines of code later and Scorebook 1.0 was ready for the App Store. I had a few beta testers who provided useful feedback and found some crashing bugs that I was able to squash, and I’m so happy to report that there have been 0 crashes on the shipping versions, 1.0 and 1.0.1. I could not be more pleased with this. There are 2 things that I dread: losing someone’s data, and crashing. Neither have happened. Praise the Lord.

On to the future!

I think I’ve figured out the next course to take. I’ve begun working on Scorebook 1.1 and that will have 2 main new features:

* It will be universal, to work with iPads natively
* It will sync

Both of these are massive things to undertake, with the iPad version made a little bit easier due to the new adaptive layout tools Apple has provided with iOS 8. The main thing that I will need to do is move a couple of layouts from table views (a vertically scrolling list of things to collection views (where you can do arbitrary layouts). The main reason is that just blowing it up to fit a screen isn’t good for anyone and if I’m going to utilize all that space I should do it right.

Data sync will be more intense. Like I said before, losing someone’s data is a prospect that keeps me up at night; I’m not going to ship anything that will jeopardize user data. My plan is to use CloudKit and users’ iCloud accounts for syncing their data. I’ve heard about enough successes with CloudKit that I’m satisfied it will work well. I’ve switched myself over to iCloud sync on 1Password and it’s been great so far.

So that is what to be expecting out of Scorebook for the next big update. I don’t have any prediction on how long it will take, but I do plan on writing about progress, what I’m learning and a little bit of how things work behind the scenes. I’m starting with sync, so look for some progress updates in the coming days/weeks/months.
