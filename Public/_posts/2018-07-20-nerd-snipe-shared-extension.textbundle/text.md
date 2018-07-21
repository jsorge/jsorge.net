---
filename: 2018-07-20-nerd-snipe-shared-extension
layout: post
title: Nerd Snipe: 2 Apps, 1 Extension
date: '2018-07-20 22:28:25'
---

I’m working on a project for Lyft that will bring in a new app extension to both our passenger and driver apps. The functionality between both apps is going to be identical so sharing code should be maximized. I am trying to figure out how to get it working to make just a single extension that can be used on both apps. This is more difficult than you might imagine, because [extensions can be fiddly](https://developer.apple.com/library/archive/technotes/tn2420/_index.html). They need to share the same version and build strings, and building in Xcode revealed this hidden gem:

> Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier.

Ugh. This begged the question of how I could possibly get it to work. Off to chase a snipe. Let’s start with a [sample project](https://github.com/jsorge/shared-extension), shall we?

I’m no shell script wizard, but it seemed that a run script build phase should do the trick. It needs to run in the host app prior to anything else happening. This means it’s the second build phase (dependencies always need to be built first). Here’s what I came up with:

```bash
#! /bin/sh

APPEX_DIR=$BUILT_PRODUCTS_DIR/SharedExtension.appex
INFO_PLIST=$APPEX_DIR/Info.plist
suffix=richmessagenotification

if [ "$IS_EMPLOYEE" = YES ] ; then
bundleID=io.taphouse.EmployeeApp.$suffix
shortVersion=$VERSION_EMPLOYEE
version=$VERSION_EMPLOYEE.$BUILD_NUMBER_EMPLOYEE
else
bundleID=io.taphouse.CustomerApp.$suffix
shortVersion=$VERSION_CUSTOMER
version=$VERSION_CUSTOMER.$BUILD_NUMBER_CUSTOMER
fi

plutil -replace CFBundleIdentifier -string "$bundleID" $INFO_PLIST
plutil -replace CFBundleShortVersionString -string "$shortVersion" $INFO_PLIST
plutil -replace CFBundleVersion -string "$version" $INFO_PLIST
```

I’ve extracted out the short version and build values as build settings in each main app target and those get funneled into the script. In this sample I’ve hard-coded each app’s bundle ID to prefix the extension, but at Lyft these are build settings as well[1]().

I’ve got a build setting in one of my apps indicating what kind of app it is (in this case that is the `IS_EMPLOYEE` setting). Checking that will tell me the environment the script is running in. I setup 3 variables for each app and replace their values in the extension’s _already built_ Info.plist file. This is important, because it’s too late to change the file in my source directory.

So now I’ve got an Info.plist file with all the proper values. Each app will build and run in the simulator. 🎉!

But we don’t write apps for the simulator. We write them for phones. Let’s give that a shot.

> 0x16b257000 +[MICodeSigningVerifier _validateSignatureAndCopyInfoForURL:withOptions:error:](): 147: Failed to verify code signature of /private/var/installd/Library/Caches/com.apple.mobile.installd.staging/temp.KCRuNY/extracted/EmployeeApp.app/PlugIns/SharedExtension.appex : 0xe8008001 (An unknown error has occurred.)

Dang. Looking at the build steps for my extension reveals that there’s a code signature step at the very end and changing the Info.plist afterwards seems to break that signature. So how do we get this done?

Well, I don’t know. My best guess is that I might need to figure out how to re-sign the extension after manipulating its Info.plist. Is this possible? Reasonable to do?

What I’ll probably wind up doing is have individual extensions (one for each app) and a shared framework that backs each. I think it will be easier to get going and more resilient to changes in tooling in the future.

Unless you’ve got a way for me to get this done… 🙂

[1](): Pro-tip: make good use of xcconfig files because editing this stuff in Xcode is a huge pain, not to mention the possible merge conflicts that could arise in your project file.