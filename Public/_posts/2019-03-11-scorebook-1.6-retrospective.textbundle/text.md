Scorebook v1.6 shipped a little over a week ago, and it _finally_ includes all my sync code. When I cracked the project back open late last year I decided to turn off the engine that I'd put together just to get the app back in shippable condition. But I also knew that I wanted to ship the sync shortly thereafter. Well, it took about 6 weeks for me to be comfortable enough to get it out the door.

Honestly it's a little embarrassing how long it took to get this feature out. I started writing about it over 4 years ago (if you're interested in reading through the journey, [they are curated here](https://jsorge.net/tag/scorebook-sync-log)). I thought I was going to get the feature shipped by WWDC 2015. Welp. It's out there now, and that's the important thing.

Back when I was building the feature I knew I wanted it to be as seamless as possible. A modal on startup asking the user if they want to turn it on, and then a simple switch in the Setting screen. Everything else should be handle-able by my sync code. And because their data lives in iCloud I don't have to worry myself about encrypting or having any access to user data. Mission accomplished on both fronts.

As I revisited the feature when getting back into the app there were a few deprecations that had come in since iOS 8 but the code I wrote back then was still good. I did it all in Objective-C so there weren't any crazy language changes to migrate through (thank God I didn't adopt Swift 1!).

Now I get to look forward to building truly new features. I know I want to tackle dynamic type and accessibility, and might do that next. Then come the summer I want to rethink what the gameplay setup screen looks like as well as the scorecard screen. I know the whole UI could use some updating since it's very much from the iOS 7 era of design. But for most of that I'll hold off to see what Apple has in store for us at WWDC.

[Check out Scorebook 1.6 in the App Store!](https://itunes.apple.com/us/app/scorebook-game-journal/id897584352?ls=1&mt=8)
