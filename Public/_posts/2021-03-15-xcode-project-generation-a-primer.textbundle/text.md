My first day at Lyft a few years ago delivered quite a shock: Our iOS repositories didn’t have Xcode projects checked in. Instead, we relied on manifest files that would define each of our targets and handed those to a tool which would create the projects for us. While this seemed really weird to me at first – and admittedly took some getting used to – I quickly game around to this being a great way to work. It shifted the source of truth in the Xcode project from the Xcode project file itself to these manifests as well as the arrangements of files on disk. And there was the added benefit of no more conflicts to resolve when merging project changes from the main branch.

At Zulily I have been able to bring the same philosophy (with a few twists, but more on that another time). Our project was started in 2012 and we still have much Objective-C laying around. Since ours is an established project I had to answer the question: Where do I start?

My aim in this post is to answer that question with a few helpful tips that I picked up along the way (with a shout out to the [Tuist docs](https://tuist.io/docs/usage/get-started/).

### Extract Your Build Settings

The first step in de-emphasizing your project file is to remove as much from it as possible. The lowest-hanging fruit are build settings. Thankfully the wonderful [BuildSettingsExtractor](https://buildsettingextractor.com) by James Dempsey is there to help you out. It will examine each target you have and create xcconfig files for each of your target configurations, as well as a shared file that each configuration file imports.

Once you have these files extracted you can attach each file to its correct target configuration using Xcode. I’d even suggest taking this one step further and having a script run to verify no build settings [creep back in](https://github.com/olofhellman/VerifyNoBS) to your project file.

### Clean Up Your Files

The manifest files I described earlier point to globs of files in your repository which will be come sources & resources for Xcode to assemble your targets in their final product form. If you have files strewn all about the repository then it will be difficult to pinpoint exactly what files are contained in any given target. It’s a good idea to determine how you want your target directories to be organized at the end of this project, and start implementing that _now_.

Here’s how I went about this cleanup at Zulily:

0. The first thing I did was to run the excellent [Synx](https://github.com/venmo/synx) tool on our repo. Our project file version was old enough that Xcode did not move files on disk when we moved them in the project, so things had gotten way out of whack. This tool ensured that we were working with files in their proper places from the start (for the most part).
1. **Using Xcode** I created the directory structure for each target and started moving files & resources around. Most of our files & folders were a single level deep in their target’s hierarchy so I started by creating the top level `Sources` directory and moving our sources in there. I would then look back in the Finder and see what files were left over. 95% of the time I could just delete them straight away – if Xcode didn’t know about them then they weren’t affecting our app.
2. Start building the project manifests in parallel to the file reorg. By building the manifests for each target (defining where to find the sources, resources, target build phases, etc) I could ensure that at the end of the day I would have a buildable project from our collective manifests.
3. One of the big things I got from the Tuist docs was to order my operations by target dependency count. I started with targets that had 0 dependencies, got their files organized, and was able to have a project and a building target right away. This helped me gain momentum in the project.
4. Once a target was organized, able to build using the generated project _and still in my Xcode project_, I made a PR changing just that target in our main branch. I wanted to keep all this churn as incremental as possible rather than dumping a PR that touched literally every file in our repo. So instead of one massive PR I had many smaller (but still big) PRs that landed in sequence before the one which generates our project file landed.

### Evaluate Your Options

There are a couple of main tools that can be used to make Xcode project files (without also affecting things like your build system): [XcodeGen](https://github.com/yonaskolb/XcodeGen) and [Tuist](https://tuist.io). I’ve now used both, and each has their merits and drawbacks. For Zulily’s project I went with Tuist. The main reason was because of its support for Test Plans (XcodeGen’s support hadn’t landed yet). For my personal projects I’m still using XcodeGen though and don’t have any real plans to make a change at this point. Here’s a rundown of some benefits & drawbacks that I’ve found for each:

**XcodeGen**

* ↔️ Manifests are all defined in yml or json files.
* ✅ Super fast project generation.
* ✅ Templates greatly enhance flexibility & reuse of things like target definitions.
* ✅ Lightweight app built in Swift with binary releases available for download. It’s super easy to integrate into your repository.
* ❗️ Manifests only have so much flexibility because they aren’t defined in code.
* ❗️ Errors can be hard to debug (yml is a good but somewhat picky format).

**Tuist**

* ↔️ Manifests are all written in Swift.
* ✅ It’s extremely opinionated but uses those opinions mostly helpfully.
* ✅ You get a framework called ProjectDescriptionHelpers which lets you add whatever helpful code or additions you want to make your manifests as simple as possible.
* ✅ There’s a fantastic community building up around it.
* ✅ Can bundle itself and all of its dependencies with one command, making pinning to any given version (or commit hash) super simple.
* ❗️ Generation is much slower than XcodeGen. This is because Tuist is attempting to do more for you, but sometimes I found that it gets in the way and I have to work around it when the Tuist way of doing things differs from my own.
* ❗️ Errors can also still be hard to debug, because you can’t (currently) pause the debugger when running the manifest generator.

It’s hard for me to prescribe which tool is right for your particular environment. I’ve been an XcodeGen user for a few years now – that’s what Lyft used – and it’s been great. I’ve been diving more into its advanced features and putting more weight on my manifest files and it doesn’t bat an eye. My project generates incredibly fast. My personal projects will likely stay on XcodeGen for a long time.

I’ve also found Tuist to be really nice to work in, and in a future post I want to talk about my Tuist-centered approach to how I’m breaking the Zulily codebase into modules and what that API looks like that I’ve built out in Tuist. I’ve found that having running code, being able to define functions, and the extra things that Tuist gives us at Zulily delivers the power of something like bazel’s BUILD files without the hassle of switching build systems. It’s been the right call for Zulily.

### Wrapping Up

Putting in some work at the beginning of your project can pay major dividends. By slimming down your existing project file, and getting your repository structure in place before (or while) building out the manifests to generate your project you are setting yourself up for success. I hope this has been a helpful primer to get you started down the road of generating your Xcode projects!