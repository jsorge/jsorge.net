In my [last post](https://jsorge.net/2019/08/22/struggling-with-swiftui) I talked about some of the struggles I'm having getting up to speed with SwiftUI. Let's dive in to a couple of examples.

**Magic Environments**

To make my Settings form view, I found a [suer helpful blog post by Majid Jabrayilov](https://mecid.github.io/2019/06/19/building-forms-with-swiftui/) where he goes over the basics of building a `Form` with SwiftUI and binding some controls to `UserDefaults`. He outlines a type called `SettingsStore`, which I also implemented. I diverged from the tutorial to try my hand at making a [property wrapper](https://www.avanderlee.com/swift/property-wrappers/) type to handle fetching from and saving to `UserDefaults`. When it came time to wire a switch up with its associated value is where I slowed quite a bit. The post has this line of code in the `SettingsView` type:

`@EnvironmentObject var settings: SettingsStore`

What this says is that somewhere in the SwiftUI environment will be a `SettingsStore` instance. What's missed in the post is how the thing gets there in the first place. It turns out that an ancestor of my `SettingsView` needs to inject the property into the environment when also constructing the view. Here's what that looks like in Scorebook's case, where the `SettingsView` is visible as a tab item in the tab bar.

`let hostingController = UIHostingController(rootView: SettingsListView().environmentObject(SettingsStore()))`

So after putting my `SettingsView` inside of the `UIHostingController`, I also need to chain an `environmentObject(_:)` call to put the store in the environment. When I failed to do this at first I got a crash, and when I tried constructing the environment and passing it in via constructor injection I couldn't set the variable. It has to be done through the environment. For my taste, it's feeling a bit magic-y at the moment but I'm hopeful that's due to the fact that I don't know what I'm doing very well just yet.

**Conditional View Navigation**

I've got a button on my settings screen to send me an email. In UIKit land I have an action on the button and check that the device in question can send the email, then it presents the mail compose screen. If it cannot, then I show an alert. Easy enough.

But in SwiftUI land it's not so easy (at least to my imperatively wired mind). Thankfully I found a [helpful StackOverflow question](https://stackoverflow.com/questions/56784722/swiftui-send-email) to help me get started with sending the message. I honestly don't quite understand exactly how the `UIViewControllerRepresentable` protocol works yet but I think the code in that answer gives me a good starting point. One thing that is kind of breaking my Objective-C brain is the usage of `_` when setting the initial value of a `@Binding` property. It's like setting the instance variable used to be in days of old.

The trouble comes in triggering the mail view from my settings screen. I think I've gotten it working with a dual-boolean option (again, somehow managed via **magic**). Here's what I've come up with (and this is working-ish in the simulator):

```swift
struct SettingsListView: View {
    // Mail
    @State var mailResult: MailResult?
    @State var isShowingMailView = false
    @State var isShowingMailErrorAlert = false

    var body: some View {
        NavigationView {
                Section(header: Text("Feedback".uppercased())) {
                    Button(action: {
                        if MFMailComposeViewController.canSendMail() {
                            self.isShowingMailView.toggle()
                        }
                        else {
                            self.isShowingMailErrorAlert.toggle()
                        }
                    }) {
                        Text("Send Email")
                    }
                }
            }
            .navigationBarTitle(Text("Settings"))
            .alert(isPresented: $isShowingMailErrorAlert) {
                Alert(title: Text("Unable to send mail"),
                      message: nil,
                      dismissButton: .default(Text("OK")))
            }

            if isShowingMailView {
                MailView(isShowing: $isShowingMailView, result: $mailResult)
                    .transition(.move(edge: .bottom))
                    .animation(.default)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
```

I haven't tried this on a device yet as I haven't installed iOS 13 at this point on anything (those days are nearing an end) but the Alert at least shows in the simulator. What I find kind of gross about this is the fact that I have separate `@State` booleans for showing or presenting content. How do those get reset when I dismiss the things they're presenting? It sounds like SwiftUI handles that but I don't know how.

I also don't like taking what was one single method in my UIKit code and scattering its pieces in a declarative spew of state all around my view code. I'm hoping there's a nice, Combine-y way of doing this that can let me isolate the states in clearer fashion.

Lots to learn still, which makes this exciting and frustrating all at the same time!
