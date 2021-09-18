When we're building apps it's important that we model our data in ways that make sense to how we want to use it. When building a game score app you might have a `Gameplay` object with an array of `Player`s who then each have their own `points` values, so that you can sort the players by number of points scored and find the one with the most to declare the winner.

There are going to be cases where we can completely model our data internally to our apps and other times where we might get data from an external source. And unless we have full control of that source (like an API built specifically for our app running on our platform) it's likely that compromises will need to be made to suit all the consumers of the data.

Let's consider a hypothetical example contrived from the [Star Wars API](https://swapi.dev):

```json
{
  "title": "The Empire Strikes Back",
  "episode_id": 5,
  "opening_crawl": "It is a dark time for the\r\nRebellion. Although the Death\r\nStar has been destroyed,\r\nImperial troops have driven the\r\nRebel forces from their hidden\r\nbase and pursued them across\r\nthe galaxy.\r\n\r\nEvading the dreaded Imperial\r\nStarfleet, a group of freedom\r\nfighters led by Luke Skywalker\r\nhas established a new secret\r\nbase on the remote ice world\r\nof Hoth.\r\n\r\nThe evil lord Darth Vader,\r\nobsessed with finding young\r\nSkywalker, has dispatched\r\nthousands of remote probes into\r\nthe far reaches of space....",
  "director": "Irvin Kershner",
  "producer": "Gary Kurtz, Rick McCallum",
  "release_date": "1980-05-17",
  "character_1": "Luke Skywalker",
  "character_2": "Leia Organa",
  "character_3": "Darth Vader",
  "character_4": "",
  "character_5": null,
  "homeworld_1": "Tatooine",
  "homeworld_2": "Alderaan",
  "homeworld_3": "Tatooine",
  "homeworld_4": "",
  "homeworld_5": null
}
```

This particular model for our movie is a totally flat structure. We have some metadata properties as well as some information about a few of our characters but the character data is blended in with our movie; it is not a structure of its own. There also may be other similar movie entries that have values for `character`/`homeworld` pairs such that we wouldn't have empty strings or null values. It's valid JSON to be sure, but definitely leaves much to be desired. When it comes time to fetch the data for our movie and we get the above response, how might we want to model our data so that it makes sense in our app?

## Direct Model

One option is to make our data model look exactly like it does coming off the wire. That will definitely make it easiest to translate from the response payload to our model object. So that might look something like this:

```swift
struct Movie: Decodable {
  let title: String
  let episode_id: String
  let opening_crawl: String
  let director: String
  let producer: String
  let release_date: String
  let character_1: String?
  let character_2: String?
  let character_3: String?
  let character_4: String?
  let character_5: String?
  let homeworld_1: String?
  let homeworld_2: String?
  let homeworld_3: String?
  let homeworld_4: String?
  let homeworld_5: String?
}
```

Going this route allows for all of the JSON above to be translated directly, which is nice. But we've got lots of optional strings going on here for the character/homeworld data. It doesn't filter out any empty or null values, and if we wanted to have a list of characters this model adds additional burden at the view level to make sense of the object it's been given rather than iterating on an array of characters. Let's rule this one out.

## Custom, Decodable Model

A better approach is to think about this from our view level and go backwards to the model. We know we want to show a screen for our movie; how might we want to model that movie in a way to help out our view?

```swift
struct Movie {
  struct Character {
    let name: String
    let homeworld: String
  }

  let title: String
  let episode_id: String
  let opening_crawl: String
  let director: String
  let producer: String
  let release_date: String
  let characters: [Character]
}
```

That looks a lot nicer to me. When it comes time for a view to render this data it doesn't need to worry about correlating properties together from the model to figure out the rows to show, nor does it need to filter out any empty or null values.
A simple `for` loop over the characters will get this done.

But how do we get to our `Movie` from the JSON payload above? That's where `Decodable` can help us:

```swift
extension Movie: Decodable {
  init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.title = try container.decode(String.self, forKey: .title)
      self.episodeID = try container.decode(String.self, forKey: .episodeID)
      self.openingCrawl = try container.decode(String.self, forKey: .openingCrawl)
      self.director = try container.decode(String.self, forKey: .director)
      self.releaseDate = try container.decode(String.self, forKey: .releaseDate)

      var characters = [Character]()

      for i in 1...50 {
          let characterKey = "character_\(i)"
          let homeworldKey = "homeworld_\(i)"

          do {
              let name = try decoder.decode(characterKey, as: String.self)
              let homeworld = try decoder.decode(homeworldKey, as: String.self)

              guard name.isEmpty == false, homeworld.isEmpty == false else { continue }
              let character = Character(name: name, homeworld: homeworld)
              characters.append(character)
          }
      }

      self.characters = characters
  }

  private enum CodingKeys: String, CodingKey {
      case title = "title"
      case episodeID = "episode_id"
      case openingCrawl = "opening_crawl"
      case director = "director"
      case releaseDate = "release_date"
      case characters = "characters"
  }
}
```

The `Codable` set of APIs strongly prefer static typing, but thanks to [Codextended by John Sundell](https://github.com/JohnSundell/Codextended) we can use a new extension on `Decodable` which can take a string for the key with the expected type and attempt to decode our property. This lets us build up a dynamic amount of character/homeworld keys