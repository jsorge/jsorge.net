---
layout: post
title: View Controllers Make Crummy Navigators
date: '2018-05-02 04:49:36'
---

My fellow iOS developers, we have a problem. We’ve been led astray by Apple. Don’t get me wrong, iOS is great. I love writing code in Swift (and Objective-C!). I’m a fan of Xcode too. And UIKit really makes a lot of really powerful things quite easy. But allow me this hot take: View controllers should never have to deal with navigation.

There’s a long running joke about MVC actually standing for [massive view controllers](https://duckduckgo.com/?q=massive+view+controller&t=osx&ia=qa) and navigation is a key reason. Even a relatively simple view controller with a couple of possible destinations, using storyboards and segues, needs to implement methods that could grow to be dozens of lines long and end up knowing about the implementation details of view controllers that come after them.

What are we to do? There must be some way that can keep our view controllers clean of navigation _and_ doesn’t fight the UIKit frameworks completely, right?

There is!

If we treat view controllers like functional pieces, we can expose a small interface to interact with them and use delegation to get stuff out. Here’s a trivial example:

```
protocol PeopleViewControllerDelegate: AnyObject {
    func personSelected(_ person: Person, from viewController: PeopleViewController)
}

final class PeopleViewController: UIViewController, UITableViewDelegate {
    var delegate: PeopleViewControllerDelegate?
    private var people: [People]?

    func configureWithPeople(_ people: [Person]) {
        self.people = people
        // fill a table with people
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // find the person
        self.delegate?.personSelected(person, from: self)
    }
}
```

This view controller (while grossly incomplete) gets configured with an array of people that will fill a table view. Tap on a row and the view controller’s job is done. It hands off the person to its delegate. What happens next is out of its hands. Perhaps we’ll show a detail screen, but maybe it’s just an API call and this view controller gets dismissed. Our `PeopleViewController` doesn’t know, and doesn’t care. Kind of great, right?

This begs the question of _what_ exactly is the delegate? I’ve come to really like the [coordinator pattern](http://khanlou.com/2015/01/the-coordinator/) myself. I like having objects whose specific responsibility it is to manage the flow of my app (or just a given object’s slice of the app).

There are some things that you’ll have to give up, of course. Storyboard segues are a non-starter in this pattern. This means that there are large swaths of sample code (Apple’s and others’) that you’ll need to learn to either ignore or translate into this pattern.

So let’s trim down the size of our view controllers. Let’s narrow their scopes of responsibility, and in turn we’ll get code that is more maintainable and easier to reason about. I think we will all be better off.