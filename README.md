# NekosiaAPI
A simple wrapper made in swift for Nekosia API

## 📄 Documentation
Check out the [official documentation](https://nekosia.cat/documentation) to learn more.

## 📦 Installation
To install this API, use Swift Package Manager (SPM).\
In your `Package.swift` file, add the package to the dependencies list and include `"NekosiaAPI"` in your target dependencies, as shown below:

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
Import `NekosiaAPI` in the file where you'll use it.\
For dependency injection, use the `NekosiaAPIServicing` protocol.\
To handle errors, use `do-catch`.

### 🧪 Simple Example
You can make a basic request by passing a category, or customize your search with parameters:

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

## 🌐 IP-based Sessions
In this mode, each IP address receives its own session. This helps avoid repeated images when fetching randomized results.

```swift
Task {
    let images = try await nekosiaAPI.fetchImages(category: "catgirl", query: [
        .session("ip"),
        .count(48)
    ])
    print(images)
}
```

### 🆔 ID-based Sessions
You can also use a user-specific session by providing an identifier. Pass this value as a string using `.id` query.

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

### 🏷️ Tags
To get a full list of available tags, request them with:

```swift
Task {
    let tags = try await nekosiaAPI.fetchTags()
    print(tags)
}
```

### ✅ Completion support
Closure-based requests are also supported:

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






































