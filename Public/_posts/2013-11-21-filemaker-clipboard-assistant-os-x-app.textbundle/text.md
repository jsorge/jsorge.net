---
microblog: false
title: FileMaker Clipboard Assistant - OS X App
layout: post
date: 2013-11-21T10:17:00Z
staticpage: false
---

#### The Problem
I’m refactoring an old database tool that I built 3 years ago to normalize the weird price lists we get for importing into our products catalog. I built it as one of my first reintroductions into FileMaker and didn’t have any standards or close examination into what I was doing. This tool is still necessary for our business but I wanted to bring it up to date with my new standard practices and naming conventions. The issue is that I updated table occurrences and this broke all of my “Import Records” script steps.

#### My Solution

I know that FileMaker uses an XML backed scheme to drive its scripts, tables and fields. There are apps like [Clip Manager](http://myfmbutler.com/index.lasso?p=422), but that’s a pretty spendy app and I don’t know how often I will use it to justify the price to my boss. Not to mention, I’ve been learning to build Mac apps and as a developer this presented a great challenge.

I built a simple Mac app that will import the contents of the clipboard, run some replace rules and copy it back to the clipboard. The trick is that FileMaker uses a special hidden clipboard type, which is why you can't copy a script step and paste it into a text editor. So you have to get the type of the pasteboard using the `NSPasteboard types` method. I
set this as a property on my document class so that the copy back action knows where the contents came from.

Initially I created the app to do some hard-coded find and replaces but I spent a little time updating it and adding a Core Data stack as well as a table view. It will now run through the table sequentially, doing a find and replace and you can save multiple documents. So you could have a template to convert a script step and another to convert a table occurrence.

#### Future Versions

Im thinking that I want to paste in with a tidied version of the XML so that its easier to identify whats going on, as well as some error checking to make sure that both the search and replace rules are populated. Im giving links to the binary and the repository so you can look over the code if you wish. Its not pretty right now, but its functional.

####Files
* [Binary](https://s3.amazonaws.com/jsorge/alfred/FileMaker%20Clipboard%20Assistant.zip)
* [Repository](https://bitbucket.org/microk12/filemaker-clipboard)
