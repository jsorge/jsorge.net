---
filename: 2019-01-23-mixed-language-framework.textbundle
layout: post
title: Mixing Swift and Objective-C in a Framework
date: '2019-01-23 19:05:21'
shortdescription: It's quite possible to use both Swift and Objective-C in a framework target. But it's not without some sharp edges. Let's go exploring together.
---
If you've worked on an iOS app that has both Swift and Objective-C code you're likely well familiar with the rules for getting the two languages to talk to each other. A bridging header here, some `@objc` declarations there, and you're probably good to go.

But the rules change a little bit when you want to start breaking your code up into frameworks and suddenly there's no bridging header. So how are you supposed to get your mixed-language framework target working anyhow? Fear not, you've come to the right place.

For this example let's say we have a language learning app called BiLingual, and it has a framework target called LanguageKit.

### Setting Things Up
The framework target needs to be configured to build as a module (using the `DEFINES_MODULE` build setting). It also needs to then define a module name (the `PRODUCT_MODULE_NAME` build setting). Usually you won't have a custom name, but that build setting is what you'd use if you want to.

### Objective-C into Swift
Your Swift files that belong to the your framework target implicitly import the target. Where app targets use a bridging header to talk to Objective-C code, frameworks rely on the umbrella header – `LanguageKit.h` in our case. The umbrella header imports the headers you want to be made public like this: `#import <LanguageKit/Language.h>`. This style of import is a modular import.

Any header imported into the umbrella header can now be seen by Swift files belonging to your framework target. Sweet!

### Swift into Objective-C
Like apps, frameworks rely on a generated header to expose Swift code to Objective-C. In our app we would import its generated header like so: `#import BiLingual-Swift.h`. But, in our framework files we need a modular import like this: `#import <BiLingual/BiLingual-Swift.h>`. Please, please, please only import these generated files in your implementation files. Importing them into headers is only asking for trouble.

From here the standard rules apply. Your Swift classes need to be `NSObject`s and members need to be decorated with `@objc` in order to be seen by Objective-C. The one other thing to note is that the Swift types need to be `public` in order for visibility to Objective-C. I honestly don't know why this is at the moment. I'm hoping that someone smarter than me ca point me to the reasoning for this. If you know, please [drop me a line](https://jsorge.net/about).

### Private Objective-C into Swift
If you're like me, you're a stickler for having clean API boundaries. This means you may have some Objective-C classes that you don't want framework consumers to see but your Swift files might need them. Thankfully there is a good way to do this. You'll create a special module that is only visible inside the framework. Don't worry though, it's not as intimidating as it sounds.

First, in your framework's root, create a file called `module.map`. I don't know why it has to be this exact title, but it does. Here's its contents:

```
module LanguageKit_Private {
    // import your private headers here
    export *
}
```

We're making a module called `LanguageKit_Private`, and importing our private headers into it. There an extra build setting we'll set for this to work: `SWIFT_INCLUDE_PATHS = $(SRCROOT)/LanguageKit`. This tells the build system to look for additional module map files. From there in our Swift code, we can `import LanguageKit_Private` and the headers imported there are now accessible by Swift. 🎉

### Wrap-Up
We've seen how to import public and private Objective-C into Swift, and public Swift into Objective-C. So go forth and worry no more about mixing your framework target languages!
