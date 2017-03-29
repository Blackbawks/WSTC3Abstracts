
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinythemes)
library(xtable)
library(shinyjs)
library(dplyr)
library(readxl)


#X <- read_excel("Schedule_FINAL.xlsx", sheet=3)[1:128,]
#Y <- tbl_df(read_excel("Schedule_FINAL.xlsx",sheet=1)[1:284,1:10])
X <- readRDS("Abstracts.rds")
Y <- tbl_df(readRDS("Schedule.rds"))

X$ids <-paste(as.character(X$Last),', ',as.character(X$First),sep='')
X$Affiliation <- as.character(X$Affiliation)
X$Country <- as.character(X$Country)


shinyUI(
  navbarPage(
    title = img(src="Logo.png",width='200px'),
    windowTitle = 'WSTC3 Abstracts',
    theme=shinytheme("spacelab"),
    selected = "Home",
    tags$head(
      tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Roboto:100,500');")),
      tags$style(type="text/css", ".navbar {height: 90px;}")
      ),
    
    tabPanel("Home",
             mainPanel(
               headerPanel(
                 h1("Welcome to the Interactive WSTC3 Abstract Guide", style="font-family:Roboto; font-weight:100; text-align:center")
               ),
               hr(),
               h2("Click the above links in the header to either SEARCH BY PRESENTER, or VIEW THE SCHEDULE"),
               HTML("<p> You can also check out <a href='http://www.seabirds.net'>Seabirds.net</a> for more information ")
             )
             
             ),
    tabPanel("Search by Presenter",
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
            tableOutput('Time'),
            HTML('<h2> Title </h2>'),
            htmlOutput('TitleDat'),
            HTML('<h2> Abstract </h2>'),
            htmlOutput('AbstractDat'),
            hr()
          )
      
        )
    ),  ## tabPanel END

    tabPanel("Schedule",
             
             sidebarLayout(
               sidebarPanel(
                 useShinyjs(), 
                 h3('Filter by:'),
                 
                 radioButtons("filter2", label = NULL, choices = c("Day","Session","None"), inline=TRUE, selected='None'),
                 
                 
                 selectInput("Day", label = "Day:", selected = 'April 12 ',
                             choices = c('April 12','April 13', 'April 14')),
                 
                 selectInput("Session", label = "Session:", selected = 'Climate',
                             choices = c(sort(as.character(Y$Topic)))),
                 

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
                 tableOutput("Schedule")
               )
               
             )
             
             )
    
))
