library(shiny)
library(tercen)
library(tidyverse)
library(ggrepel)
library(ggsci)
library(viridis)
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


