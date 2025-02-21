# NekosiaAPI
A simple wrapper made in swift for Nekosia API

## 📄 Documentation
Check out the [official documentation](https://nekosia.cat/documentation) to learn more.

## 📦 Installation
To install this API, use SPM (swift Package Manager)\
In your `Package.swift` file, add this package to the dependencies list, and the package name to your target's dependencies as per the following example

```swift
// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(url: "https://github.com/jezreelbarbosa/NekosiaAPI.git", upToNextMajor: "1.0.0")
    ],
    targets: [
        .target(name: "MyPackage", dependencies: ["NekosiaAPI"])
    ]
)
```

## 🤔 How to Use?
To use it, you do `import NekosiaAPI`\
In dependency injection you can use the `NekosiaAPIServicing` protocol\
To handle error cases, use the `do-catch` statement

### Simple Example
You can make a simple request with just one category or pass some parameters to customize the search

```swift
import NekosiaAPI

let nekosiaAPI: NekosiaAPIServicing = NekosiaAPI()

Task {
    do {
        let catgirlImages = try await nekosiaAPI.fetchImages(category: "catgirl")
        print(catgirlImages)

        let pinkImages = try await nekosiaAPI.fetchImages(category: "pink-hair", query: [.count(3)])
        print(pinkImages)
    } catch let error {
        print(error)
    }
}
```

### IP-based Sessions
In this example, we used an IP-based session. What does this mean? Thanks to this solution, a user with a specific IP address will not encounter duplicate images when selecting them randomly.

```swift
Task {
    let images = try await nekosiaAPI.fetchImages(category: "catgirl", query: [
        .session("ip"),
        .count(48)
    ])
    print(images)
}
```

### ID-based Sessions
You can also use `id`, but this requires providing a user identifier (e.g., from Discord). Pass this information in `id` as a string.

```swift
Task {
    let images = try await nekosiaAPI.fetchImages(category: "catgirl", query: [
        .session("id"),
        .id("1234"),
        .count(48),
        .additionalTags(["cute", "winter"]),
        .blacklistedTags(["skirt"]),
        .rating(.safe)
    ])
    print(images)
}
```

### Tags
To get a list of tags from the api, you can simply make a `fetchTags()` request

```swift
Task {
    let tags = try await nekosiaAPI.fetchTags()
    print(tags)
}
```

### Completion support
It also have closure based requests

```swift
nekosiaAPI.fetchTags { result in
    switch result {
    case .success(let tags):
        print(tags)
    case .failure(let error):
        print(error)
    }
}

nekosiaAPI.fetchById("66a7792dbf843e6bbe6eddccz") { model in
    print(model)
} onFailure: { error in
    print(error)
}
```

### More examples
https://github.com/jezreelbarbosa/NekosiaAPI/blob/main/Sources/NekosiaAPISample/main.swift






































