
ui <- fluidPage(
  titlePanel("Who Represents You?"),
  
  # Text input the report is generated from
  textInput("address", label = "Please enter a valid address", value = "400 Broad St, Seattle"),
  
  # Intro paragraph, in markdown for easy usage of bolding/italics
  includeMarkdown("./markdown/intro.md"),
  
  # Data table of all representatives at an input address
  dataTableOutput("table"),
  
  # Another markdown paragraph to intro the house representatives section
  includeMarkdown("./markdown/house.md"),
  
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