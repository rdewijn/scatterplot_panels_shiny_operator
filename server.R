library(shiny)
library(tercen)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
set.seed(42)

############################################
#### This part should not be modified
getCtx <- function(session) {
  # retreive url query parameters provided by tercen
  query <- parseQueryString(session$clientData$url_search)
  token <- query[["token"]]
  taskId <- query[["taskId"]]
  
  # create a Tercen context object using the token
  ctx <- tercenCtx(taskId = taskId, authToken = token)
  return(ctx)
}
####
############################################

shinyServer(function(input, output, session) {
  
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
    
    values <- dataInput()
    
    df <- values$data
    in.col <- values$colors
    in.lab <- values$labels
    
    input.par <- list(
      xlab = input$xlab,
      ylab = input$ylab,
      labs = input$labs
    )
    
    fill.col <- NULL
    if(length(unique(in.col)) > 0) fill.col <- as.factor(in.col)
    labels <- NULL
    if(length(unique(in.lab)) > 0) labels <- as.factor(in.lab)
    
    theme_set(theme_minimal())
    print(labels)
    plt <- ggplot(df, aes(x = .x, y = .y, fill = fill.col, label = labels)) + 
      geom_point() + labs(x = input.par$xlab, y = input.par$ylab, fill = "Legend")
    
    if(input.par$labs) plt <- plt + geom_text_repel()
    if(!is.null(df$cnames)) plt <- plt + facet_wrap(~ cnames + rnames)
    
    plt
    
  })
  
})

getValues <- function(session){
  
  ctx <- getCtx(session)
  
  values <- list()
  
  values$data <- ctx %>% select(.x, .y, .ri, .ci) %>%
    group_by(.ri)
  
  values$colors <- NA
  if(length(ctx$colors)) values$colors <- ctx$select(ctx$colors[[1]])[[1]]
  
  values$labels <- NA
  if(length(ctx$labels)) values$labels <- as.character(ctx$select(ctx$labels[[1]])[[1]])  
  
  values$rnames <- ctx$rselect()[[1]]
  names(values$rnames) <- seq_along(values$rnames) - 1
  values$data$rnames <- values$rnames[as.character(values$data$.ri)]
  
  if(nchar(values$rnames) == 0) values$data$rnames <- values$colors
  
  values$cnames <- ctx$cselect()[[1]]
  names(values$cnames) <- seq_along(values$cnames) - 1
  values$data$cnames <- values$cnames[as.character(values$data$.ci)]
  
  return(values)
}
