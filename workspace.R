library(shiny)
library(tercen)
library(dplyr)
library(tidyr)
library(shiny)
library(tercen)
library(tidyverse)
library(ggrepel)
library(ggsci)

set.seed(42)

############################################
#### This part should not be included in ui.R and server.R scripts
getCtx <- function(session) {
  ctx <- tercenCtx(workflowId = "8f17d834dda49eba43ac822ed600aa7b",
                   stepId = "706ac7cf-8dd6-41a9-83a7-b5802ea67031")
  return(ctx)
}
####
############################################

ui <- shinyUI(fluidPage(
  
  titlePanel("Boxplot"),
  
  sidebarPanel(
    sliderInput("plotWidth", "Plot width (px)", 200, 2000, 500),
    sliderInput("plotHeight", "Plot height (px)", 200, 2000, 500),
    textInput("xlab", "x axis label", ""),
    textInput("ylab", "y axis label", ""),
    checkboxInput("labs", "Apply labels",0),
    checkboxInput("wrap", "Wrap panel grid", 0),
    checkboxInput("fixed", "Axes equal for panels",0)
  ),
  
  mainPanel(
    uiOutput("reacOut")
  )
  
))

server <- shinyServer(function(input, output, session) {
  
  dataInput <- reactive({
    getValues(session)
  })
  
  output$reacOut <- renderUI({
    plotOutput(
      "main.plot",
      height = input$plotHeight,
      width = input$plotWidth
    )
  }) 
  
  output$main.plot <- renderPlot({
    
    df <- dataInput()

    plt = ggplot(df, aes(x = .x, y = .y, colour = colors, label = labels)) +
      labs(x = input$xlab, y = input$ylab)
    
    if(all(is.numeric(df$colors))){
      plt = plt + scale_colour_viridis_c()
    } else {
      plt = plt + scale_colour_jama()
    }

    if(input$labs & !all(is.na(df$labels))) {
      plt <- plt + geom_point() + geom_text_repel()
    }
    else if(input$labs & !all(is.na(df$sizes))){
      plt = plt + geom_point(aes(size = sizes))
    }
    else{
      plt = plt + geom_point()
    }
    
    if (!input$wrap){
      plt <- plt + facet_grid(rnames ~ cnames, scales = ifelse(input$fixed, "fixed", "free"))
    } else {
      plt = plt + facet_wrap(~ rnames + cnames, scales = ifelse(input$fixed, "fixed", "free"))
    }
    plt = plt + theme_bw()
    plt
  })
  
})

getValues <- function(session){
  #browser()
  ctx <- getCtx(session)
  df <- ctx %>% select(.x, .y, .ri, .ci) %>%
    group_by(.ri)

  colors <- 0
  if(length(ctx$colors)) colors <- ctx$select(ctx$colors[[1]])[[1]]
  if(!all(is.numeric(colors))) colors = as.factor(colors)
  
  labels <- NA
  sizes = NA
  if(length(ctx$labels)) tcn.labels <- ctx$select(ctx$labels[[1]])[[1]]
  if (!all(is.numeric(tcn.labels))) {
    labels = as.factor(tcn.labels)
  } else {
    sizes = tcn.labels
  }
  
  
  df = df %>% data.frame(labels, colors, sizes)
  
  cnames = ctx$cselect()[[1]]
  
  rnames = ctx$rselect()[[1]]
  df = df %>% 
    mutate(colors = colors, labels = labels) %>%
    left_join(data.frame(.ri = 0:(length(rnames)-1), rnames), by = ".ri") %>%
    left_join(data.frame(.ci = 0:(length(cnames)-1), cnames), by = ".ci")
  
  return(df)
}

runApp(shinyApp(ui, server))  