# Shiny SSB

options(scipen=10000) #I hate scientific notation

#Set package versions
#library("checkpoint") #Checkpoint assures us that we use the same package versions
#checkpoint("2019-01-21") #As they were at the date set in this function. i.e "2019-01-21"

#This is the app!
library(shiny) 
library(shinythemes)
library(shinyWidgets) #For fancy dropdown menu

#Other packages
library(tidyverse) #For data wrangling and plotting
library(here) # allows us to use relative file paths, see readme or simulations doc
library(stringr) #To destring strings
library(readr) #To do some text stuff
library(DT) #For data table

#Read data frames
df_joined_long <- readRDS(here("data/processed", "df_joined_long.rds"))
#df_joined_wide <- readRDS(here("data/processed", "df_joined_wide.rds"))

################################################################################

# Define User Interface
ui <- fluidPage(
        
        # Choose theme
        theme = shinytheme("yeti"),
        
        # Application title
        titlePanel("Key Norwegian Indicators in the Four Largest Cities"),
        
        # Sidebar layout, meaning choices at left, output at right
        sidebarLayout(
                
                #First part of UI, what goes in the sidebar    
                sidebarPanel(
                        
                        # Custom plot title 
                        textInput("title", "Provide your own plot title:", "Home Transfers and Average Home Prices"),
                        
                        #Use dropdown with select all feature. NB selectInput good alternative, but w/o "all" option
                        pickerInput(inputId = "selected_vars",
                                    label = "Variables to plot:", 
                                    choices = c("Number of unemployed" = "reg_unemployed",
                                                "Number of home transfers" = "home_transfers", 
                                                "Total transfer value in 1000 NOK" = "trans_val_in_1000",
                                                "Average home transfer price" = "ave_home_price",
                                                "Crude oil prices" = "oil_price",
                                                "Inhabitants" = "inhabitants"),
                                    selected = c("home_transfers", "ave_home_price"),
                                    options = list(`actions-box` = TRUE),
                                    multiple = TRUE),
                        
                        #Select date range to plot
                        sliderInput("date", "Custom date range:", 
                                    value = c(min(df_joined_long$date), max(df_joined_long$date)), 
                                    timeFormat = "%Y-%m-%d",
                                    min = min(df_joined_long$date), 
                                    max = max(df_joined_long$date)),
                        
                        #Add conditional panel if inhabitants (for age)
                        conditionalPanel(
                                condition = "input.selected_vars.indexOf('inhabitants') > -1",
                                sliderInput("age_range", "Age Range:",
                                            value = c(30, 67),
                                            min = min(df_joined_long$age, na.rm = TRUE), 
                                            max = max(df_joined_long$age, na.rm = TRUE)
                                )
                        ),
                        
                        #Select region i.e. Oslo, Bergen, Trondheim and Stavanger
                        checkboxGroupInput("selected_region", "Choose cities to plot:",
                                           choices = c("Oslo", "Bergen", "Stavanger", "Trondheim"),
                                           selected = c("Oslo", "Bergen", "Stavanger", "Trondheim")),
                        
                        tags$small("Visualization tools:"), #Common headline for all checkbox inputs
                        
                        #Add checkboxes for log-transformation, point, lines and smoothing function
                        checkboxInput("log", "Log transformation", value = TRUE),
                        checkboxInput("point", "Dot plot", value = TRUE),
                        checkboxInput("line", "Line plot", value = FALSE),
                        checkboxInput("smooth", "Add line of best fit", value = FALSE),
                        
                        #Add conditional panel if unemp or inhabitants (for sex)
                        conditionalPanel(
                                condition = "input.selected_vars.indexOf('reg_unemployed') > -1 || input.selected_vars.indexOf('inhabitants') > -1",
                                radioButtons("selected_population", "Population or by gender",
                                             choices = levels(df_joined_long$sex),
                                             selected = "Population")
                        )
                        
                ),
                
                # Second part of UI, what goes in the main panel
                mainPanel(
                        #We will have multiple tabs for different information input
                        tabsetPanel(type = "tabs", 
                                    
                                    #First tab is for plotting
                                    tabPanel("Plot",
                                             uiOutput("plot_ui"),
                                             br(), #Add some space
                                             downloadButton("downloadPlot", label = "Download the plot") #Can be moved to side panel
                                    ),
                                    
                                    #Second tab is for the data table showing the raw data
                                    tabPanel("Table",
                                             DT::dataTableOutput(outputId = "dataTable"),
                                             br(),
                                             downloadButton("downloadData", label = "Download chosen data")) ,
                                    
                                    #Third tab for references and text
                                    tabPanel("References",
                                             h3("Add some text"))# , add content
                        )# End of tabsetPanel
                )#End of main panel
                
                
        ) #End of sidebar layout
) # End of fluidpage

