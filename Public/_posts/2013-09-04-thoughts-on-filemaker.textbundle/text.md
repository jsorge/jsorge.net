---
microblog: false
title: Thoughts on FileMaker
layout: post
date: 2013-09-04T08:00:21Z
staticpage: false
---

In my day job I spend a lot of time building apps based in the FileMaker Pro ecosystem. I ‘ve been wanting to share some of my unstructured thoughts about the platforms and give some preview of things that I’ve built that I want to share with the larger developer community.

For the uninitiated, FileMaker Pro is an application that allows for easy creation of database driven applications. They include a good amount of templates (like contact managers, invoice tracking, etc). But the real power comes when you start customizing the interface to make it function like your own application. Over the past 7 months I’ve been doing just that at work and am about to release internally a new sales
application for our quotes, orders, contact management and many other things.

While it’s easy to get rolling with a simple application, naturally more complicated things are increasingly difficult. I’ve been spending a lot of time in Xcode in my free time as I develop my other programming skills and am really craving for some improvements in how FileMaker handles things. Here are a few of my wish list items.

-   Improve the calculation engine
    -   Make it work like a standard text editor. I shouldn’t have to worry about the undo command; that it will wipe away everything I’ve done when I just put a character in the wrong place
    -   Implement auto-complete for table occurrences and fields. You can validate the existence of said TO’s but can’t help me find the one that I want without going to my mouse. I don’t want to use the mouse if I can avoid it, since it slows me down. While you’re at it, you should also auto-complete functions.
    -   Code hinting. Solid black text doesn’t help me do my job better when I can’t identify things at a glance.
    -   Let me change the font. If I want to line everything up I should be able to because I’ve selected a mono-spaced font. Developers don’t want variable spaced fonts.

-   Scripts
    -   Give us the ability to type out our scripts. I know that this is really difficult (maybe impossible) to accomplish but it would be a huge step up as a development tool. Like I said before, the mouse slows me down especially when I can’t search script steps
    -   Allow undo of a a mistake in the script editor. I can’t use the undo command to go back a level of two while working on a script. I can either save and manually undo, or close the script without saving. That is a joke.
    -   Some way to diff/merge scripts. This is part of a larger request for version control, since there is no way to handle versioning of my files. Git is a remarkable tool that is rendered less helpful because of the way files are packaged. I should have a way to track changes made to files, roll back or try something out on a different branch.

Those are my biggest day to day frustrations with the platform. Because there are no frameworks to speak of, and very little in the way of shared code, I’ve had to create things that frameworks would give me for free. I’ve builds my own navigation controller, my own unwind segue controller, and my own centralized code to handle uploading to and deleting from S3. I plan on sharing some of these things on modular filemaker when I have the time to generalize them.

The biggest thing I think FileMaker needs to talk about is their direction. What are they and where are they going? When they first started their biggest competition was Excel, and they were glorified spreadsheets. Now things are very different. We live in an age of mobile and apps. Last year, the FileMaker Talk podcast featured John Sindelar and Todd Geist [talking about this very thing before DevCon.](http://filemakertalk.com/media/12_fmt069_building_apps.mp3) More than a year later, we don’t have clarity about their direction.

As it stands right now, FileMaker will never be able to produce the kind of quality apps found in a native platform. They don’t have access to low level Apis that make building native feeling apps. I doubt you’ll ever see parallax in an iOS 7 FileMake app, let alone gestures. But what they can do is easily spur the creation of little helper apps that let you get things done.

I hope that FileMaker will have things to say in the near future, but I wouldn’t count on it. We probably won’t get a new release until early ish next year. 2 years between releases is too long, especially in this day and age. FileMaker is a good tool for sure, but there’s still much work to be done.

What do you think? Sound off on Twitter or in the comments.
