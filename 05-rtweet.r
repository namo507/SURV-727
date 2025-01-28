
library(rtweet)
library(tidyverse)
library(tidytext)
library(ggmap)


## Collecting Twitter data

### Search tweets and users

# The `rtweet` package offers many features for searching and collecting Twitter data. As an example, `search_tweets()` allows us to search and retrieve tweets by keywords.

?search_tweets

# Among other options, we can specify the number of desired tweets to be returned via `n`. Note that the default `type` of search results to return is "recent".

auth_as("default")
chicago_tweets <- tweet_search_recent("#ChicagoPolice", n = 100)
chicago_tweets


# Besides the tweet text, `rtweet` attaches a lot of meta-information to the search results.


names(chicago_tweets)


# We can also use `search_tweets()` in combination with geocodes (and a radius) to include a geographical limiter when searching for tweets.


chicago_loc <- search_tweets("lang:en", geocode = "41.881,-87.623,1mi", n = 100)


# We can use the `ggmap` package to (1) download a map of Chicago and (2) plot the tweets locations on that map. For building the map, geocodes (lon and lat for the bounding box) of the desired area can be found here:

# https://boundingbox.klokantech.com/


chicago_loc <- lat_lng(chicago_loc)

map <- get_stamenmap(bbox = c(-87.7200,41.7957,-87.5490,41.9463), 
                     zoom = 12, maptype = "toner-hybrid")

# Now we can overlay the map with the tweet locations (colored by `retweet_count`).


ggmap(map) + 
  geom_point(data = chicago_loc, 
             aes(x = lng, y = lat, color = retweet_count), 
             size = 1)


# Another option is to search for Twitter users with certain keywords in their profiles.


chicago_users <- search_users("#Chicago", n = 100)
chicago_users


# Some exploration of the meta-information that comes with the tweets.


qplot(followers_count, data = chicago_users, bins = 20) 

chicago_users %>% arrange(desc(followers_count)) %>% 
  select(name, description)

glimpse(chicago_users)
### Stream tweets

# A major functionality of the `rtweet` is the option to live stream tweets. As an example, we can collect a 'random' sample of Tweets for 10 seconds as follows.

stream_tweets(
  q = "",
  timeout = 10,
  file_name = "sample.json",
  parse = FALSE
)


# Since the results were written to a local json file, we need to load and parse them to make them accessible in R.


sample <- parse_stream("sample.json")


# The `ts_plot()` allows us to plot the number of tweets that were collected over time.


ts_plot(sample, by = "secs")


# As with `search_tweets()`, we can also collect tweets from a specific location (e.g., for 60 seconds).


stream_tweets(
  c(-87.7200,41.7957,-87.5490,41.9463), 
  timeout = 60,
  file_name = "chicago.json",
  parse = FALSE
)

# Again, parsing the json file.


chicago <- parse_stream("chicago.json")


# Plotting the tweet locations.


qplot(chicago$place_full_name)

# Still using `stream_tweets()`, we can collect tweets that contain specific keywords (e.g., for 30 seconds).


stream_tweets(
  q = "chicago,crime,police",
  timeout = 30,
  file_name = "keywords.json",
  parse = FALSE
)



keywords <- parse_stream("keywords.json")


## Exploring Twitter data

# In this section we check whether the top words in the tweets that were collected in the previous step match with the search keywords.

# First, we need to clean the tweets. This includes deleting links using regex and `gsub()`. 


keywords$text <- gsub("http.*", "", keywords$text)
keywords$text <- gsub("https.*", "", keywords$text)
keywords$text <- gsub("&amp;", "&", keywords$text)

# Next, we remove punctuation, convert to lowercase, and separate the words.


keywords_clean <- keywords %>%
  select(text) %>%
  unnest_tokens(word, text)

# Lastly, we delete stopwords using a stopword lexicon from the `tidytext` package. 
# Note that we could also use Twitter's stopwords # stopwordslang
# tw.sw <- stopwordslangs

nrow(keywords_clean)

stopwds <- get_stopwords("en")
keywords_cleaner <- keywords_clean %>%
  anti_join(stopwds)

nrow(keywords_cleaner)

# We can now plot the top 15 words based on the cleaned tweet text.


keywords_cleaner %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot() +
  geom_col(aes(x = word, y = n)) +
  coord_flip()


## Open exercise

# Try out `stream_tweets()` with your own keywords 
# and/or location, etc. 
# Feel free to adjust other settings as well, 
# but please try to keep the number of tweets to be collected 
# at a reasonable level.


stream_tweets(
  q = "your-own-keywords",
  timeout = 30,
  file_name = "own-keywords.json",
  parse = FALSE
)


# Parse the returned json file.


keywords <- parse_stream("own-keywords.json")

 
# Explore your results!


# Helpful Tutorial
# https://github.com/PythonCoderUnicorn/rtweet-tutorial

## References

# https://rtweet.info/articles/stream.html