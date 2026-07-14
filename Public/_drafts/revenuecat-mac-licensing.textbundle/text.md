I've been hard at work at a new Mac app called [Arborist](https://taphouse.io/arborist) lately, and one of the key decisions has been how to monetize it. Arborist is not an app that can be sandboxed, so putting it in the Mac App Store was never a real consideration (it runs commands entered by the user at arbitrary locations, which means sandboxing is right out). I had thought that I would make it a subscription app at first, but after a lot of thought I settled on a one-time version 1 purchase for $39 USD (just like the Software Days of Yore).

Then came the question: how do I do licensing on my own?

I know there are options out there like [Paddle](https://www.paddle.com), [FastSpring](https://fastspring.com), and [Lemon Squeezy](https://www.lemonsqueezy.com) that have worked for many apps like mine over the years. But I also wanted something simple for my users. Not to mention Apple Pay was a must-have. I've experienced friction more times than I can count when an app doesn't support Apple Pay, and every time it happens I am ever so slightly less happy with that app because of it. Customers are also more familiar with the smooth in-app purchase experiences provided by the App Store, and if I could achieve something that easy I wanted to do just that.

I also happen to be in a couple of Slack workspaces with the wonderful and friendly [Dave DeLong](https://davedelong.com). Dave started working at [RevenueCat](https://www.revenuecat.com) recently and he also has a passion for good Mac apps. He mentioned in a discussion about Mac app licensing that he would love to work with someone using RevenueCat's web SDK to power that experience – and my gears started turning.

After collaborating with Dave and some trial and error I was able to land on a somewhat novel – and simple – licensing implementation:
* RevenueCat serves as the source of truth for whether or not a customer is licensed.
* I create RevenueCat customer IDs from local iCloud identifiers (more specifically, calling `userRecordID()` on my `CKContainer` in CloudKit).
* When the user makes a purchase, they earn an entitlement that I look for in Arborist to grant them a license.

The big bullet of note there is the second one. I didn't want to have to spin up a licensing server to send out codes (much less have to store them), and I didn't want to have an email-based system. I wished for something simple like StoreKit but without using the App Store as a backend. I had to implement some kind of identifier that I could tie easily to a user and I wanted that to be as transparent to the user as possible. Hence, `userRecordID()` made complete sense. This also allowed for "license sharing" across all of a user's devices. So as long as a customer is logged in to the same iCloud account on a device that they made a purchase on, they'll be licensed for Arborist. I like the simplicity there. One other great thing about this is that I don't have to collect any personally identifying information about my customers directly. Stripe handles the payment process, and the iCloud's identifiers give nothing away.

The eagle-eyed among you may notice that my _entire licensing strategy_ hinges on the customer being logged in to iCloud. That's true for my 1.0. I don't think this is too big of a leap to make for a power-user app like Arborist. But I am working on a way to sign in to iCloud using the web so that folks who don't have iCloud set up on their machines can still buy a copy. That should land not super long after 1.0, but it does have some more moving parts to it and so I deferred it to post-launch.

## Setting it up

Getting these details in place was not immediately obvious to me, and I actually went down one path first before partly reverting and going another direction. At first I set up [RevenueCat Billing](https://www.revenuecat.com/billing), but that ended up being the route I didn't want to take. I had never heard the term [merchant of record (MoR)](https://stripe.com/resources/more/merchant-of-record) before and when I first did I didn't know it was something to care about (spoiler alert: it very much is). RevenueCat's product does not take care of being the MoR for me and thus would leave me on the hook for things like taxes and refunds. Being a solo developer embarking on my first direct-sale app this became a dealbreaker.

Thankfully Stripe has a service called [Managed Payments](https://stripe.com/managed-payments) which does handle this for me and even better is that RevenueCat plugs right into that system out of the box. So after doing some research it seemed the better way for me to go.

On the RevenueCat side, I will say that I am consistent in forgetting how to set up their chain of values. I have used RevenueCat for [Baseplate](https://taphouse.io/baseplate) and [Decoder](https://taphouse.io/decoder) previously but getting set up for Arborist definitely tripped me up.

1. In RevenueCat, create the entitlement that Arborist will look for to ensure the user is licensed for v1.x.

2. Add the product in my Stripe dashboard (ensuring it meets the criteria for managed payments).

3. Back in RevenueCat, I had to set up Stripe as a [web provider](https://www.revenuecat.com/docs/projects/connect-a-store). There's a box to check to [use Managed Payments when available](https://www.revenuecat.com/docs/web/integrations/stripe/stripe-managed-payments) that I had to check as well.

4. Create the RevenueCat product by importing it from my Stripe web provider.

5. Add a new offering which has the product inside with a lifetime duration. This will give me effectively a one-time purchase (there is a subscription "end date" that comes along in the SDK but it's for 200 years from now so if a customer needs a refund in 200 years I probably won't be able to help them).

6. That offering then gets a Web Purchase Link. This URL is what I then use to direct users to purchase in the app. It lets me specify things like the callback URL for when a purchase is complete.

I'm listing these steps as much for your information as I am for Future Me in the hopes that we can all do this a little smoother the next time 😀.

So the whole flow goes from Settings -> License -> Buy -> Safari -> Complete purchase -> Back to Arborist -> Refresh from RevenueCat -> Done. My hope early in the process was to avoid the Safari hopping, but doing so meant that I could not offer Apple Pay. This is a [known WebKit bug](https://bugs.webkit.org/show_bug.cgi?id=282078) from 2 years ago about Apple Pay not working in `WKWebView`. It's a real bummer because keeping the flow in the app was so smooth when I had it working that way, but I figured the friction of going to Safari to do Apple Pay and then hopping back was much less than having to input all your payment details in the app.

### An Aside on Taxes

One thing that has scared the daylights out of me in all this is sales taxes. I've never had to collect them before, let alone distribute them back to a government. Throw in dealing with non-US countries and that's even more terrifying. I was originally looking at [Stripe Tax](https://stripe.com/tax) to take care of things for me but something felt strange as I was exploring that route. I couldn't ever get it working in the sandbox environment and when I did some more research I was still going to have to file on my own. Thankfully I found Managed Payments and from everything I can tell, making Stripe my MoR puts all the burden of these collections and distributions on Stripe. So I'm happy to give them a few extra percent of each sale to handle that for me.

## Wrapping Up

I think this process has gone about as smoothly as I could have hoped, given that I have never sold a Mac app directly before. I've also never seen anyone attempt to use iCloud as a customer identifier. So there's still some nerves as I approach July 20, when I'm going to be launching Arborist. I know I've done my best to get here and if everything goes sideways on launch day, it's still just the first day of my journey selling this app.

I want to give a lot of thanks to RevenueCat's team, particularly Dave DeLong, Ed Shelley, and Delia Behr for being great partners in helping me get set up technically as well as on the content side with this blog post. I've long been a fan of RevenueCat's and for someone running an operation of my size I've yet to have to pay them a nickel.

I'll follow up post-launch with a retrospective for how things have gone and how this licensing plan has worked out. If it's as transparent as I hope it is I think this will work out nicely.