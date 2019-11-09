A couple of weeks ago I brought my app back from the dead. Scorebook was first released in November 2014, got a minor bugfix update a month later and then was unceremoniously removed from the App Store by Apple in January 2018. Apple doesn't want apps that appear dead on their store anymore and with good reason. By all external accounts my app wasn't under active development.

And it wasn't. Over the last couple of years my desire to play games had gone down because I didn't want to use my app with the state it was in. Mid-last year I even joined a beta for an app under development that was very close in functionality to Scorebook and I got sad. I didn't want to use their app; I wanted to use mine. So I got to work.

This is going to be a retrospective of what it took to bring Scorebook back, culminating in the release a couple weeks ago of v1.5.

### Grab Game Image From Web

Scorebook has a feature that enables finding box art on the internet and attaching it to a game. I built that against a web API (Bing) that performed the image search and returned the results. That API disappeared, and its replacement was migrated to Azure. I spun up an Azure account and set up their image search API. Past me would have called it a day from there.

Instead, with my experience I've gained over the past few years, I knew that if I hit my own API I could prevent this from happening to future versions of the app. I've been playing around with the [Vapor framework](https://vapor.codes) (which is written in Swift) to power the web service, and using their [cloud service](https://vapor.cloud) was able to bring my API online pretty easily.

The most interesting part of this was thinking through authentication. I don't store any user data – don't want to, and don't plan on it– but wanted only my app to be able to talk to the service. I also know that baking a key into the app is fragile. So I utilized the public database provided by [CloudKit](https://developer.apple.com/documentation/cloudkit/ckcontainer/1399166-publicclouddatabase?language=swift) to store the record. On launch the app performs a search for the key, which it then uses to authenticate to the server. The server likewise has the key and uses a middleware class that I wrote to validate the key sent as part of the request. I know it's not bullet proof but it gets the job done for what I need and I'm happy with the solution.

### On Memory and Images

When a fried of mine was using the app after it first launched he told me about a crash he saw when taking pictures during a gameplay. Being the young developer I was, I looked at Crashlytics, didn't see anything, and moved on. It wasn't until later that I learned that out of memory crashes aren't picked up by crash reporting tools other than Apple. I decided to look into it and hunt it down if indeed it was a problem. (Narrator: It was)

I went through and audited all the places in code where I display an image. Save searching for a game image, all images are loaded from files on disk (though that did change in this version from the files being binary blobs in Core Data). When I needed to show a picture I'd simply create a `UIImage` from the data and put it in an image view. Done and done. Except that leaks memory like crazy and can result in the system killing the app. Whoopsie.

Thankfully there were a couple great guiding resources that came out this year: [WWDC 2018 session 219](https://developer.apple.com/videos/play/wwdc2018/219/) (presented by Xcoder Kyle Sluder – once an Xcoder always an Xcoder), and a [very helpful post by Jordan Morgan](https://www.swiftjectivec.com/optimizing-images/) going into some extra detail on how to get it done. 

I set about adding a downsampling method like the one at WWDC, and had to defer actually rendering the image until I knew the frame that it needed to fill. Sometimes it's a small circle representing a person's image, sometimes it's a picture taken during a gameplay. I don't make assumptions about that until I know all the conditions I need. Images are stored inside of the `<Container>/Documents/Pictures/<ImageType>` directory, so knowing the image name (which is stored in the Core Data entity) and the type of the image I need, I could assemble the URL to the image file on disk.

From there I hand it, along with the size needed, to the downsampler, and it hands back the scaled image. I had to get rid of essentially all of my `[UIImage imageWithData:]` calls in favor of this new method. It was a fair bit more work than I thought it might be, but wound up saving a ton of memory so it's completely worth it. Plus it was the right thing to do.

### Miscellaneous

Those are the two things that took the longest to get done, and there are a handful of other things that made it in to this release from times over the last few years when I did some concentrated work on Scorebook. The big ones were architectural things like splitting up the main storyboard into multiple smaller ones, and refactors to have the app flow use coordinators.

I've also been modularizing things a bit as I'm working to get sync turned back on. We take that modular approach at Lyft and I really have enjoyed the benefits.

### Final Thoughts

One thing I wasn't expecting was easily slipping back into my old mindsets as I approached a problem that I had set aside for a while. I have to knowingly refuse to let myself get caught up into old habits, or think that a problem is too big. If it's too big it just needs to be deconstructed further until it's in manageable chunks that I can tackle one at a time.

I'm incredibly happy to have Scorebook back on the App Store. Bringing it back to life has been a lot of work, but I've been able to look back at the decisions past me made (good and bad), and apply some of what I've learned at my day jobs as well.

[Go forth and remember your games!](https://taphouse.io/scorebook)
