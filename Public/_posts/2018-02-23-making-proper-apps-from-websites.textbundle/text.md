---
microblog: false
title: Making Proper Apps From Websites
layout: post
date: 2018-02-22T16:00:26Z
staticpage: false
---

While at zulily, I used to have [JIRA](https://www.atlassian.com/software/jira) and [GitLab](http://gitlab.com) inside of wrappers provided by [Fluid](http://fluidapp.com) instances. Now that I’m at Lyft I’ve done the same thing with JIRA, but we use [GitHub](https://github.com) instead. For the longest time I would take links sent to me for those pages and paste them into the apps by hand since clicking on the links would open my browser instead of the app silos that I hand-crafted for these sites.

Well today [@jackbrewster](https://twitter.com/jackbrewster) taught me about something great that takes this to another level. The app [Choosy](https://www.choosyosx.com) will let me route URL clicks to whatever app I want. I set up rules in Choosy to look at the web address that I clicked and now have it routing my JIRA and GitHub links to their proper Fluid apps. It’s wonderful!

My default browser is Safari, I keep Chrome around as my Flash ghetto (and now only it can be used for [Meet](https://meet.google.com) as well). I can use Choosy to send the Hangouts/Meet links straight to Chrome as well. This makes everything feel completely seamless.

One other tip I got from Jack was about 1Password. Fluid instances don’t support it directly but you can invoke the global 1Password mini, find the site you need, and press  ⌘⇧C to copy to the clipboard. Focus will then switch back to your Fluid app and you can paste the value in there. I was using the mouse to do this previously. This way sure seems a lot better.