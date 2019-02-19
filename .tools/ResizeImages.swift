import Foundation
import ShellOut // marathon:https://github.com/JohnSundell/ShellOut.git

func applyStash(named stashName: String) {
    guard let stashes = try? shellOut(to: "git stash list") else { return }
    if stashes.components(separatedBy: "\n").first == stashName {
        _ = try? shellOut(to: "git stash pop -q")
    }
}

func saveStash(named stashName: String) throws {
    try shellOut(to: "git stash save -q --keep-index \(stashName)")
}

let imgExtensions = [
    "jpeg",
    "jpg",
    "png",
]

extension String {
    var containsImageExtension: Bool {
        for ext in imgExtensions {
            if self.contains(ext) {
                return true
            }
        }

        return false
    }
}

let stashName = "pre-commit-\(Date())"
try saveStash(named: stashName)

let stashedFiles = try shellOut(to: "git diff --staged --name-only")
let imagePaths = stashedFiles
    .components(separatedBy: "\n")
    .filter({ $0.containsImageExtension })

guard imagePaths.count > 0 else {
//    applyStash(named: stashName)
    exit(0)
}

let workingDir = try shellOut(to: "pwd")

for path in imagePaths {
    let fullImagePath = "\(workingDir)/\(path)"
    let command = "/usr/local/bin/magick mogrify -resize 500 \(fullImagePath)"

    try shellOut(to: command)
}

applyStash(named: stashName)
