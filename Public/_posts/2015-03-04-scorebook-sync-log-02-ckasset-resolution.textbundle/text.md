After thinking through my options [last time](http://jsorge.net/2015/02/21/scorebook-sync-log-episode-01-binary-data-files-core-data/) I landed on option 2. Instead of storing the binary data within Core Data, I'm putting it in the file system instead. Here's how it's working:

* The user picks an image that they want to save
* The object associating with the image determines its filename and is responsible for all saving and retrieving of file data

I put the saving methods in a category on the 3 entities that save images. I couldn't stomach the idea of importing UIKit into actual model classes. This is more of a style thing than not, so it could have gone either way.

When I was originally putting this together I stored the absolute filepath to each file. This would work until I relaunched and then it broke. Turns out the simulator's documents path isn't always guaranteed to be the same file path every time. The workaround is to store the file's path relative to my documents directory. When I need to retrieve the image, the object responsible grabs the current document directory and smashes it up with the relative file path.

I'm not super happy that this is something I had to do in the first place, but I am satisfied with how it turned out. Now I get to move on to the grittier details of the syncing process.
