---
layout: post
title: My First Swift Package
date: '2018-05-07 04:41:39'
---

I’m embarking on phase 1 of my [blog rethink](https://jsorge.net/2018/04/15/reconsidering-my-blogging-setup/) and have decided that whatever I do next will use [the textbundle spec](http://textbundle.org/spec/) for file transport and storage. It will likely be some git repo or perhaps a Dropbox synced folder but all of the options that I’ve seen don’t strongly link a post together with assets. Textbundle solves that.

I think initially I might wrap Jekyll in something, so that the thing making the static site is really an implementation detail. The idea being that my server has an endpoint that would accept XML-RPC as well as micropub inputs, transform those to a textbundle and then build the static site from there.

So my first step was to download my posts stored on Ghost as well as my assets folder. I wanted a way to build textbundles out of these for easy migration. My first inclination was a Ruby script. I don’t know Ruby, so that became problematic from the start. So I turned to a more familiar language.

I made a Swift package called [textbundleify](https://github.com/jsorge/textbundleify), and the code is up on GitHub if you’re interested. It’s not polished in the slightest, but was a fun chance to try something new. It gets run from a directory containing Markdown files and if you give it a directory that contains pictures (or a directory of directories of pictures), it will embed linked images to the referenced textbundle.

I had to learn to use `Process` as well as `NSRegularExpression` (though I still don’t know how regular expressions really work). It was quite weird getting an `NSRange` for use on a Swift string, which only works on `String.Range` ranges. It was fun to put together over a few hours, and should do the migration trick I’m wanting.

The next step is to figure out the proper order of operations in converting textbundles (which Jekyll doesn’t support) to the structure that Jekyll does. I’ve still got Ruby learning on my horizon but at least there are [a couple](https://twitter.com/timothyekl/status/991913298747572224) of [wonderful souls](https://twitter.com/soffes/status/992078081857761282) who have offered some help to me if I need it.

Onward!