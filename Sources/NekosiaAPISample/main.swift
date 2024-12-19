import Foundation
import NekosiaAPI

let tags: [String] = Array(NekosiaAPI.tags.shuffled().prefix(3))
let nekosiaAPI: NekosiaAPIServicing = NekosiaAPI()
nekosiaAPI.isLoggerEnabled = true

if #available(iOS 13.0, macOS 10.15, watchOS 6, tvOS 13.0, *) {
    Task {
        do {
            let cat = try await NekosiaAPI.shared.fetchImages(category: "catgirl")
            print(cat)
            let model = try await nekosiaAPI.fetchShadowImages(query: [.count(1), .additionalTags(tags), .blacklistedTags(["boy"]), .session("id"), .id("123456"), .rating(.questionable)])
            print(model)
            let image = try await nekosiaAPI.fetchById("66a7792dbf843e6bbe6eddc        c")
            print(image)
        } catch let error {
            print(error)
        }
    }
} else {
    // Fallback on earlier versions
}

nekosiaAPI.fetchImages(category: "catgirl", query: [
    .count(1),
    .additionalTags(tags),
    .rating(.safe),
    .session("id"),
    .id("123456")
]) { model in
    print(model)
} onFailure: { error in
    print(error)
}

nekosiaAPI.fetchById("66a7792dbf843e6bbe6eddccz") { model in
    print(model)
} onFailure: { error in
    print(error)
}

nekosiaAPI.fetchShadowImages(query: [
    .count(1),
    .additionalTags(tags),
    .blacklistedTags(["boy"]),
    .session("id"),
    .id("1234"),
    .rating(.questionable)
]) { model in
    print(model)
} onFailure: { error in
    print(error)
}

RunLoop.main.run()
