# Setup

library(RSocrata)
library(tidyverse)
library(shiny)
library(DT)

# Data

cc_2018 <- read.socrata("https://data.cityofchicago.org/resource/6zsd-86xi.json?$where=date between '2018-01-01' and '2018-04-01'")

# Define UI
ui <- fluidPage(
  
  # Sidebar layout with input and output definitions 
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      
      # Select crime type
      selectInput(inputId = "type", 
                  label = "Primary type",
                  choices = c("ASSAULT", "BATTERY", "CRIMINAL DAMAGE", "DECEPTIVE PRACTICE", "NARCOTICS", "OTHER OFFENSE", "THEFT"), 
                  selected = "ASSAULT"),
      # Select smooth method
      selectInput(inputId = "method", 
                  label = "Smooth method",
                  choices = c("loess", "lm"), 
                  selected = "loess")
    ),
    
    # Outputs
    mainPanel(
      plotOutput(outputId = "scatterplot"),
      br(), br(),
      dataTableOutput(outputId = "table")
    )
  )
)

# Define server function
server <- function(input, output) {
  
  # Create scatterplot object
  output$scatterplot <- renderPlot({
    cc_2018 %>%
      filter(as.Date(date) < "2018-04-01") %>%
      filter(primary_type == input$type) %>%
      group_by(date = as.Date(date)) %>%
      summarise(total = n()) %>%
      ggplot() +
      geom_line(aes(x = date, y = total)) +
      geom_smooth(aes(x = date, y = total), method = input$method) +
      ylim(0, 250)
  })
  
  # Create data table
  output$table <- renderDataTable({
    datatable(data = cc_2018 %>% select(id, date, primary_type), 
              options = list(pageLength = 5), rownames = FALSE)
  })
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)