
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(xtable)
library(readxl)
library(dplyr)

X <- readRDS("Abstracts.rds")
Y <- readRDS("Schedule.rds")
#X <- read.csv('AbstractsV2.csv')

X$ids <- paste(as.character(X$Last),', ',as.character(X$First),sep='')
X$Affiliation <- as.character(X$Affiliation)
X$Country <- as.character(X$Country)
X$First <- as.character(X$First)
X$Last <- as.character(X$Last)
X$Title <- as.character(X$Title)
X$Abstract <- as.character(X$Abstract)
X$Topic <- as.character(X$Topic)


X <- X[order(X$Last),]




Y$fullname <- paste(Y$First, Y$Last, sep=" ")
Y$day <- paste("April", format(strptime(Y$Date,format="%Y-%m-%d"),"%d"), sep=" ")
Y$Time<- round(Y$Time,units='min')
Y$UTC <- format(Y$Time,"%H:%M:%S")


shinyServer(function(input, output, session) {

  
  observeEvent(input$filter, {
    if(input$filter == 'Country'){
      shinyjs::enable('Country')
      shinyjs::disable('Affiliation')
      shinyjs::disable('Topic')
      
    }else if(input$filter == 'Affiliation'){
      shinyjs::enable('Affiliation')
      shinyjs::disable('Country')
      shinyjs::disable('Topic')
      
    }else if(input$filter == 'Topic'){
      shinyjs::enable('Topic')
      shinyjs::disable('Country')
      shinyjs::disable("Affiliation")
      
    }else if(input$filter == 'None'){
      shinyjs::disable("Country")
      shinyjs::disable("Affiliation")
      shinyjs::disable("Topic")
      updateSelectInput(session, "Presenter",
                        choices = c(X$ids)
      )
    }
    
  })
  
  
  
  observe({
    if(input$filter == 'Country'){
      y <- input$Country
      
      values <- X[which(X$Country == y),]
      updateSelectInput(session, "Presenter",
                        choices = c(values$ids)
      )
    }else if(input$filter == 'Affiliation'){
      y <- input$Affiliation
      
      values <- X[which(X$Affiliation == y),]
      updateSelectInput(session, "Presenter",
                        choices = c(values$ids)
      )
    }else if(input$filter == 'Topic'){
      y <- input$Topic
      
      values <- X[which(X$Topic == y),]
      updateSelectInput(session, "Presenter",
                        choices = c(values$ids)
      )
    }
    
  })
  
  
  
  output$Person <- renderTable({
    Dat <- X[which(X$ids == input$Presenter),][1,]
    Tab <- data.frame(First=Dat$First, Last=Dat$Last, Email = Dat$Email, Country = Dat$Country)
    xtable(Tab)
  })
  
  output$Info <- renderTable({
    Dat <- X[which(X$ids == input$Presenter),]
    if(nrow(Dat) > 1){
      Dat$lab <- c(1:nrow(Dat))
      Tab <- data.frame(Label = Dat$lab, Handle = Dat$Handle, Affiliation = Dat$Affiliation)
    }else{
      Tab <- data.frame(Handle = Dat$Handle, Affiliation = Dat$Affiliation)
    }
  })
  
  output$Time <- renderTable({
    Dat <- X[which(X$ids == input$Presenter),]
    UTCtime <- round(strptime(as.character(Dat$DateTimeUTC),format="%Y-%m-%d %H:%M:%S"),units='min')
    Localtime <- round(strptime(as.character(Dat$LocalTimeUTC),format="%Y-%m-%d %H:%M:%S"),units='min')
    Dat$UTCTm <- paste("April ",as.character(UTCtime$mday)," ",format(UTCtime, "%H:%M"),sep="")
    Dat$LOCTm <- paste("April ",as.character(Localtime$mday)," ",format(Localtime, "%H:%M"),sep="")
    
    if(nrow(Dat) > 1){
      Dat$lab <- c(1:nrow(Dat))
      Tab <- data.frame(Label = Dat$lab, UTC = Dat$UTCTm, "Local Timezone" = Dat$LOCTm, "Offset From UTC" = Dat$Timezone, check.names=FALSE)
    }else{
      Tab <- data.frame(UTC = Dat$UTCTm, "Local Timezone" = Dat$LOCTm, "Offset From UTC" = Dat$Timezone, check.names=FALSE)
    }
    
    
  })
  
  
  
  output$TitleDat <- renderUI({
    Dat <- X[which(X$ids == input$Presenter),]
    
    if(nrow(Dat) > 1){
      Dat$lab <- c(1:nrow(Dat))
      TITLEhtml <- paste('<p><strong>',Dat$lab,'</strong>',Dat$Title,'</p>')
    }else{
      TITLEhtml <- paste('<p>',Dat$Title,'</p>')
    }
    HTML(TITLEhtml)
  })
  
  
  output$AbstractDat <- renderUI({
    Dat <- X[which(X$ids == input$Presenter),]
    
    if(nrow(Dat) > 1){
      Dat$lab <- c(1:nrow(Dat))
      Abshtml <- paste('<p><strong>',Dat$lab,'</strong>',Dat$Abstract,'</p>')
    }else{
      Abshtml <- paste('<p>',Dat$Abstract,'</p>')
    }
    HTML(Abshtml)

  })
  
  
  ########## For the schedule
  
  observeEvent(input$filter2, {
    if(input$filter2 == 'Day'){
      shinyjs::enable('Day')
      shinyjs::disable('Session')
      
    }else if(input$filter2 == 'Session'){
      shinyjs::enable('Session')
      shinyjs::disable('Day')
      
    }else if(input$filter2 == 'None'){
      shinyjs::disable('Session')
      shinyjs::disable("Day")
    }
  })
  
  
  output$Schedule <- renderTable(striped = TRUE,hover=TRUE, expr= {
    Dat <- data.frame(Name = Y$fullname, Handle = Y$Handle, Day = Y$day, UTC = Y$UTC,Topic = Y$Topic, Title = Y$Title,check.names=FALSE)
    
    Dat <- tbl_df(Dat) %>% filter(!is.na(Title))
    
    
    if(input$filter2 == 'Session'){
      Dat <- tbl_df(Dat)
      Dat <- Dat %>% filter(Topic == input$Session)
      Dat <- data.frame(Dat)
    }else if(input$filter2 == "Day"){
      Dat <- tbl_df(Dat)
      Dat <- Dat %>% filter(Day == input$Day)
      Dat <- data.frame(Dat)
    }else if(input$filter == "None"){
      Dat <- data.frame(Dat)
    }
    
    
    
    
  })
  
  
  

})
