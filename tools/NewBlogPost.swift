import Files // marathon:https://github.com/JohnSundell/Files.git
import Foundation
import MaverickModels // marathon:https://github.com/jsorge/maverick-models.git
import ShellOut // marathon:https://github.com/JohnSundell/ShellOut.git
import Yams // marathon:https://github.com/jpsim/Yams.git

struct Options {
    let postTitle: String
    let isDraft: Bool

    init(args: [String]) {
        var allArgs = args.dropFirst()

        if let draftIndex = allArgs.firstIndex(of: "--draft") {
            self.isDraft = true
            allArgs.remove(at: draftIndex)
        }
        else {
            self.isDraft = false
        }

        if let firstArg = allArgs.first, firstArg.starts(with: "--") == false {
            self.postTitle = firstArg
        }
        else {
            self.postTitle = "New Post"
        }
    }
}

struct Info: Codable {
    let version = 2
    let `type` = "net.daringfireball.markdown"
    let transient = true

    static var encoded: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(Info())
        return String(data: data, encoding: .utf8)!
    }
}

@available(OSX 10.12, *)
extension FrontMatter {
    static func emptyTemplate(date: Date, filename: String, title: String) -> FrontMatter {
        return FrontMatter(isMicroblog: false, title: title,
                           layout: "post", guid: nil, date: date, isStaticPage: false,
                           shortDescription: "<Short Description Goes Here>", filename: filename)
    }

    var yamlEncoded: String {
        let encoder = YAMLEncoder()
        return try! encoder.encode(self)
    }
}

@available(OSX 10.12, *)
func createPostDate() -> Date {
    let date = Date()

    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.formatOptions = [ .withInternetDateTime ]

    let dateStr = formatter.string(from: date)
    let converted = formatter.date(from: dateStr)!
    return converted
}

func extractDayMonthYear(from date: Date) -> (day: Int, month: Int, year: Int) {
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)

    return (day, month, year)
}

func makeFilenameFromTitle(_ title: String) -> String {
    let formattedFilename = title
        .split(separator: " ")
        .joined(separator: "-")
        .lowercased()

    return formattedFilename
}

@available(OSX 10.12, *)
func makePostBaseText(date: Date, filename: String, title: String) -> String {
    return  """
    ---
    \(FrontMatter.emptyTemplate(date: date, filename: filename, title: title).yamlEncoded)---

    """
}

/* ========== SCRIPT ========== */
if #available(OSX 10.12, *) {
    let publicFolder = try Folder(path: "~/Develop/jsorge.net/Public/")
    let postsFolder = try publicFolder.subfolder(named: "_posts")
    let draftsFolder = try publicFolder.subfolder(named: "_drafts")

    let postDate = createPostDate()
    let options = Options(args: CommandLine.arguments)
    let filename = makeFilenameFromTitle(options.postTitle)
    let dateComponents = extractDayMonthYear(from: postDate)
    let formattedDay = String(format: "%02d", dateComponents.day)
    let formattedMonth = String(format: "%02d", dateComponents.month)
    let bundleName = "\(dateComponents.year)-\(formattedMonth)-\(formattedDay)-\(filename).textbundle"

    // Create the text bundle
    let bundlePath: Folder
    if options.isDraft {
        bundlePath = try draftsFolder.createSubfolderIfNeeded(withName: filename)
    }
    else {
        bundlePath = try postsFolder.createSubfolderIfNeeded(withName: bundleName)
    }

    // Add info.json
    try bundlePath.createFile(named: "info.json", contents: Info.encoded)

    // Create the base text.md
    let baseContent = makePostBaseText(date: postDate, filename: bundleName, title: options.postTitle)
    try bundlePath.createFile(named: "text.md", contents: baseContent)

    // Create the assets folder and add .gitkeep
    let assetsDir = try bundlePath.createSubfolder(named: "assets")
    try assetsDir.createFile(named: ".gitkeep")

    print("Created new text bundle at \(bundlePath.path). Opening in BBEdit.")

    // Open in my editor
    try shellOut(to: "bbedit", arguments: [bundlePath.path])

}
else {
    print("This script requires macOS 10.12 or higher")
    exit(1)
}
