Last year when I started thinking about moving away from Ghost as my blogging platform, the first place I turned was Jekyll. It's really popular and can create great websites. Plus it's nerdy, which is usually right up my alley. I found an exporter from Ghost to Jekyll which worked quite nicely. But one thing that did rub me wrong was that posts were separated from their associated media assets. This is why I started looking at [textbundle](http://textbundle.org) packages.

I really like encapsulating each post in a single file, with assets and text contained inside. And, because I went from Ghost to the Jekyll format directly, I left the metadata at the top of a post's `text.md` file inside. The metadata (or FrontMatter) contains things like the post title, date, tags, etc. As it is currently, there's a chunk of yml at the top of each of my markdown files containing this metadata. I'm starting to rethink this approach now, for a couple of reasons:

* I want to build a textbundle editor that can work not just with files for my [Maverick](https://github.com/jsorge/maverick)-powered blog, but anyone who wants to write using that format.
* Currently I have to open the main text of each post file to get at its metadata. While I haven't done any benchmarking on the server, I suspect this isn't the most optimal way of doing things. This unknown overhead has made me hesitant to implement some new features.

So, with the decision seemingly made that I want to investigate moving metadata somewhere else, where should I start putting it? Turns out that textbundles have an `info.json` file inside. I'd always just hard-coded its contents when I'm creating new bundles and moved on. But when I look at the documentation for that file I found this gem:

> Additionally, the meta data file can contain application-specific information. Application-specific information must be stored inside a nested dictionary. The dictionary is referenced by a key using the application bundle identifier (e.g. com.example.myapp). This dictionary should contain at least a version number to ensure backwards compatibility.

Turns out my custom metadatas source has been in front of my face all along. I'll need to write a script to update all of my existing posts (which I don't anticipate will be too difficult), and from there update my Maverick code to handle the new location of the metadata. I sure hope this will only take a few days to get done.

It's been a bit since I did much significant work on Maverick and I'm really excited to dig back in.
