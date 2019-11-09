#!/usr/bin/swift sh

import Foundation
import ShellOut // @JohnSundell ~> 2.2

do {
    // commit files in a text bundle contained in the working copy
    try shellOut(to: "git add *.textbundle/**")
    try shellOut(to: .gitCommit(message: "New Post"))
    try shellOut(to: .gitPush())

    // ssh in to jsorge.net, at the directory of the website
    // run git pull
    try shellOut(to: "ssh jsorge@jsorge.net 'cd /var/www/jsorge.net/; git fetch && git pull'")
}
