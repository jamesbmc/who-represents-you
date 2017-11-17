# Libraries for querying APIs and converting to usable data
library(httr)
library(jsonlite)

# Libraries for data wrangling
library(dplyr)
library(tidyr)
library(stringr)

# Library to use shiny
library(shiny)

# Getting functions/variables from helper files
source("api-keys.R")
source("civic-info.R")
source("propublica.R")

# Initialize shiny server
server <- function(input, output) {
  # Returning which state the address comes from - for use in propublica queries
  state <- reactive({
    if (input$address != "") {
      return(GetState(input$address, civic.key))
    }
  })
  
  # Information on house representatives of a given state
  house.info <- reactive({
    if (input$address != "") {
      return(GetHouseInfo(state(), pro.key))
    }
  })
  
  # Render data table about all representatives of an address
  output$table <- renderDataTable({
    if (input$address != "") {
      table <- GetRepInfo(input$address, civic.key)
      return(table)
    }
  })
  
  # House representatives by gender
  output$gender.plot <- renderPlot({
    if (input$address != "") {
      # A vector with numbers of male and female house representatives for use in barplot
      gender.num <- c(nrow(house.info() %>% 
                            filter(gender == "M")), 
                      nrow(house.info() %>% 
                            filter(gender == "F"))
      )
    
      return(barplot(gender.num, horiz = T, xlab = "# of Representatives", names.arg = c("Males", "Females"), main = "Representatives by Gender",
                    xlim = c(0, max(gender.num) + 5)))
    }
  })
  
  # House representatives by party
  output$party.plot <- renderPlot({
    if (input$address != "") {
      # A vector with numbers of Democrat and Republican house representatives for use in barplot
      party.num <- c(nrow(house.info() %>% 
                              filter(party == "D")), 
                      nrow(house.info() %>% 
                              filter(party == "R"))
      )
    
      return(barplot(party.num, horiz = T, xlab = "# of Representatives", names.arg = c("Democrats", "Republicans"), main = "Representatives by Party",
                    xlim = c(0, max(party.num) + 5)))
    }
  })
  
  # Data about a randomly selected house representative
  output$rep.info <- renderText({
    if (input$address != "") {
      # Generate a random number (1-number of house representatives)
      rand.num <- runif(1, 1, nrow(house.info()))
    
      # Select a random representative
      rep.id <- house.info()$id[rand.num]
    
      # Get personal and voting info about that representative
      house.rep.info <- GetHouseRepInfo(rep.id, pro.key)
      house.rep.voting <- GetHouseRepVoting(rep.id, pro.key)
    
      # Determine the rep age from his or her birth date
      rep.age <- (as.Date(Sys.Date()) - as.Date(house.rep.info$date_of_birth)) / 365
      rep.age.num <- floor(as.numeric(rep.age))
    
      # Turn rep voting record into a percentage agreement with majority
      rep.voting <- round(nrow(filter(house.rep.voting, agree == T)) / nrow(house.rep.voting) * 100, 0)
    
      # Creating rep full name from first, middle, last name
      rep.full.name <- paste(house.rep.info$first_name, house.rep.info$middle_name, house.rep.info$last_name)
    
      stats <- paste0(rep.full.name, " is ", rep.age.num, " years old. Of the last ", nrow(house.rep.voting), " votes, this representative was in accordance with the majority ", 
                    rep.voting, "% of the time.")
    }
  })
}