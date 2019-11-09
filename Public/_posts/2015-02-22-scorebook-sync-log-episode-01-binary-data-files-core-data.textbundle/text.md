I'm working on the CloudKit schema for Scorebook and am coming upon a question right away. Scorebook allows users to add pictures as avatars, or game thumbnails, and to attach to game plays. I'm storing these in Core Data as binary data. All cool on the device. I'm also using the option to allow external storage in the managed object model.

CloudKit offers to store these files as `CKAsset`s attached to my `CKRecord`. The problem is the init method for a `CKAsset` is `initWithFileURL:`, and `initWithData:` is not an option. So, how do I get to the files in the database?

My first inclination is to export the `NSData` as a file and return its resulting `file:///` URL. I don't like this because of the additional storage that is necessary. I also don't like this because of possible overhead in processing. This method could drain users' batteries much faster. I'll also have to account for cleanup of the files once the sync is complete.

The other option, that could be something of a rabbit hole, is to rewrite all of those binary data fields to point to a location on disk for the files. This is starting to sound like it might be the winner. The tricky part I think will be migrating all the current image assets out of the database and to their own files on disk, then initiating the first sync.

Which sounds better to you? Is there something I'm missing?

**Update** I just filed [rdar://19915193](rdar://19915193) asking for an initializer to work with `NSData` objects for `CKAsset`s.
