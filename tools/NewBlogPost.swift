#!/usr/bin/swift sh

import Foundation
import MaverickModels // jsorge/maverick-models ~> 2.2.0
import Pathos // @dduan
import ShellOut // @JohnSundell

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

/* ========== SCRIPT ========== */
if #available(OSX 10.12, *) {
    let publicFolder = Path("/Users/jsorge/Develop/jsorge.net/Public/")
    let postsFolder = publicFolder + Path("_posts")
    let draftsFolder = publicFolder + Path("_drafts")

    let postDate = createPostDate()
    let options = Options(args: CommandLine.arguments)
    let filename = makeFilenameFromTitle(options.postTitle)
    let dateComponents = extractDayMonthYear(from: postDate)
    let formattedDay = String(format: "%02d", dateComponents.day)
    let formattedMonth = String(format: "%02d", dateComponents.month)
    let bundleName = "\(dateComponents.year)-\(formattedMonth)-\(formattedDay)-\(filename).textbundle"

    // Create the text bundle
    let bundlePath: Path
    if options.isDraft {
        bundlePath = draftsFolder + Path(filename)
    }
    else {
        bundlePath = postsFolder + Path(bundleName)
    }

    bundlePath.createDirectory()

    // Add info.json
    let frontMatter = FrontMatter.emptyTemplate(date: postDate,
                                                filename: bundlePath.split().1.pathString,
                                                title: options.postTitle)
    let bundleInfo = BundleInfo.defaultWithFrontMatter(frontMatter)
    let bundleInfoPath = bundlePath + Path("info.json")
    bundleInfoPath.write(bundleInfo.toData(), createIfNecessary: true)

    // Create the empty text.md
    let textPath = bundlePath + Path("text.md")
    textPath.write("", createIfNecessary: true)

    // Create the assets folder and add .gitkeep
    let assetsPath = bundlePath + Path("assets")
    assetsPath.createDirectory()
    let assetsKeepPath = assetsPath + Path(".gitkeep")
    assetsKeepPath.write("", createIfNecessary: true)

    print("Created new text bundle at \(bundlePath.pathString). Opening in BBEdit.")

    // Open in my editor
    try shellOut(to: "bbedit", arguments: [bundlePath.pathString])
}
else {
    print("This script requires macOS 10.12 or higher")
    exit(1)
}
