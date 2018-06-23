---
layout: post
title: Help Make This Code Better
date: '2016-04-21 19:44:50'
---

I’m working on a chunk of code that validates whether or not an array of NSURLQueryItems contains a URL whose host is one of our email domains. The main idea is that when a link comes in via universal links, we need to attribute the click for our tracking. However, if we don’t know how to handle the link explicitly, it will get transformed into an internal URI that bounces to the mobile web (don’t fixate on this part, the main idea is that I need to search through the query items of the URI).

I have an array of our email domains, and I need to loop through both the query items of the URI, and see if the value of each contains a domain that we know about. If it does, I can abort the reporting operation.

I think my favorite thing about this code is naming the `do` block so that when I get a match , I can break the outer most part of the scope. That’s really great, and I don’t have to track state with a `BOOL` variable. I really want to avoid the number of loops that I’ve got going on if I can.

```swift
//: Playground - noun: a place where people can play

import UIKit

//The URI that we are going to be bounced over to
let uri = "zulily://action.show/web?url=http%3A%2F%2Ftrksmail4.zulily.com%2Ft%2FccgabBLXLjCAA01dBLXLjaabaaaaa%3Fo%3Dqauijqoh_5orcrs.iis%26Y%3Dqauijqoh_5orcrs.iis%26f%3DHxy%26r%3D%26x%3Dbznv%3A%2F%2Fq2q.5orcrs.iis%2FUvjEXuqtfuUj%3FY3n%40oX%3D%26sUv%40cj%3D&external=1"

//The email domains that we use
let domains = ["trksmail4.zulily.com", "trksmail5.zulily.com", "trksmail6.zulily.com", "trksmail7.zulily.com"]


//Go through the array of query items for the URI and see if any of them include an email domain in their value
//This would indicate that we don't want to hit the email server to attribute click throughs (that will be done when the user is bounced to mobile web)
emailTracker: do {
    if let comps = NSURLComponents(string: uri), items = comps.queryItems {
        for item in items where item.value != nil {
            for domain in domains {
                if item.value!.containsString(domain) {
                    print(item.value!)
                    break emailTracker
                }
            }
        }
        
        /* Perform network operation */
    }
}
```

I’d love to hear ways to make this better!