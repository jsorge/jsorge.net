---
layout: post
title: Separating CoreBluetooth and View Controllers
date: '2014-04-29 14:10:42'
---

One of the things we did early this quarter was go over Core Bluetooth. In the class demos and in all the materials I've seen online dealing with these classes the logic for handling the Bluetooth events is put inside the view controllers responsible for displaying the  UI. This felt like a bad practice to me.

For my homework I implemented separate classes for central and peripherals. I built 1 app that could fulfill both roles (on different devices) using these classes and it worked!

What I like about this practice is the separation. I can move them without having to reimplement every single time I need them in a view.

What I'm not fond of is still needing delegates so there are a few layers of callbacks. There is definitely some reimplementing of methods in whatever class is calling these.

I haven't tested these much yet so they're definitely not production ready.  The files can be found here: [CoreBluetooth helpers Gist](https://gist.github.com/jsorge/11390537)
