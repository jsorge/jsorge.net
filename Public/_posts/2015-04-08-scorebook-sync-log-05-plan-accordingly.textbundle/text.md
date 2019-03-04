---
microblog: false
title: Scorebook Sync Log 05 - Plan Accordingly
layout: post
date: 2015-04-08T06:59:11Z
staticpage: false
tags:
  - scorebook-sync-log
---

When I decided to begin sync implementation with CloudKit, I just started going. I watched the WWDC videos (mostly) and read through the getting started, then started coding.

That wasn't the best tactic. Turns out.

There are a couple of questions that I should have asked myself. Do I want to have record changes pushed to me automatically? Do I want atomic operations so that all of the items have to succeed?

(As a slight aside, take note that neither of those things can be done on the public database, this is only for private data)

Well, I do want at least the record changes. So I need to implement a custom record zone. This is done with a `CKRecordZone` object, and is kind of like the equivalent of a database schema. Instead of using the default zone (which can't have push notifications or atomic actions), I create my own like this:

```language-objectivec
CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"ScorebookData" ownerName:CKOwnerDefaultName];
CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneID:zoneID];
```

The zone name can be "ASCII characters and must not exceed 255 characters". The zone name needs to be unique within the user's private database (which makes using a single string as the zone name possible). The owner name can just have the string constant `CKOwnerDefaultName`, which I'm pretty sure gets changed server-side to be some sort of user identifier. The docs aren't super clear about that part, but the method notes say:

> To specify the current user, use the CKOwnerDefaultName constant.

Poking inside that constant at runtime expands it to `__defaultOwner__`. CloudKit seems to know what to do, though.

The next part I had to figure out was how do I get records into this zone? You don't save anything to the zone object, but instead use a different initializer on the `CKRecordID` objects. So I added a paramteter to my `-cloudKitRecord` methods in my model categories to take a zone. Now the methods are `- (CKRecord *)cloudKitRecordInRecordZone:(CKRecordZoneID *)zone`,  and the implememtation uses the `-initWithRecordName:zoneID` initializer to create the record ID.

The thing I'm going to talk about next time is setting this whole stack up. I'm coming to realize that CloudKit, like Core Data, is a stack. I'm building a sync controller (which is what injects the `CKRecordZoneID` into the model objects' zone parameter) and that is working well so far. Stay tuned.
