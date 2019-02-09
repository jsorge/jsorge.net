---
microblog: false
title: "Scorebook Sync Log 06 \u2013 Fun with Protocols"
layout: post
date: 2015-05-21T16:20:10Z
staticpage: false
---

In my usage of CloudKit I had to determine early on how I was going to upload batches of records and deal with batches coming down. I’m dealing entirely with `CKRecord` instances, so all of my entities will need to know how to handle those; both in how to create one from themselves, and how to turn turn one into itself. 

I didn’t have any clever idea at first, so I punted. For saving records to CloudKit, I’m monitoring the `NSManagedObjectContextDidSaveNotification` (which isn’t verbose enough) and I get `NSSet`s of managed objects. Here’s what my initial implementation looked like:

```objectivec
- (CKRecord *)ckRecordForManagedObject:(NSManagedObject *)managedObject
{
    CKRecordZoneID *userZone = [[SBSyncController sharedSyncController] userRecordZone];
    CKRecord *recordToReturn;
    
    if ([managedObject isKindOfClass:[SBPerson class]]) {
        recordToReturn = [(SBPerson *)managedObject cloudKitRecordInRecordZone:userZone];
    } else if ([managedObject isKindOfClass:[SBGame class]]) {
        recordToReturn = [(SBGame *)managedObject cloudKitRecordInRecordZone:userZone];
    } else if ([managedObject isKindOfClass:[SBMatch class]]) {
        recordToReturn = [(SBMatch *)managedObject cloudKitRecordInRecordZone:userZone];
    } else if ([managedObject isKindOfClass:[SBPlayer class]]) {
        recordToReturn = [(SBPlayer *)managedObject cloudKitRecordInRecordZone:userZone];
    } else if ([managedObject isKindOfClass:[SBScore class]]) {
        recordToReturn = [(SBScore *)managedObject cloudKitRecordInRecordZone:userZone];
    } else if ([managedObject isKindOfClass:[SBMatchImage class]]) {
        recordToReturn = [(SBMatchImage *)managedObject cloudKitRecordInRecordZone:userZone];
    } else if ([managedObject isKindOfClass:[SBMatchLocation class]]) {
        recordToReturn = [(SBMatchLocation *)managedObject cloudKitRecordInRecordZone:userZone];
    }
    
    return recordToReturn;
}
```

Yuck.

And similarly, I captured the `-recordType` property of an incoming `CKRecord`, then ran `-isEqualToString:` against it to determine which entity it represented. And then something interesting happened.

I got to the place where I was working through how to handle conflicts and needed a `-modificationTimestamp` property to get that done, and realized that I could use a protocol to declare uniform conformance across all of my entities. I could make sure that the class conforms to the protocol, and then set the property without having to do the ugliness of something like the above snippet.

And thus, `SBCloudKitCompatible` was born. This protocol defines 4 things in the interface:

```objectivec
@protocol SBCloudKitCompatible <NSObject>
@property (nonatomic, strong) NSString *ckRecordName;
@property (nonatomic, strong) NSDate *modificationDate;

- (CKRecord *)cloudKitRecordInRecordZone:(CKRecordZoneID *)zone;
+ (NSManagedObject *)managedObjectFromRecord:(CKRecord *)record context:(NSManagedObjectContext *)context;
@end
```

By conforming to this protocol, I’ve been able to cut out a bunch of code. Here’s what the snippet above now looks like:

```objectivec
- (CKRecord *)ckRecordForManagedObject:(NSManagedObject *)managedObject
{
    CKRecord *recordToReturn = nil;
    
    if ([managedObject conformsToProtocol:@protocol(SBCloudKitCompatible)]) {
        id<SBCloudKitCompatible> object = (id<SBCloudKitCompatible>)managedObject;
        recordToReturn = [object cloudKitRecordInRecordZone:self.zoneID];
    }
    
    return recordToReturn;
}
```

I think we can agree that it looks way, way better.