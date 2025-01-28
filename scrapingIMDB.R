if (!requireNamespace("XML", quietly = TRUE)) {
  install.packages("XML")
}
if (!requireNamespace("rvest", quietly = TRUE)) {
  install.packages("rvest")
}
if (!requireNamespace("stringr", quietly = TRUE)) {
  install.packages("stringr")
}

library('XML')
library('rvest')
library("stringr")

# Use XML to read in the HTML from IMDB site
site <- "https://www.imdb.com/search/title?groups=top_250&sort=user_rating"
sitehtml <- read_html(site)
sitehtml

# Looking at the body
html_node(sitehtml, 'body')

# Get first row from table
firstrow <- html_node(sitehtml,'h3 a')
firstrow
html_text(firstrow)

# Get all rows from table
body_rows <- html_nodes(sitehtml, "h3 a")
## PRINT FIRST 4 ITEMS
body_rows[1:4]

# Check how many we have
length(body_rows)
tail(body_rows)

# Using the html_text function to pull out text that isn't in HTML
titles <- html_text(body_rows)
length(titles)
titles <- titles[1:50]
titles # This looks much neater!

# URLs
urls <- (html_attr(body_rows, "href"))[1:50]
urls

# Putting them into a data frame
imdb_top_250 = as.data.frame(titles, stringsAsFactors = FALSE)
imdb_top_250["URLs"] <- urls
head(imdb_top_250)

# Getting year
# First try
html_node(sitehtml, 'span.lister-item-year.text-muted.unbold') %>% html_text()

# Getting all
html_nodes(sitehtml, 'span.lister-item-year.text-muted.unbold') %>% html_text()

# Cleaning the text
html_nodes(sitehtml, 'span.lister-item-year.text-muted.unbold') %>% html_text() %>% str_extract("\\d{4}")

# Adding to dataframe
imdb_top_250["year"] <- html_nodes(sitehtml, 'span.lister-item-year.text-muted.unbold') %>% 
  html_text() %>% str_extract("\\d{4}")

# Adding rating
imdb_top_250["rating"] <- html_nodes(sitehtml, 'span.certificate') %>% html_text()

# Adding runtime
imdb_top_250["runtime"] <- html_nodes(sitehtml, 'span.runtime') %>% html_text() %>% str_extract("\\d*") %>% as.numeric()

# Adding genre
imdb_top_250["genres"] <- html_nodes(sitehtml, 'span.genre') %>% html_text() %>% str_trim()

html_node(sitehtml, 'div.inline-block.ratings-imdb-rating') %>% 
  html_element("strong") %>% html_text()

# Adding star rating
imdb_top_250["stars"] <- html_nodes(sitehtml, 'div.inline-block.ratings-imdb-rating') %>% 
  html_element("strong") %>% html_text() %>% as.numeric()

head(imdb_top_250)

description <- html_nodes(sitehtml, 'p.text-muted') %>% html_text()
description <- description[1:50*2]
description

directors <- html_nodes(sitehtml, 'p')  %>% 
  html_element("a") %>%
  html_text()
directors <- directors[!is.na(directors)]
directors <- directors[directors != 'Top 250']
directors

##### Adding next page ######
sess <- html_session(site)
is.session(sess)

sess <- sess %>% session_follow_link("Next")

# Check to see if we're getting 51-100
html_node(sess, "span.lister-item-index.unbold.text-primary") %>% html_text()

# Get data from next page
titles <- html_nodes(sess, "h3.lister-item-header a") %>% html_text()
urls <- html_nodes(sess, "h3.lister-item-header a") %>% html_attr("href")
years <- html_nodes(sess, 'span.lister-item-year.text-muted.unbold') %>% html_text() %>% str_extract("\\d{4}")
ratings <- html_nodes(sess, 'span.certificate') %>% html_text()
runtimes <- html_nodes(sess, 'span.runtime') %>% html_text() %>% str_extract("\\d*") %>% as.integer()
genres <- html_nodes(sess, 'span.genre') %>% html_text() %>% str_trim()
stars <- html_nodes(sess, 'div.inline-block.ratings-imdb-rating') %>% html_node ("strong") %>% html_text() %>% as.numeric()

