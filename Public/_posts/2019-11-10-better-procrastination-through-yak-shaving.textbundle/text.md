The first step in any new project is to create the project (more on what the project is tomorrow). That's where yesterday's yak shaving adventure comes in.

<iframe src="https://giphy.com/embed/HCQ4noVjpvFwA" width="480" height="361" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/nutshell-HCQ4noVjpvFwA">via GIPHY</a></p>

The app I'm starting in on is for the Mac. I have a [project template for iOS already](https://github.com/jsorge/ios-project-template) but it didn't support a Mac app. I have really come to like using [Xcodegen](https://github.com/yonaskolb/XcodeGen) to generate my Xcode files and not check them in to source control. So I decided to update my template to support a Mac app.

Instead of starting with the assumption of always wanting a Mac app, I updated the `new-module`(https://github.com/jsorge/ios-project-template/blob/master/tools/new-module.swift) command to output a framework, an iOS app, or a Mac app. This will let me have maximum flexibility for my project. I went about it by creating a shell project from Xcode, extracting the build settings using [James Dempsey's excellent Build Settings Extractor](https://github.com/dempseyatgithub/BuildSettingExtractor), and modified some files to tokenize the name based on input.

I'm pretty happy with the result, even though I've been churning over my new app idea in my head. This was a fun distraction, but now the real work will begin.
