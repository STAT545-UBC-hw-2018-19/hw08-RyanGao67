
library(tidyverse)
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(shinydashboard)
library(shinyjs)
library(colourpicker)

bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

# ui part
ui <- fluidPage(

  # Feature 7: If you know CSS, add CSS to make your app look nicer.
  # Hint: Add a CSS file under www and use the function
  # includeCSS() to use it in your app
  useShinyjs(),
  tags$head(includeCSS("www/style.css")),

  div(class = "Header h1",
      titlePanel("BC Liquor price app",
                 windowTitle = "BCL app"),
      em(
        span("Created by Tian for STAT547M"),br()
      )
  ),


  # sidebar
  sidebarLayout(
    sidebarPanel(

      # Feature 2: Add an image of the BC Liquor Store to the UI.
      # Hint: Place the image in a folder named www,
      # and use img(src = "imagename.png") to add the image.
      img(src = "bc.png", width = "100%"),


      # Feature 4: Add parameters to the plot.
      # Hint: You will need to add input functions
      # that will be used as parameters for the plot.
      # You could use shinyjs::colourInput() to let
      # the user decide on the colours of the bars in the plot.
      div(class="h1",
      colourInput("bar",
                   "You can choose whatever color you like to fill your plot",
                   value = "red"),
      # To make room to indicate the other functions
      br()
      ),

      # This is to determine the number of lines shown in table,
      # if there are too many lines in the return result
      div(class="h1",
      numericInput(
        "rowsToShow",
        "You can specify the maximum number of lines in table",
        value = 3,
      )
      ),
      # To make room to indicate the other functions
      br(),

      # Feature 1:Add an option to sort the results table by price.
      # Hint: Use checkboxInput() to get TRUE/FALSE values from the user.
      div(class="h1",
      checkboxInput(
        "sort",
        "Check this to sort the result by price",
        value = FALSE,
        width = "500"
      ),
      # To make room to indicate the other functions
      br()
      ),

      div(class="h1",
      sliderInput("priceInput",
                  "Select your desired price range.",
                  min = 0,
                  max = 100,
                  value = c(15, 30),
                  pre="$"),
      # To make room to indicate the other functions
      br(),


      radioButtons("typeInput",
                   "Select your alcoholic beverage type.",
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE"),
      # To make room to indicate the other functions
      br(),


      selectInput("country",
                  "only show the selected countries",
                  sort(unique(bcl$Country)),
                  selected = "CANADA")
      )

    ),


    # Panel
    mainPanel(
      h4("You can choose to view the plot or the table"), br(),
      # Feature 6: Place the plot and the table in separate tabs.
      # Hint: Use tabsetPanel() to create an interface with multiple tabs.
      tabsetPanel(
        tabPanel("Graph",
                 plotOutput("price_hist")
                 ),
        tabPanel("Table",
                 DT::dataTableOutput("bcl_data"))
      )
    )

  )
)


# server part
server <- function(input, output) {
  observe(print(input$priceInput))


  bcl_filtered <- reactive({
    # If there's no data after filtering,
    # return NULL
    if(is.null(input$country))return(NULL)

    bcl %>%
      filter(Price < input$priceInput[2],
             Price > input$priceInput[1],
             Type == input$typeInput,
             Country == input$country)
  })

  output$price_hist <- renderPlot({
    if(is.null(bcl_filtered())){
      return()
    }
    bcl_filtered() %>%
      ggplot(aes(Price)) +
      geom_histogram(fill=input$bar)
  })


# Feature3: Use the DT package to turn the current results table
# into an interactive table.
# Hint: Install the DT package, replace tableOutput() with
# DT::dataTableOutput() and replace renderTable() with
# DT::renderDataTable().
  output$bcl_data <- DT::renderDataTable({
    if(input$rowsToShow <= 0){return(NULL)}

    if(input$sort==TRUE){
      bcl_filtered() %>%
        arrange(desc(Price)) %>%
        head(input$rowsToShow)
    }else{
      bcl_filtered() %>%
        head(input$rowsToShow)
    }
  })
}


shinyApp(ui = ui, server = server)
