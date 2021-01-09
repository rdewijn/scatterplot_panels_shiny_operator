library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Scatterplot"),
  
  sidebarPanel(
    sliderInput("plotWidth", "Plot width (px)", 200, 2000, 500),
    sliderInput("plotHeight", "Plot height (px)", 200, 2000, 500),
    textInput("xlab", "x axis label", ""),
    textInput("ylab", "y axis label", ""),
    checkboxInput("labs", "Add text labels")
  ),
  
  mainPanel(
    uiOutput("reacOut")
  )
  
))