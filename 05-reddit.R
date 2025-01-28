

# install.packages("RedditExtractoR")

library(RedditExtractoR)

?RedditExtractoR
help(package = 'RedditExtractoR')

# Get submissions. From these, get links, then get their comments
?find_thread_urls

links_liberal_abortion <- find_thread_urls(keywords = "abortion",
                                       subreddit = "liberal",
                                       sort_by = "comments")

# Comments to to those links
comments_liberal_abortion <- get_thread_content(links_liberal_abortion$url)

first3 <- get_thread_content(links_liberal_abortion$url[1:3])
links_liberal_abortion$title[1]
first3[['comments']][1:3,]

### Repeat with conservative

links_conservative_abortion <- find_thread_urls(keywords = "abortion",
                                           subreddit = "conservative",
                                           sort_by = "comments")

# Comments to to those links
comments_conservative_abortion <- get_thread_content(links_conservative_abortion$url)

first3con <- get_thread_content(links_conservative_abortion$url[1:3])
links_conservative_abortion$title[1]
first3con[['comments']][1:3,]
