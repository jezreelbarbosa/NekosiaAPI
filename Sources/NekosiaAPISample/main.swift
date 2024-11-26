import Foundation
import NekosiaAPI

NekosiaAPI.shared.fetchImages(category: "catgirl", query: [
    .count(1),
    .rating(.safe)
]) { result in
    print(result)
}

NekosiaAPI.shared.fetchById("66a7792dbf843e6bbe6eddcc") { result in
    print(result)
}

RunLoop.main.run()
