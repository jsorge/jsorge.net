---
layout: post
title: Ash on UIAlertController
date: '2014-09-08 14:47:09'
---

Ash Furrow wrote a really nice [introduction to the new UIAlertController class](http://ashfurrow.com/blog/uialertviewcontroller-example). His example showed an alert view and presented it with a text field. Cool. It can also do much more. The new class actually cannibalizes UIActionSheet as well, and that is very cool. I've been building an app that uses this new class (albeit in Objective-C since I'm a dinosaur).

Here's some actual code from my app, and I'll explain the wrinkle that now exists with action sheets:

```language-objectivec
UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak UIAlertController *weakAlert = alertController;
    __weak typeof(self) weakSelf = self;
    UIAlertAction *showCameraAction = [UIAlertAction actionWithTitle:@"Take Picture"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 typeof(weakSelf) strongSelf = weakSelf;
                                                                 
                                                                 [weakAlert dismissViewControllerAnimated:YES completion:^{
                                                                     [strongSelf.imagePicker showCameraInViewController:strongSelf];
                                                                 }];
                                                             }];
    UIAlertAction *showPickerAction = [UIAlertAction actionWithTitle:@"Choose Existing"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 typeof(weakSelf) strongSelf = weakSelf;
                                                                 
                                                                 [weakAlert dismissViewControllerAnimated:YES completion:^{
                                                                     [strongSelf.imagePicker showImagePickerInViewController:strongSelf];
                                                                 }];
                                                             }];
    [alertController addAction:showCameraAction];
    [alertController addAction:showPickerAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
```

It's all pretty standard stuff. You create the alert controller, and because it's just showing options to use the camera or image picker the button options are straightforward enough so I don't need a title or message. The wrinkle comes when I'm wanting to dismiss the alertController. Because it's a presented view controller (that seems to be doing presenting of its own), you need to have the alertController do its own dismissing. So you just need to create a weak version of it to call dismiss on, thus avoiding a nasty retain cycle.

So I'm a fan of this new class. Getting rid of the delegation that was needed for `UIActionSheet`s and `UIAlertView`s is great. It can make for long methods to put it all on screen, but the tradeoff is worthwhile. I am disappointed that Apple didn't go farther, though. Here are a couple areas where I would like more customization:

* My app uses a tint color for distinguishing buttons, but the action sheet doesn't respect it. Instead it's the standard iOS 7/8 blue. I think they should either respect the tint color, or allow you to set your own button color.

* I also want to use a custom font. There's no way to set the font of buttons that I can tell and I really don't want to do any hacky runtime things. This feels very similar to what [Dave and Brent are asking for for Vesper](http://inessential.com/2014/08/05/dave_on_ios_and_embedded_fonts). Seems like a very reasonable request. Maybe for iOS 9.

Overall the upgrade to `UIAlertController` is a big, big improvement. Thumbs up! 