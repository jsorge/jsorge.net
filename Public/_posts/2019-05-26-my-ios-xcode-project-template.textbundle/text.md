---
microblog: false
title: My iOS Project Template
layout: post
date: 2019-05-27T05:14:45Z
staticpage: false
shortdescription: Talking about my iOS project setup
filename: 2019-05-26-my-ios-xcode-project-template.textbundle
tags: []
---
Like many of my fellow iOS developers, I often find myself starting little projects here and there. Also like my fellow iOS developers, I have developed a preferred project structure. This structure has changed quite a bit recently as I've been exposed to a different way of doing things at Lyft. We have a highly modularized codebase and I quite like that methodology. I dipped my toes in the many framework waters in my time at zulily but what we have at Lyft goes well beyond that.

As such in my personal projects I have incorporated additional modularization and automation. My goal with this post is to peel back the curtain a little bit and give you some ideas on how you might be able to use modularization to create clean boundaries between code in your project.

To kick things off, I've published my [template code on GitHub](https://github.com/jsorge/ios-project-template).

I really like using commands via a Makefile to run automations, and further from there my aim is to have a project as self-contained as possible. What I mean by that is I don't want to rely on Ruby gems or Python modules managed by a central system on my machine. I freely admit that this is because of my ignorance to how those environments work. There have been great tools built on those platforms. But, like [Orta Theroux](https://twitter.com/orta) wrote on the Artsy blog, I agree that [it's time to use Swift Package Manager](https://artsy.github.io/blog/2019/01/05/its-time-to-use-spm/).

It turns out that Swift is a really nice language to write tools in. For me, as one who hasn't fully grasped Ruby or Python for tooling (though I would like to eventually) being able to use Swift to build some automation has been great. And now we can use SwiftPM to manage these dependencies for us. If you look at my [Package.swift](https://github.com/jsorge/ios-project-template/blob/master/Package.swift) file you'll see that I'm creating a "dummy" Swift module to get all the power of `swift run` in the Makefile.

Make is a super old system, and I had never used it prior to joining Lyft. And I gotta say, I love it. It's a great central place to run commands to do work on my project. To add a new module, I run a script by calling `make new-module`. The script asks for the name of my module and goes about creating some template files and linking it in to my app.

## Secret Sauce

To be honest, I've somewhat buried the lede here. If you glance over the [.gitignore](https://github.com/jsorge/ios-project-template/blob/master/.gitignore) file you'll see an entry for `*.xcodeproj`. Yep, I'm ignoring Xcode project files. This is because I'm using a tool called [XcodeGen](https://github.com/yonaskolb/XcodeGen) to create my project files using yaml definitions in my repo.

I love this.

I love that I don't have to worry about Xcode project conflicts in git merges (of course on side projects this isn't a big deal for me). I love that I can easily rename my project on disk and it's instantly reflected the next time I generate the project. I love that I can move a group of files around, regenerate, and have my new file group or module instantly.

My modules all live inside of a `Modules` folder stored at the repo's root. The `project.yml` file is what drives the structure of the resulting Xcode project. Each module has its own definition file, which helps keep the project definition file slim.

## Wrapping Up

I've been working through these pieces for over the past 6 months or so. When I got back in to Scorebook I adapted the structure, and over a couple of other small projects I've started up I've built out the shell that you see in my GitHub project. I hope some parts of it are helpful for you in some way.

As always I love talking about this stuff and am happy to answer any questions you might have. And, if you've got a better way that I'm missing the boat on please let me know. Let's help each other get better 🙂
