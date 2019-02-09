import Files // marathon:https://github.com/JohnSundell/Files.git
import Foundation
import ShellOut // marathon:https://github.com/JohnSundell/ShellOut.git
import Yams // marathon:https://github.com/jpsim/Yams.git

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

struct FrontMatter: Codable {
    let isMicroblog: Bool
    let title: String?
    let layout: String?
    let guid: String?
    let date: Date
    let isStaticPage: Bool
    let shortDescription: String
    let filename: String?

    private enum CodingKeys: String, CodingKey {
        case isMicroblog = "microblog"
        case title = "title"
        case layout = "layout"
        case guid = "guid"
        case date = "date"
        case isStaticPage = "staticpage"
        case shortDescription = "shortDescription"
        case filename = "filename"
    }

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

func createPostDate() -> Date {
    let date = Date()

    guard #available(macOS 10.12, *) else { return date }

    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.formatOptions = [ .withInternetDateTime ]

    let dateStr = formatter.string(from: date)
    let converted = formatter.date(from: dateStr)!
    return converted
}

func localizeDate(_ date: Date) -> Date {
    let calendar = Calendar.current
    let gmtOffset = calendar.timeZone.secondsFromGMT(for: date)
    let localizedDate = calendar.date(byAdding: .second, value: gmtOffset, to: date)!
    return localizedDate
}

func extractDayMonthYear(from date: Date) -> (day: Int, month: Int, year: Int) {
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)

    return (day, month, year)
}

func parseTitleFromArgs(_ args: [String]) -> String {
    let title: String
    if args.count > 1 {
        title = CommandLine.arguments[1]
    }
    else {
        title = "New Post"
    }

    return title
}

func makeFilenameFromTitle(_ title: String) -> String {
    let formattedFilename = title
        .split(separator: " ")
        .joined(separator: "-")
        .lowercased()

    return formattedFilename
}

func makePostBaseText(date: Date, filename: String, title: String) -> String {
    return  """
    ---
    \(FrontMatter.emptyTemplate(date: date, filename: filename, title: title).yamlEncoded)---

    """
}

/* ========== SCRIPT ========== */
let postsFolder = try Folder(path: "~/Develop/jsorge.net/Public/_posts")

let postDate = createPostDate()
let title = parseTitleFromArgs(CommandLine.arguments)
let filename = makeFilenameFromTitle(title)
let dateComponents = extractDayMonthYear(from: postDate)
let formattedDay = String(format: "%02d", dateComponents.day)
let formattedMonth = String(format: "%02d", dateComponents.month)
let bundleName = "\(dateComponents.year)-\(formattedMonth)-\(formattedDay)-\(filename).textbundle"

// Create the text bundle
let bundlePath = try postsFolder.createSubfolderIfNeeded(withName: bundleName)

// Add info.json
try bundlePath.createFile(named: "info.json", contents: Info.encoded)

// Create the base text.md
let baseContent = makePostBaseText(date: postDate, filename: bundleName, title: title)
try bundlePath.createFile(named: "text.md", contents: baseContent)

// Create the assets folder and add .gitkeep
let assetsDir = try bundlePath.createSubfolder(named: "assets")
try assetsDir.createFile(named: ".gitkeep")

print("Created new text bundle at \(bundlePath.path). Opening in BBEdit.")

// Open in my editor
try shellOut(to: "bbedit", arguments: [bundlePath.path])
