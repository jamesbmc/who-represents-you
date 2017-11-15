# Base url for requests about representatives and query parameter to filter by address
base.civic.url <- "https://www.googleapis.com/civicinfo/v2/representatives?"

# Function to request information about representatives by address
GetRepInfo <- function(my.address, my.api.key) {
  # Query parameters
  query.params <- list(key = my.api.key, address = my.address)
  
  # Requesting and parsing the data
  response <- GET(base.civic.url, query = query.params)
  body <- content(response, "text")
  data <- fromJSON(body)
  
  # Extract official data and select relevant information
  officials <- data$officials
  officials <- officials %>% 
    select(name, party, phones, emails, photoUrl, urls)
  
  # Get rid of NULL and NA values
  officials$emails[officials$emails == "NULL"] <- "Not available"
  officials$photoUrl[is.na(officials$photoUrl)] <- "Not available"
  officials$party[is.na(officials$party)] <- "NA"
  
  # Replace NULL candidate website with a google search for candidate
  google.names <- str_replace_all(officials$name, " ", "_")
  officials$urls[officials$urls == "NULL"] <- paste0("https://www.google.com/search?q=", google.names[officials$urls == "NULL"])
  
  # Set up photoUrl columns with a valid url for use in R markdown (html since gives nicer image sizing)
  officials$photoUrl[officials$photoUrl != "Not available"] <- paste0("<img src = ", officials$photoUrl[officials$photoUrl != "Not available"],
                                                                      " height = 150>")
  
  # Data about offices, unnested so can be joined later
  offices <- select(data$offices, name, officialIndices)
  offices <- unnest(offices)
  
  # Add 0 based indices to officials table
  officials <- officials %>% 
    mutate(officialIndices = seq(0, nrow(officials) - 1))
  
  # Join based on row index!
  officials <- left_join(officials, offices, by = "officialIndices")
  
  # Build out name column to include link to website
  officials$name.x <- paste0("<a href = ", officials$urls, ">", officials$name.x, "</a>")
  
  # Filter to data we want
  officials <- officials %>% 
    select(name.x, name.y, party, emails, phones, photoUrl)
  
  # Rename column names to be more descriptive + formatting
  colnames(officials) <- c("Name", "Position", "Party", "Email", "Phone", "Photo")
  
  return(officials)
  
}

GetState <- function(my.address, my.api.key) {
  # Query parameters
  query.params <- list(key = my.api.key, address = my.address)
  
  # Requesting and parsing the data
  response <- GET(base.civic.url, query = query.params)
  body <- content(response, "text")
  data <- fromJSON(body)
  
  return(data$normalizedInput$state)
}
