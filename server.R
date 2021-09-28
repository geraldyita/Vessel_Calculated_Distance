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

# Server
server <- function(session, input, output) {
    
    #Observe Event for Vessel Name
    observeEvent(
        input$type_dropdown, 
        update_dropdown_input(
            session,
            "name_dropdown",
            choices = sort(unique(df$SHIPNAME[df$ship_type == input$type_dropdown]))
        )
    )
    
    df_distances <- reactive({
        
        df_vessel<-filter(df, SHIPNAME == input$name_dropdown) 
        
        test <- select(df_vessel, "LAT", "LON", "DATETIME")
        
        # Se crea vector vacio
        distances <- c()
        # Ciclo For para buscar en el numero de filas
        for (m in 1:nrow(test)){
            # Ciclo For para buscar en el numero de columnas
            for (n in 1:1){
                # Condicional if para comprobar si no es igual al numero total de filas
                if (m != nrow(test)){
                    # toma los valores de m para n y n+1, luego los de m+1 para n y n+1 y calcula la distancias
                    d <- distm(c(test[m,n+1], test[m,n]), c(test[m+1,n+1], test[m+1,n]), fun = distHaversine)[1,1]
                    #guarda las distancias en el vector distances
                    distances <- c(distances, d)
                } else {
                    #cuando la condicion anterior no se cumpla, se guarda un valor de 0 en el vector
                    d <- 0
                    distances <- c(distances, d)
                }
            }
        }
        df_distances <- try(cbind(test, distances), silent = TRUE)
        df_distances
    })
    
    output$MaxDistance <- renderText({
        
        #verifica que df_distances() existe
        if(class(df_distances()) == 'data.frame') {
            #guarda el valor mayor de la columna distancia en la variable MaxDistance y luego la imprime
            MaxDistance <- max(df_distances()[,4])
            paste0(round(MaxDistance,2), " meters")
        } else {
            paste0("---Loading Data---")
        }
    })
    
    output$map <- renderLeaflet({
        
        if(class(df_distances()) == 'data.frame'){
            n <- which.max(df_distances()[,4])
            leaflet() %>%
                addProviderTiles(providers$Stamen.TonerLite,
                                 options = providerTileOptions(noWrap = TRUE))%>% 
                addMarkers(lng=df_distances()[n,2], lat=df_distances()[n,1], popup="Place A") %>%
                addMarkers(lng=df_distances()[n+1,2], lat=df_distances()[n+1,1], popup="Place B")
        }
    })
    
}