# Note the length
length(ratings)

# We're going add the movies to the imdb_top_250 dataframe
# First, create a page dataframe to get all movies on the page
page = data.frame(titles = rep(NA, 50),
                  URLs = rep(NA, 50),
                  year = rep(NA, 50),
                  rating = rep(NA, 50),
                  runtime = rep(NA, 50),
                  genres = rep(NA, 50),
                  stars = rep(NA, 50))
movies_html <- html_nodes(sess, '.mode-advanced')
movies_html[1] %>% html_node("h3.lister-item-header a")

len <- length(movies_html) # get the length of the movie blocks vector as a variable
for (i in 1:len) { # loop through each movie block one by one
  #set the 7 elements for this movie
  title <- movies_html[i] %>% html_node("h3.lister-item-header a") %>% html_text()
  url <- movies_html[i] %>% html_node("h3.lister-item-header a") %>% html_attr("href")
  year <- movies_html[i] %>% html_node('span.lister-item-year.text-muted.unbold') %>% html_text() %>% str_extract("\\d{4}")
  rating <- movies_html[i] %>% html_node('span.certificate') %>% html_text()
  runtime <- movies_html[i] %>% html_node('span.runtime') %>% html_text() %>% str_extract("\\d*") %>% as.integer()
  genre <- movies_html[i] %>% html_node('span.genre') %>% html_text() %>% str_trim()
  star_rating <- movies_html[i] %>% html_node('div.inline-block.ratings-imdb-rating') %>% html_node ("strong") %>% html_text() %>% as.numeric()
  
  #create the row for this movie by column binding (cbind) the 7 items
  movie_row <- c(title, url, year, rating, runtime, genre, star_rating)
  #append the new row to the page df
  page[i,] <- movie_row
}

head(page)
tail(page)

# Don't run this multiple times, as you'll add the rows again and again!
imdb_top_250 <- rbind(imdb_top_250, page)

# Do the other three pages
for(i in 1:3){
  sess <- sess %>% session_follow_link("Next")
  page <- data.frame()
  movies_html <- html_nodes(sess, '.mode-advanced')
  len <- length(movies_html) # get the length of the movie blocks vector as a variable
  for (i in 1:len) { # loop through each movie block one by one
    #set the 7 elements for this movie
    title <- movies_html[i] %>% html_node("h3.lister-item-header a") %>% html_text()
    url <- movies_html[i] %>% html_node("h3.lister-item-header a") %>% html_attr("href")
    year <- movies_html[i] %>% html_node('span.lister-item-year.text-muted.unbold') %>% html_text() %>% str_extract("\\d{4}")
    rating <- movies_html[i] %>% html_node('span.certificate') %>% html_text()
    runtime <- movies_html[i] %>% html_node('span.runtime') %>% html_text() %>% str_extract("\\d*") %>% as.integer()
    genre <- movies_html[i] %>% html_node('span.genre') %>% html_text() %>% str_trim()
    star_rating <- movies_html[i] %>% html_node('div.inline-block.ratings-imdb-rating') %>% html_node ("strong") %>% html_text() %>% as.numeric()
    
    #create the row for this movie by column binding (cbind) the 7 items
    movie_row <- cbind(title, url, year, rating, runtime, genre, star_rating)
    #append the new row to the page df
    page <- rbind (page, movie_row)
  }
  colnames(page) <- colnames(imdb_top_250)
  imdb_top_250 <- rbind(imdb_top_250, page)
}
dim(imdb_top_250) # print final dimensions

imdb_top_250

library(tidyverse)

qplot(imdb_top_250$rating)
qplot(as.numeric(imdb_top_250$runtime), bins = 15)


