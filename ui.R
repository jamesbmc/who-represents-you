
ui <- fluidPage(
  titlePanel("Who Represents You?"),
  
  # Text input the report is generated from
  textInput("address", label = "Please enter a valid address", value = "400 Broad St, Seattle"),
  
  # Intro paragraph
  h3("Your Representatives"),
  p("Based on the address you entered, these are your political representatives. This report was generated using information from the",
    a("ProPublica API", href = "https://projects.propublica.org/api-docs/congress-api/"), "and the", 
    a("Google Civic Information API", href = "https://developers.google.com/civic-information/"),
    "Here is a summary of who represents the address entered, from national down to local."),
  
  # Data table of all representatives at an input address
  dataTableOutput("table"),
  
  # Intro to house representatives
  h3("House of Representatives"),
  p("Now let's take a look at all of the House representatives (not Senate!) for your input address. Here is a breakdown by gender and political party:"),
  
  # Barplot of house representatives by gender
  plotOutput("gender.plot"),
  
  # Barplot of house representatives by party affiliation
  plotOutput("party.plot"),
  
  # A section to delve into one house representative's voting record
  h3("A Closer Look at One House Representative"),
  
  # All the data about a randomly selected house representative
  textOutput("rep.info"), 
  
  # Empty space to separate out source info from project
  p(),
  
  # Reference to my code
  p("Code for this project can be found", a("here", href = "https://github.com/jamesbmc/who-represents-you"))
)