---
microblog: false
title: URL Schemes and UIViewControllers
layout: post
date: 2014-03-21T07:00:15Z
staticpage: false
---

Our last 3 assignments in class this quarter have all been building on each other to create a photo list and location tagging app. It's really lightweight, and this last part of it involved adding a URL scheme for extra credit.

Part of it led me to posting this tweet:
> Why don’t UINavigationController pop and push methods have completion blocks?

I have a URL that can be activated to open the app and delete all the photo entries. What I wanted to do is make sure that the UI was in a good state for this to happen so that deleting a photo while you might be viewing that photo won't cause any catastrophes.

I haven't implemented anything like this before but I'm happy with my solution. 

First, I'm calling the method on my view controller using NSNotificationCenter. In the init method I register for the notification, and my header file broadcasts a string constant that names the notification.

In my app delegate, when the application:openURL:sourceApplication:annotation method I verify the URL and post the notification, which my view controller will pick up. Yes, I have to import my view controller so that I can access the string, but I figure that

Now the tricky part: get the current view to a usable state before prompting the user to delete their photos.

The app can exist in 4 different states: the main photo list, adding a photo from the image picker, attaching a location to a picked photo (but not yet added to your list) or viewing a photo in the map or it's details.

So I wrote a method that will get the view back to the photo list with a callback block to handle the next action after getting the view onscreen.

What made me smile about this technique is that it was the first time I used a block as a parameter and it worked perfectly. I just called `performBlock` on the main queue (since I'm performing UI code and that has to happen on the main thread).

Here's what that method looks like:

```language-objectivec
- (void)bringSelfToMainViewWithCompletion:(void(^)())completion
{
    if (self.navigationController.visibleViewController == self) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
    } else {
    	id presented = self.presentedViewController;
        if ([presented isKindOfClass:[UIImagePickerController class]] || [presented isKindOfClass:[UINavigationController class]]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
            }];
        } else {
            [UIView transitionWithView:self.navigationController.visibleViewController.view
                              duration:0.75
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self.navigationController popToRootViewControllerAnimated:YES];
                            } completion:^(BOOL finished) {
                                [self.navigationController setViewControllers:@[self]];
                                [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
                            }];
        }
    }
}
```

I'm interested to hear what other techniques there are for this kind of thing. It's my first shot and I'm sure there are other optimizations I could make. I don't know how I would handle a more complex navigation structure, but that's a problem for another day.

Next quarter starts in 2 weeks, and I'm really wanting to take a more [Brent Simmons-type](http://inessential.com) approach and blog what's going on in real time. Hopefully I have something useful to contribute.

If you're interested in the code from this project it's available here: [https://github.com/jsorge/CP125_HW-6-7-8](https://github.com/jsorge/CP125_HW-6-7-8).