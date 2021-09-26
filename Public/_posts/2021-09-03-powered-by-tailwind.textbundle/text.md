I've been able to take time off from my normal duties at Zulily and learn something new. That thing has been [Tailwind CSS](https://tailwindcss.com). I originally heard about it from [Jordan Morgan's exploration of it](https://www.swiftjectivec.com/tailwindcss-from-a-ios-dev/) from the perspective of an iOS developer and was intrigued. I'm not any CSS wizard by any stretch and Tailwind looked like a cool way to simplify what I've done before and maybe even make some things better.

The week went well over all! It took me what felt like a long time to get used to some of the core concepts like using all the utilities it gives me, but I'm happy with the outcome – even though the results don't look much different from the previous layout. Once I got my mind around using the configuration file, and then processing my [input CSS](https://github.com/jsorge/jsorge.net/blob/main/styles/styles.source.css) into my final output things really started clicking. I could use my same fonts, and using the [typography plugin](https://github.com/tailwindlabs/tailwindcss-typography) I was able to easily just let the system lay out m text way better than I ever could by hand.

I'd be remiss too if I didn't mention the wonderful [Tailwind UI](https://tailwindui.com) templates that helped me along my way too. They are a really nice way to get started and piece together some super functional sites. I'm not using Vue or React so I had to do some adapting of the HTML templates (and if I need to, I'll have to write any JavaScript to interact with them by hand).

I also did a bit of refactoring of my leaf templates to simplify them a bit, wrote a couple of new command line utilities to help me make & publish new posts, and put in my first [GitHub Action](https://github.com/jsorge/jsorge.net/blob/main/.github/workflows/push-on-main.yml) which will publish new posts as I commit them to the repository.

On the whole it's been a very productive week. My next task will be to upate my [Taphouse](https://taphouse.io) using Tailwind as well – and I'll be making heavy use of those Tailwind UI components to get that done.