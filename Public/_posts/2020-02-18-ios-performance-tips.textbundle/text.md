[iOS Performance tips you probably didn't know (from an ex-Apple engineer)](https://www.fadel.io/blog/posts/ios-performance-tips-you-probably-didnt-know/)

> A common anti-pattern is leaving UITableView/UICollectionView cell labels populated with their text content when these cells enter the reuse queue. It is highly likely that once the cells are recycled, the labels’ text value will be different, so storing them is wasteful.

I could have pulled a few more gems from this super helpful post by Rony Fadel, but this first one struck me off the bat. I don't know how many times I have kept text in a label when I perhaps didn't need to. I _also_ didn't know that the right place to nil-out text in reusable views (`UI{Table|Collection}ViewCell`) is not in their `prepareForReuse()` method but in the delegate's `didEndDisplaying` method instead.

In larger projects with many cell class types this may take some thinking on how to get the message across to a cell type of "time to reset any labels you have". I know if I were still at zulily this would be something that I'd work to get in place as soon as possible, as I did a lot of really hacky things to collection views in my time there 😀
