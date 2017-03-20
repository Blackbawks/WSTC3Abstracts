
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(xtable)

X <- read.csv('AbstractsV2.csv')

X$ids <- iconv(paste(as.character(X$Last),', ',as.character(X$First),sep=''),'latin1','UTF-8')
X$Affiliation <- iconv(as.character(X$Affiliation),'latin1','UTF-8')
X$Country <- iconv(as.character(X$Country),'latin1','UTF-8')
X$First <- iconv(as.character(X$First),'latin1','UTF-8')
X$Last <- iconv(as.character(X$Last),'latin1','UTF-8')
X$Title <- iconv(as.character(X$Title),'latin1','UTF-8')
X$Abstract <- iconv(as.character(X$Abstract),'latin1','UTF-8')
X$Topic <- iconv(as.character(X$Topic),'latin1','UTF-8')

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
  

})
