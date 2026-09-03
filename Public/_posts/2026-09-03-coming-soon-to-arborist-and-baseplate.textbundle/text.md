I've been hard at work on updates to [Arborist](https://taphouse.io/arborist) and [Baseplate](https://taphouse.io/baseplate) recently and wanted to give a preview of what's coming up.

## Arborist 1.2

The list of things for Arborist 1.2 keeps growing and I think it's about ready to release. I've been building a help section to the Taphouse website and writing Arborist articles based on some feedback questions I've received as well as the typical "getting started" kind of things. I think finishing out that part of the website and adding the actual link into Arborist's help menu is the last thing I have to do.

Release highlights:

* I built a new feature where Arborist will recognize a `Makefile` or a [mise](https://mise.jdx.dev) configuration and import those tasks to run right in the app. I used to be a big `make` user but migrated to `mise` a couple of years ago and it's become a key part of my workflows. Having those tasks right in Arborist has been amazing. If you'd like to see an example of how I use `mise`, [here is this site's `.mise.toml` file](https://github.com/jsorge/jsorge.net/blob/main/.mise.toml).
* A feature request that I got was adding a filter to the branch selector popup when creating a worktree. I added support for this too and it's been _super useful_ in my day-to-day as I'm making new worktrees. This one was fun because it gave me a chance to drop down to AppKit and wrap that in a SwiftUI representable view.
* I took inspiration from [Rogue Amoeba](https://weblog.rogueamoeba.com/2026/04/28/unobtrusive-update-notifications/) and made the "Update available" indicator appear inline in the status bar – at the bottom of the window, but there really wasn't room at the top when I tried that thanks to the unified toolbar – and I really like how this turned out. It stands out just enough in both light and dark modes.
* I had been fighting with SwiftUI and `SplitView` to the point where if I moved the inspector pane's size too much I would get crashes, so I had to restrict the sizes of the sidebar and inspector. No longer! I have changed the main window structure to AppKit and am using `NSSplitViewController` to power it, and the feel of the app is just so much smoother now.

There's also a bunch of bug fixes especially around cancelling commands (thanks to the updated [swift-subprocess](https://github.com/swiftlang/swift-subprocess) library) and other things that I found bothersome during my regular usage of the app while building my other apps or at [my day job](https://apps.apple.com/us/app/adobe-firefly-ai-video-photo/id6742595426).

## Baseplate

I acquired Baseplate a couple of years ago now and that has been such an interesting experience. Learning someone else's code, updating it to be more my style, and adding features there has been fun but also slow going (just look at the update history). But I've been hard at work at Baseplate 2.0 and I'm so excited to get this app out into the world.

It's basically a rebuild of the UI. The current interface is very custom, and worked well in a pre-Liquid Glass world but it started feeling a bit dated to me. So I've set out to breathe new life into the app with a massive redesign, but also many under-the-hood changes as well.

* Baseplate will now sync your collection data between your iPhone, iPad, Mac, and Vision Pro (I'm letting go of the watch app for now). Seeing my data come across from one device to the other for the first time was _magic_ and I hope this feature really lets customers dive in to their Lego collections on all their devices. This took quite a bit of planning and careful migration – I've moved to using [SQLiteData](https://github.com/pointfreeco/sqlite-data) from the excellent Point-Free folks and it's been wonderful.
* The UI as I mentioned is completely redesigned. I'm making your Lego collection the first tab, and want the app to be all about what you have on your shelf and in your queue to build. I'm really happy landing on my stuff when I launch the app now.
* Next is the Discover tab, which will start out with the familiar list of themes as a starting point but then gives you search right away. I moved the Vision feature to this tab as well as a button in the navigation bar. It's a very cool feature but I think it is another way of searching for sets so it fits better in this tab.
* A brand new tab is Radar. This is where your wanted sets will land, and I'm adding sections below those for sets just announced by Lego so you can see what's on the horizon. There's also links in all the sets to buy them from Lego.com, and I'm getting product data for sets as well so you can see what sets are available, what are retired, etc. I'm really happy with how this tab has turned out!

I've also saved the best for last: Baseplate has a brand new icon that _I am in love with_. The fine folks at [The Iconfactory](https://seadev.slack.com/archives/C04DUMZRY/p1785261580651979) had a great offer recently to help indie apps remake their icons and I jumped on it. I could not be happier with the result and can't wait for you to see it on your home screen!

I'm targeting the iOS 27 launch day for Baseplate 2.0, though it may be the end of September. We'll find out the OS launch date [on September 9th](https://www.apple.com/newsroom/in-the-loop/2026/08/surprise-and-shine/) 😀.