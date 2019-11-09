A while back, the good folks at [Swift Talk](https://talk.objc.io) posted an episode about using [typed notifications](https://talk.objc.io/episodes/S01E27-typed-notifications-part-1). As one who deals with lots of notifications in the app I [build for my day job](https://www.zulily.com/mobilelanding) I was intrigued. However it didn’t feel like their crack at the problem of using types in notifications went quite far enough. I wanted a way to make any notification easily accessible wherever I needed to use it.

So I took a swing. Here’s what I came up with.

I started off where Swift developers usually do: a protocol.

```swift
public protocol NotificationDescriptor {
    associatedtype Payload
    var noteName: Notification.Name { get }
    func encode(payload: Payload) -> Notification
    func decode(_ note: Notification) -> Payload
}

public extension NotificationDescriptor {
    private var _modelKey: String {
        return "ModelKey"
    }
    
    public func encode(payload: Payload) -> Notification {
        let info = [_modelKey: payload]
        let note = Notification(name: noteName, object: nil, userInfo: info)
        return note
    }
    
    public func decode(_ note: Notification) -> Payload {
        let model = note.userInfo![_modelKey] as! Payload
        return model
    }
}
```

So, what we have here is the definition of our protocol. We have the `Payload` that conformers will `typealias` something to tell us what is going to be handled be the encode and decode functions. Then we have the notification that is posted or listened for. So far, so good.

Next is an extension to give us boilerplate implementations of encoding and decoding. This is really only useful with custom notifications that you create, and not ones given by iOS. 

To get this working, we need to also extend NotificationCenter so that it can listen for one of these descriptors. But first, there’s one class we need to build.

```swift
public final class NotificationToken {
    let token: NSObjectProtocol
    let center: NotificationCenter
    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}
```

This class will handle de-registering from NotificationCenter so we just need to hold onto whatever tokens are necessary. When the token goes out of scope and it deinits, then it removes the observer automatically. That really is the worst part of using block based notification observers.

Next is the NotiicationCenter extension:

```swift
public extension NotificationCenter {
    public func addObserver<A: NotificationDescriptor>(descriptor: A, queue: OperationQueue? = nil, using block: @escaping (A.Payload) -> ()) -> NotificationToken {
        let token = addObserver(forName: descriptor.noteName, object: nil, queue: queue, using: { note in
            block(descriptor.decode(note))
        })
        return NotificationToken(token: token, center: self)
    }
}
```

This method will add the observer for the notification’s name, and – using the specified queue – decode the notification and call the block which will have the payload as its argument. This makes call sites really nice:

```swift
struct CustomNotification: NotificationDescriptor {
    struct Output {
        let name: String
        let type: String
    }
    
    typealias Payload = Output
    let noteName = Notification.Name("CustomNotificationPosted")
}

class Foo {
    var token: NotificationToken?
    
    init() {
        token = NotificationCenter.default.addObserver(descriptor: CustomNotification(), using: { (output) in
            print("received a \(output.name) of type \(output.type)")
        })
    }
}

var myFoo: Foo? = Foo()
let output = CustomNotification.Output(name: "thing", type: "superclass")
let note = CustomNotification().encode(payload: output)
NotificationCenter.default.post(note)
myFoo = nil
```

If you put this all in a playground (and the files can be found here: https://gist.github.com/jsorge/a216f95d871371d1684f45519a59c5a6), you will see in your console the printed output of the block placed in `Foo`’s initializer. Pretty cool.

This gets a little bit more complicated if you want to use an iOS system notification. It all still works, you will just have to implement the decode function safely.

```swift
struct KeyboardDidShowNotification: NotificationDescriptor {
    typealias NotificationOutput = (begin: CGRect?, end: CGRect?)
    typealias Payload = NotificationOutput
    let noteName: Notification.Name = .UIKeyboardDidShow
    
    func decode(_ note: Notification) -> NotificationOutput {
        let begin = note.userInfo![UIKeyboardFrameBeginUserInfoKey] as? CGRect
        let end = note.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect
        return (begin, end)
    }
}
```

That’s all there is to it. I hope this is as useful to you as it has been to me!
