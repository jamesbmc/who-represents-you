# Base url for all requests
base.pro.url <- "https://api.propublica.org/congress/v1/members/"

GetHouseInfo <- function(my.state, my.api.key) {
  # Url with state (to be obtained from civic api)
  state.url <- paste0(base.pro.url, "house/", my.state, "/current.json")
  
  # Making and parsing a request
  response <- GET(state.url, add_headers("X-API-Key" = my.api.key))
  body <- content(response, "text")
  data <- fromJSON(body)
  
  return(data$results)
}

GetHouseRepInfo <- function(rep.id, my.api.key) {
  # Base url for rep info
  rep.url <- paste0(base.pro.url, rep.id, ".json")
  
  # Making and parsing a request
  response <- GET(rep.url, add_headers("X-API-Key" = my.api.key))
  body <- content(response, "text")
  data <- fromJSON(body)
  rep <- data$results
  
  # Select relevant results, create a column for twitter address
  rep <- rep %>% 
    select(first_name, middle_name, last_name, date_of_birth, twitter_account) %>% 
    mutate(twitter_address = paste0("https://www.twitter.com/", twitter_account))
  
  # Get rid of NA middle names
  rep$middle_name[is.na(rep$middle_name)] <- ""
  
  return(rep)
}

GetHouseRepVoting <- function(rep.id, my.api.key) {
  # Base url for rep voting record
  rep.votes <- paste0(base.pro.url, rep.id, "/votes.json")
  
  # Making and parsing a request
  response <- GET(rep.votes, add_headers("X-API-Key" = my.api.key))
  body <- content(response, "text")
  data <- fromJSON(body)
  
  # Turn voting data into a flattened data frame, selecting relevant columns, add a column for if
  # rep agreed with majority result
  votes <- data$results$votes %>% 
    as.data.frame %>% 
    flatten() %>% 
    select(position, result) %>% 
    mutate(agree = position == "No" & (str_detect(result, "Rejected") | str_detect(result, "Failed")) | 
             position == "Yes" & (str_detect(result, "Agreed") | str_detect(result, "Passed")) | str_detect(result, "Joint"))
  
  return(votes)
}
