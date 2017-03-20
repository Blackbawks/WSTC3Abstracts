
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinythemes)
library(xtable)
library(shinyjs)


X <- read.csv('AbstractsV2.csv')


X$ids <-iconv(paste(as.character(X$Last),', ',as.character(X$First),sep=''),'latin1','UTF-8')
X$Affiliation <- iconv(as.character(X$Affiliation),'latin1','UTF-8')
X$Country <- iconv(as.character(X$Country),'latin1','UTF-8')


shinyUI(
  navbarPage(
    title = img(src="Logo.png",width='200px'),
    windowTitle = 'WSTC3 Abstracts',
    theme=shinytheme("spacelab"),

    tags$head(
      tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Roboto:100,500');")),
      tags$style(type="text/css", ".navbar {height: 90px;}")
      ),
                   
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      useShinyjs(), 
        selectInput("Presenter", label = "Presenter:",
                    choices = c(as.character(X$ids))),
        
        hr(),
        
        h3('Filter presenter by:'),
      
        radioButtons("filter", label = NULL, choices = c("Country", "Affiliation","Topic", "None"), inline=TRUE, selected='None'),
      
      
        selectInput("Country", label = "Country:", selected = 'Australia ',
                    choices = c(sort(as.character(X$Country)))),
        
        
        selectInput("Affiliation", label = "Affiliation:",
                    choices = c(sort(as.character(X$Affiliation)))),
      
        selectInput("Topic", label = "Topic:",
                  choices = c(sort(unique(as.character(X$Topic))))),
      
        hr(),
        img(src='Blackbawks.png',width = '25%'),
        HTML('<span>Created by: <a href="http://blackbawks.net">Black bawks data science ltd.</a></span>'),
        HTML('<p><a href="mailto:grwhumphries@blackbawks.net">Click here</a> to report a bug</p>')
        
        
    ),

    # Show a plot of the generated distribution
    mainPanel(
      headerPanel(
        h1("Interactive WSTC3 Abstract Guide", style="font-family:Roboto; font-weight:100")
      ),
      tableOutput('Person'),
      tableOutput('Info'),
      HTML('<h2> Title </h2>'),
      htmlOutput('TitleDat'),
      HTML('<h2> Abstract </h2>'),
      htmlOutput('AbstractDat'),
      hr()
    )
  )
))
