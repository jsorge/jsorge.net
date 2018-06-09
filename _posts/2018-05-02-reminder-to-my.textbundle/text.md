---
layout: post
microblog: true
audio: 
date: 2018-05-02 08:27:10 -0700
guid: http://jsorge.micro.blog/2018/05/02/reminder-to-my.html
---
Reminder to my future self: setting the `delegate` property on a `UINavigationController` subclass doesn't always do what I think it will do. In the case of the `MFMessageComposeViewController`, I needed to set the `messageComposeDelegate` instead.