################################################################################

# Define server logic to make output. This is where we generate our plots and data etc. 
server <- function(input, output) {
        
        #CREATING DATA
        
        #Reactive dataset which serves as foundation for all plots and data tables. 
        df_long_sub <- reactive({
                req(input$selected_vars) #Require non-empty vector of inputs to produce plot
                #Filtering on variables and dates
                #in_vec <- c("inhabitants", "reg_unemployed")
                df_sub <- df_joined_long %>%
                        filter(contents %in% input$selected_vars) %>%
                        filter(date>=input$date[1] & date<=input$date[2]) %>%
                        filter(region %in% input$selected_region | region == "all") %>%
                        filter(if( any( input$selected_vars %in% c("inhabitants", "reg_unemployed") ) ) 
                                (sex == input$selected_population | is.na(sex)) else TRUE)
                
                if(any( input$selected_vars %in% c("inhabitants") ))
                        df_sub <- df_sub %>% 
                        filter(between(age, input$age_range[1], input$age_range[2]) | is.na(age)) %>%
                        group_by(region, sex, contents, date) %>%
                        summarise(value = sum(value)) %>%
                        ungroup()  %>%
                        mutate(
                                subset_age = ifelse( contents == "inhabitants", paste(input$age_range[1],"-",input$age_range[2]), NA)
                        )
                df_sub
                 
           
        })
        
        # PLOTTING MAIN FIGURE
        
        #Make a count of numbers of plots to adjust height (one plot per variable)
        plotCount <- reactive({
                req(input$selected_vars)
                length(input$selected_vars)
        })
        
        #Create a variable with custom plot height
        plotHeight <- reactive(200 * plotCount())
        
        #Make plot
        output$fullPlot <- renderPlot ({
                
                #Make conditional plot based on log value or value
                ifelse(input$log, 
                       p <- ggplot(data = df_long_sub(), aes(x = date, y = log(value), colour = region)),
                       p <- ggplot(data = df_long_sub(), aes(x = date, y = value, colour = region))
                )
                
                # Add facets and title, all should have this
                p <- p + facet_grid(contents~., scales = "free_y") + 
                        ggtitle(input$title)
                
                # conditionally add geom point
                if (input$point) {
                        p <- p + geom_point(aes(shape = region))
                }
                
                # conditionally add line plot
                if (input$line) {
                        p <- p + geom_line()
                }
                
                # conditionally add  linear smoothing function
                if (input$smooth) {
                        p <- p + geom_smooth(method = "lm")
                }       
                
                p #Actually produces the plot save to output$fullPlot
        })
        
        #Create object that takes plot and adjusts height
        output$plot_ui <- renderUI({
                plotOutput("fullPlot", height = plotHeight())
        })
        
        #Create downloadable plot that matches download button
        output$downloadPlot <- downloadHandler(
                filename = "plot.png",
                content = function(file) {
                        ggsave(file, device = "png")
                }
        )
        
        # DATA TABLE
        
        #Create raw data table and make it downloadable 
        output$dataTable <- DT::renderDataTable(
                DT::datatable(data = df_long_sub(), 
                              options = list(pageLength = 10), 
                              rownames = FALSE)
        )
        
        #Create a download handler for downloading the subsetted data set
        output$downloadData <- downloadHandler(
                filename = "data.csv",
                content = function(file){
                        write.csv(df_long_sub(), file)
                }
        )
        
} #End of server function



# Run the application 
shinyApp(ui = ui, server = server)

