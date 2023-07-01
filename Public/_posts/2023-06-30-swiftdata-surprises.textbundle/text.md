I've started working on a new app as a side project and because WWDC was just a few weeks ago decided to play with some of the new APIs introduced – namely SwiftData. Consider this class:

```swift
@Model
final class Company {
    var name: String

    @Relationship(inverse: \Person.company)
    var employees: [Employee] // `Employee` is also a class annotated with @Model
}
```

My surprises came when I started adding some tests around my new models. For somewhat contrived reasons, let's say that when a company gets created there is 1 employee.

```swift
func test_newCompany_hasEmployeeAttached() throws {
    let company = Company(name: "Great Co.")
    XCTAssertEqual(1, company.employees.count)
}
```

This test fails in 2 ways:
1. I get a crash at the init on the first line because there is no configured container.
2. I get a crash when accessing the array (which should have 1 auto-inserted value).

I fix the test by adding the container, and then inserting the `company` in to the container's context:

```swift
func test_newCompany_hasEmployeeAttached() throws {
    let context = // create the container

    let company = Company(name: "Great Co.")
    context.insert(company)

    XCTAssertEqual(1, company.employees.count)
}
```

What stands out to me is that it sure _feels_ like SwiftData classes are your own classes. But they're not. They gain a conformance to `PersistentModel` and have all of their persisted properties rewritten with generated getters and setters. So yeah the class does not inherit from `NSManagedObject` but it's also not a class that is unencumbered from implicit behavior to be aware of.

I think this is teaching me that there are nuances to using SwiftData and macros in general.
