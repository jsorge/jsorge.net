---
microblog: false
title: 'Xcoders talk: Don''t Fear the Project'
layout: post
date: 2019-08-14T15:49:14Z
staticpage: false
shortdescription: Some notes on my talk about Xcode Projects from the August Seattle Xcoders meetup.
filename: 2019-08-14-xcoders-talk:-don't-fear-the-project.textbundle
tags: []
---
Last week I gave a talk at our [Seattle Xcoders](https://xcoders.org) meetup group. The topic was Xcode projects and I discussed the things that make up a project (targets, schemes, etc) and dissected project files themselves a little bit. The meat of the talk was then going through using [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate Xcode projects programmatically so you can stop checking them in to source control. This is a talk I've wanted to give for over a year and I'm glad I finally got around to it.

The really cool thing that happened (which I was not expecting) is the level of questions & discussion after I wrapped up the talk. I've not seen as many questions come out of a talk as this one had. That can generally mean 1 of 2 things. Either 1) I could have done better at explaining things or 2) The topic generated that much genuine interest in people. From what I heard it's more the latter than the former though there are definitely areas that I could have expanded on.

Many of the questions that arose came in the area of using flags for individual files in generated Xcode projects (think of toggling ARC on a per-file basis back in the day). I didn't know if that was possible, since I mainly use the file system to organize my sources and tell XcodeGen to grab files from the correctly organized folders. Turns out it is possible to do fancy things like define custom regexes to include certain files and then apply build phases or compiler flags to those matched sources ([documentation](https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#sources)). XcodeGen is even more powerful than I thought originally!

Were I to give this talk again at a conference or something I'd probably expand it to include a demo where I take an Xcode project that's already existing and adapt it to use XcodeGen, but for this talk I wanted to avoid live coding. The main reason that I delayed giving the talk at all was because I wanted to build a conversion tool. But in the end when I tried it out it was both harder than I was expecting to be, and I didn't think that building a complicated tool for someone to run once and move on from was a great use of my limited time.

We recorded video for the talk and I'll post a link when it's ready. For now, the [slides can be found here](assets/dont-fear-the-project-slides.pdf).
