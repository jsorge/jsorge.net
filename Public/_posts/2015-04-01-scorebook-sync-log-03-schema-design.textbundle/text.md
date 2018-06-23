---
layout: post
title: Scorebook Sync Log 03 - Schema Design
date: '2015-04-01 03:59:18'
tags:
- scorebook-sync-log
---

Building a schema on CloudKit is pretty straightforward. You get a `CKRecord` object and treat it like a dictionary. There are a few data types they can take (`NSString`, `NSNumber`, `NSData` to name a few) and it’s a key/value pair to get the data on the record. Once you have a record created, you save it to the database and your RecordType (i.e. a database table) is created. Simple. But there is a trick associated with related data.

One of the data types you can attach is a `CKReference`. This is how you glue 2 records together. CloudKit supports 1:Many relationships (not many:many though). The way you do the relating is through the child record, not the parent. This tripped me up a little bit because with my background in FileMaker I would typically go parent to child (like with a portal object on a layout).

Let me back up for a moment. I made a design decision early on to isolate my networking files as much as possible. It could be a hedge or just wanting to have all the syncing code in one place, it jut felt right. I put a new folder in my Model folder called Sync and in it I have categories on all my model objects called `<objectName>+CloudKit.h/m`. I want each entity to know how to turn itself into a `CKRecord` and how to turn a `CKRecord` into itself. That feels like the right way to go.

Inside each category I have a method called `-cloudKitRecord` that returns a `CKRecord`. Here’s a basic implementation:

```language-objectivec
- (CKRecord *)cloudKitRecord
{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.ckRecordId];
    CKRecord *personRecord = [[CKRecord alloc] initWithRecordType:[SBPerson entityName]
                                                         recordID:recordID];
    
    personRecord[SBPersonFirstNameKEY] = self.firstName;
    personRecord[SBPersonLastNameKEY] = self.lastName;
    personRecord[SBPersonEmailAddressKEY] = self.emailAddress;
    
    if (self.imageURL) {
        CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:[self urlForImage]];
        personRecord[SBPersonAvatarKEY] = imageAsset;
    }
    
    return personRecord;
}
```

A few things to note here:

* I’m overriding -awakeFromInsert on all of my managed objects to create a -ckRecordId string property (Just a random UUID) that I can use as my CloudKit record ID. This is the unique identifier across the system. I started out with something much more complicated but landed here for now.
* I have used [Accessorizer (MAS link)](https://itunes.apple.com/us/app/accessorizer/id402866670?mt=12) to create string constants for all of my managed object properties. [See this talk from Paul Gorake for more Core Data amazingness.](http://corporationunknown.com/blog/2014/02/16/core-data-potpourri/)
* You can see my new `CKAsset` code at work here. I’m creating a new image asset with the URL to the image on disk, then you just use the asset as a property on the `CKRecord`. CloudKit handles the rest, which is really nice.

On the flipside, I have methods in the category that will take a `CKRecord` and create the Core Data managed object out of it. I haven’t gotten to the downstream sync just yet (I just ran into the need for `CKRecordZone`s that I’ll probably write about next). Once I start the downstream I’ll put up a post about it too.

I’m going to come back to the `CKReference` stuff in my next post, since this one got a bit too long. Stay tuned.