import Foundation
import NekosiaAPI

let tags: [String] = Array(NekosiaAPI.tags.shuffled().prefix(3))

if #available(macOS 10.15, *) {
    Task {
        do {
            let cat = try await NekosiaAPI.shared.fetchImages(category: "catgirl")
            print(cat)
            let model = try await NekosiaAPI.shared.fetchShadowImages(query: [.count(1), .additionalTags(tags), .blacklistedTags(["boy"]), .session("id"), .id("123456"), .rating(.questionable)])
            print(model)
            let image = try await NekosiaAPI.shared.fetchById("66a7792dbf843e6bbe6eddcc")
            print(image)
        } catch let error {
            print(error)
        }
    }
}

RunLoop.main.run()
