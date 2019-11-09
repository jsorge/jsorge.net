When I relaunched my website last summer using my homegrown blog engine ([Maverick](https://github.com/jsorge/maverick)) I adopted the [textbundle](https://textbundle.org) format for writing posts and I was using [Ulysses](https://ulysses.app) for my writing. But after launching the site and using Ulysses for long enough I was running into some friction with their Markdown syntax. That led me to the decision to not renew my subscription when the time came.

I'd since gotten a [BBEdit](https://www.barebones.com/products/bbedit/index.html) license after hearing _tons_ of people I highly respect speak glowingly about it and decided to use it for writing my posts. It doesn't support textbundle natively like Ulysses does, but it does well enough for my needs. textbundles are in fact just a folder with a Markdown file inside with an optional assets directory. So I've been using BBEdit for writing on my Mac ever since.

But I've been running into a different kind of friction: making new posts was kind of painful. I've been manually making the directory structure, copying the `info.json` file, and creating the text file myself. I'd written an [Alfred](https://www.alfredapp.com) snippet to create the front matter that each post needs, but that's become problematic too because dates are hard (more on that in a minute).

Well, we've gotten deluged with snow in my neck of the woods so I figured I'd dive in to a couple of new tools and get this thing automated. I watched through the [NSScreencast](https://nsscreencast.com/episodes/368-marathon-part-1) episodes with [John Sundell](https://www.swiftbysundell.com) explaining his [Marathon](https://github.com/johnsundell/marathon) scripting tool written in Swift, for Swift. I was able to take that knowledge and make a little script which outputs the directory structure I need, fills the front matter on the post, and launches me into BBEdit where I can write away.

Part of the spark for this was that I'd approached dates all wrong when I built Maverick. I used dates in my current time, not against UTC. I have posts automatically show up on [my microblog](https://mb.jsorge.net) using [micro.blog's](https://micro.blog) cross posting functionality and when my posts came over they were off by 8 hours or so (I'm in the Pacific time zone). So I had to go through all my posts and update times, then use dates that are UTC based (formatting them using an `ISO8601DateFormatter` and `.withInternetDateTime`).

I should be all set now, and my posts showing up in the correct order on my microblog. Happy Saturday!

**Update**

[Here's the script that I wrote, in case you're interested 🙂](https://github.com/jsorge/jsorge.net/blob/master/tools/NewBlogPost.swift)
