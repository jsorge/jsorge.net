I [previewed Arborist 1.2 last week](https://jsorge.net/2026/09/03/coming-soon-to-arborist-and-baseplate) and I'm happy to announce I [just released it](http://macarborist.com)!

The biggest new feature is support for running tasks from Make and mise. These systems let you define reusable pieces of work a scripts or short commands and are very common across all kinds of projects. Arborist now [supports these tasks](https://taphouse.io/arborist/help/tasks) right below the Commands section of the main window. I'm really happy with how this turned out, and it's only the beginning. I'm on the lookout for other task runners to support (and the beta of Arborist 1.3 already supports `justfile` and `npm run` tasks).

The next biggest effort is not strictly an app feature at all. It dawned on me early after releasing Arborist 1.0 that an app like this really should have documentation to go along with it. This would serve users well by being a place to look before asking for help as well as a repository for articles based on questions and feedback that I get from users. So now [Arborist help](https://taphouse.io/arborist/help) exists with pages covering many parts of the app. I'll be continuing to build this space out as I add new features and get questions from users.

To build out the help section I used [Maverick](https://github.com/taphouseio/maverick), my blog engine that powers this site. I had to make quite a few modifications to it but now it's no longer just a blog engine. I'm really happy with how it came together and that I have found another new use for [textbundles](https://textbundle.org). It's a format that I really do enjoy working with because it makes bundling assets alongside my text a breeze. I've even got my own textbundle editor that I've been building for the last 6+ years, and writing more posts here plus the new help articles have given me al the more reason to continue building that out too.

Back to Arborist, there are some other nice features added:

* The branch selection pop-up now has a filter at the top of the list so you can easily find the branch you're looking for.
* App update notifications no longer interrupt your work, they appear in the sidebar (that was inspired by [Rogue Amoeba](https://weblog.rogueamoeba.com/2026/04/28/unobtrusive-update-notifications/).
* Open the selected worktree in the terminal using the new `Open Worktree in Terminal` command in the Worktree menu.

There were also a handful of bug fixes too. Check out the [full release notes](https://taphouse.io/arborist/releases), and grab the new version today.