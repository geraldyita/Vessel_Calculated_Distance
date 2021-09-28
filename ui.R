# Import Libraries -------------------------------------------------------------
library(shiny)
library(shiny.semantic)
library(dplyr)
library(tidyverse)
library(geosphere)
library(leaflet)

# Data Import & Sort ------------------------------------------------------------------
df <-readRDS("ships.rds")

vassels_types <- sort(unique(df$ship_type))

#user interface
ui <- semanticPage(
    title = "Project",
    
    # Main Title -----------
    h1("Max Distance Of Vessels"),
    sidebar_layout(
        sidebar_panel(
            p("Find out the longest distance traveled by a vessel!"),
            br(),
            
            #Dropdown Vessel Type------------
            p(strong("First:") ,"Select Vessel Type"),
            dropdown_input("type_dropdown", 
                           vassels_types,
                           default_text = "",
                           value = "Cargo", 
                           type = "selection fluid"),
            br(),
            
            #Dropdown Vessel namee------------
            p(strong("Second:") ,"Select Vessel Name"),
            
            dropdown_input("name_dropdown", 
                           choices = "",
                           value = NULL, 
                           type = "selection fluid"),
            br(),
            
            #Distance calculated
            div(class = "ui horizontal divider", icon("compass outline"), 
                "Max. distance obtained"),
            h4(align = "center", textOutput("MaxDistance"))
            ),
        
        main_panel(
            h3("Map location"),
            leafletOutput("map")
        )
    )
)