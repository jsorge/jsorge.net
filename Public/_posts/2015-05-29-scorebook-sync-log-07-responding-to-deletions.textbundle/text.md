---
microblog: false
title: "Scorebook Sync Log 07 \u2013 Responding to Deletions"
layout: post
date: 2015-05-28T21:21:54Z
staticpage: false
tags:
  - scorebook-sync-log
---

(Thanks to David Hoang for the [encouragement to post this](https://twitter.com/davidhoang/status/604136066673565696))

I thought I was close to being done, and then I remembered that I haven’t implemented responding to deletions from CloudKit locally. Here’s how the process works:

1. Delete the object from Core Data & save the context
2. Respond to the context did save notification and send CloudKit `CKRecordID` objects representing the deleted record to CloudKit
3. CloudKit will send a notification to all subscribed devices letting them know of the deletion, with the corresponding `CKRecordID` object.
4. Figure out what entity that object belongs to, and delete the instance from the database
5. Save the updated database.

Pretty easy, right? Except, consider this: there isn’t a way to know the `recordType` of the CKRecordID coming down. The `recordType` is the database equivalent of a table, and it’s a property on `CKRecord`, not `CKRecordID`. When I’m creating `CKRecord`s from my managed objects, I set the `recordType` property to a string representing my entity. That keeps things clean (i.e. my `SBGame` instances would all have record types of `SBGame`).

I haven’t talked about uniquing objects in CloudKit yet, so let’s go back to the beginning there. When you create a `CKRecord` you can specify it’s unique ID (made up of a `recordName` property which is a string, and a zone if it’s going to a custom zone). Those 2 factors combine with the `CKRecord`’s `recordType` property to create a primary key. Good database practice so far. You can also choose not to specify a `recordID` at the `CKRecord`’s creation, and it will be created when saved to the server.

For ease, I have decided to create a unique ID as a UUID string that is set on `-awakeFromInsert` on all of my entities. That way I always know what their unique ID will be, and I don’t have to worry about saving them back to the database when they are saved to the cloud.

The first step to determining what record type the `CKRecordID` I’m responsible for deleting, I made a change to each entity’s `-recordName` property, so that it includes the entity name as the first part of the record name. Then it’s followed by a delimiter (I’m using “|~|”) and then the UUID. Here’s how that now looks:

```objectivec
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.ckRecordName = [NSString stringWithFormat:@"SBGame|~|%@", [[NSUUID UUID] UUIDString]];
}
```

A sample `recordName` for an `SBGame` instance would be “SBGame|~|386c1919-5f25-4be2-975f-5b34506c51db”, with |~| being the delimiter between the entity name and the UUID. A bit hacky, but it works.

On the downloader I explode the string into an array using he same delimiter and grab the first object, which will be “SBGame”. Once I have the entity and the `recordName` to search for, I can put this in a fetch request to grab the object that needs deletion. Here’s what that looks like:

```objectivec
NSString *recordName = recordID.recordName;
NSString *recordType = [[recordName componentsSeparatedByString:@"|~|"] firstObject];

NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ckRecordName = %@", recordName];
NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:recordType];
fetchRequest.predicate = predicate;

NSArray *foundObjects = [backgroundContext executeFetchRequest:fetchRequest error:nil];
id foundObject = [foundObjects firstObject];
if (foundObject != nil) {
    [backgroundContext deleteObject:foundObject];
}
```

In my limited initial testing this is working well so far, and it’s a simple solution to the problem.
