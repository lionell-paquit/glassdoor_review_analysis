### Packages ###
library(xml2)       #convert to XML document: read_html()
library(rvest)      #scrape
library(purrr)      #iterate scraping by map_df()

## Set URL details
company <- "Xero-Reviews-E318448"   #You can just change this value to any company you want to scrape
baseurl <- "https://www.glassdoor.com/Reviews/"
sort <- ".htm?sort.sortType=RD&sort.ascending=true"

# This will check the total number of reviews and determine the maximum page results to iterate over.
totalReviews <- read_html(paste(baseurl, company, sort, sep = "")) %>%
  html_nodes("h2.col-6") %>%
  html_text() %>%
  sub(".*?([0-9]+).*", "\\1", .) %>%  # remove text from string and retain the total review value
  as.integer()

maxresults <- as.integer(ceiling(totalReviews/10))     #10 reviews per page, round up to whole number

### Create df by scraping: Date, Summary, Rating, Title, Pros, Cons
### There are more information you can scrape on Glassdoor aside from what were already stated
df <- map_df(1:maxresults, function(i) {

                    #Time delay helps avoid errors from scrapping through pages
  Sys.sleep(2)      #Pausing also helps us avoid getting flagged as spammer from sending requests

  cat("P",i," ")    #Progress indicator on what page is currently being scrape

  pg <- read_html(paste(baseurl, company, "_P", i, sort, sep=""))
  data.frame(rev.date = html_text(html_nodes(pg, ".date.subtle.small, .featuredFlag")),
               rev.sum = html_text(html_nodes(pg, ".reviewLink .summary:not([class*='hidden'])")),
               rev.rating = html_attr(html_nodes(pg, ".gdStars.gdRatings.sm .rating .value-title"), "title"),
               rev.title = html_text(html_nodes(pg, ".authorInfo")),
               rev.pros = html_text(html_nodes(pg, ".mt-md:nth-child(1) .strong+ p")),
               rev.cons = html_text(html_nodes(pg, ".mt-md:nth-child(2) .strong+ p")),
               stringsAsFactors=F)
})

### Save df in CSV
write.csv(df, "../data/xero-glassdoor-output.csv")
