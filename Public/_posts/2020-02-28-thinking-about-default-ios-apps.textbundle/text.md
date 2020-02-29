There's a report that came out [this week from Bloomberg](https://www.bloomberg.com/news/articles/2020-02-20/apple-weighs-loosening-restrictions-on-rival-iphone-music-apps) that says Apple is "considering" the idea of allowing users to pick third-party apps to be their default for things like email, music, and web browsing. This really does feel like a good thing for Apple to do, though I do laugh a bit at the "considering" word. If they are truly considering it then it's likely to miss iOS 14 which I imagine has been feature-locked for some time. The question is: what does setting a default app mean?

* In Messages, tapping an http or https link would presumably take you to the browser you've set as default. This could be Safari, Chrome, or iCab.
* Tapping a `mailto` link would open up your email app. There are plenty out there which could supplant the default Mail.app (which is what I use and personally find to be fine).
* Asking Siri to play some music could launch Spotify without having to add "with Spotify" to the end of your query.

And there are many other possibilites here that I won't bother listing. As a user I think the time is definitely right for Apple to introduce a feature like this. But what about as a developer?

The big question that I have revolves around code that would normally put Safari in your app. The class to do this is `SFSafariViewController` and it literally puts a Safari view in your app. This allows for the system to use your content blockers and other installed extensions. It also locks the domain to the one provided by the developer when they brought it on screen.

If one of the benefits of setting your default browser to (let's say) Chrome so you have access to all the Chrome things all the time would it be jarring for a user to see Safari inside of their Twitter app when they tap on a link? Would Apple provide some kind of hook inside of `SFSafariViewController` to actually show the content of a third-party app like this? If I've purposefully gone and set Chrome as my default browser then I sure don't want Safari _ever_ getting in my way.

There's also similar code around `MFMailComposeViewController` for sending emails in apps (I use that in Scorebook) as well as `MFMessageComposeViewController` for sending iMessage or SMS messages. Would they allow users to pick their email or message client and slide up those experiences as well?

If Apple does allow these third-party apps then it will be the result of a mountain of work touching who knows how many parts of iOS. I'm excited to see what we get in iOS 14 come WWDC this year. We should be hearing logistical details about the conference in just a few weeks. 🍿
