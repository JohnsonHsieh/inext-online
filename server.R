# Load packages
library("shiny")
library("shinyIncubator")
library("xtable")
library("markdown")

load('data/ex_data.RData')
data(list='ex_data')
source("iNEXT.R")


shinyServer(function(input, output) {
  tempRD1 <- paste(tempfile(), ".RData", sep="")
  tempRD2 <- paste(tempfile(), ".RData", sep="")
  temphtml <- paste(tempfile(), ".html", sep="") 
  source('sub.R', local = TRUE)
  tol <- 0.1^3
  
  #############################################################################
  # Data setting
  #############################################################################  
  
  loadPaste <- reactive({
    if(input$data_type=="ind"){
      text <- input$copyAndPaste_ind
    } else {
      text <- input$copyAndPaste_sam
    }
    Fun <- function(e){
      temp <- lapply(readLines(textConnection(text)), function(x) scan(text = x, what='char'))
      out <- list()
      out.name <- 0
      for(i in seq_along(temp)){
        out.name[i] <- temp[[i]][1]
        out[[i]] <- as.numeric(temp[[i]][-1])
      }
      names(out) <- t(data.frame(out.name))
      out
    }
    tryCatch(Fun(e), error=function(e){return()})
  })
  
  
  #Get Input data name list
  getDataName <- reactive({
    Fun <- function(e){
      out <- loadPaste()
      out.name <- names(out)
      if(is.na(names(out)[1]) == TRUE) {
        dat <- paste("No data")
        dat
      } else {
        dat <- out
        for(i in seq_along(out)){
          dat[[i]] <- out.name[i]
        }
        dat        
      }    
    }
    tryCatch(Fun(e), error=function(e){return()})
  })
  
  #Select data
  output$choose_dataset <- renderUI({
    dat <- getDataName()
    selectInput("dataset", "Select dataset:", choices = dat, selected = dat[1], multiple = TRUE)
    
  })
  
  
  
  #output$ui_import_ind <- renderUI({
  #  tags$textarea(id="copyAndPaste_ind", rows=5, 
  #                "Girdled 46 22 17 15 15  9  8  6  6  4  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1 \nLogged 88 22 16 15 13 10  8  8  7  7  7  5  4  4  4  3  3  3  3  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1  1  1")  
  #})
  
  #output$ui_import_sam <- renderUI({
  #  tags$textarea(id="copyAndPaste_sam", rows=5, 
  #                "Ants_1500m 200 144 113 79 76 74 73 53 50 43 33 32 30 29 25 25 25 24 23 23 19 18 17 17 11 11 9 9 9 9 6 6 5 5 5 5 4 4 3 3 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 \nAnts_2000m 200 80 59 34 23 19 15 13 8 8 4 3 2 2 1")
  #})
  
  
  
  selectedData <- reactive({
    out <- loadPaste()
    selected <- 1
    dataset <- list()
    for(i in seq_along(input$dataset)){
      selected[i] <- which(names(out)==input$dataset[i])
    }
    for(i in seq_along(selected)){
      k <- selected[i]
      dataset[[i]] <- out[[k]]
    }
    names(dataset) <- input$dataset
    return(dataset)    
  })
  
  #Test function
  #output$datanames <- renderPrint(
  #  selectedData()
  #)
  
  
  #############################################################################
  # Data Summary
  #############################################################################  
  
  output$dataview <- renderPrint({  
    dataset <- selectedData()
    #names(dataset) <- input$dataset
    lapply(dataset, function(dat) sort(subset(dat, dat>0), dec=TRUE))    
  })
  
  #Show basic data information
  output$summary <- renderPrint({
    dataset <- selectedData()
    #names(dataset) <- input$dataset
    #dataset <- loadPaste()
    if(input$data_type == "ind") {
      out <- lapply(dataset, summary.Ind)  
    } else if(input$data_type == "sam"){
      out <- lapply(dataset, summary.Sam)
    }  
    saveRDS(out, tempRD1) 
    out
  })  
  
  #Download summary data  
  output$dlsummary <- downloadHandler(
    filename = function() { paste('Info_', Sys.Date(), '_[iNEXT].csv', sep='') },
    content = function(file) { 
      out <- readRDS(tempRD1)
      saveList2csv(out, file)      
    }
  )
  
  #############################################################################
  # Slider control
  #############################################################################  
  
  output$set_endpt <- renderUI({
    
    dataset <- selectedData()
    #dataname <- getDataName()
    size <- 0
    if (input$data_type == "ind") {
      for(i in seq_along(dataset)){  
        size[i] <- sum(dataset[[i]])
      }
      
    } else if (input$data_type == "sam"){
      for(i in seq_along(dataset)){
        size[i] <- dataset[[i]][1]
      }
    }
    eptAuto <- ifelse(length(size)>1, min(max(size), min(2*size)), 2*size)
    numericInput("endpt", "Endpoint setting", value=eptAuto)    
  })
  
  
  
  
  #############################################################################
  # Rarefaction and Prediction
  #############################################################################
  out.iNEXT <- reactive({
    if(is.null(input$data_type)) return()
    dataset <- selectedData()
    #names(dataset) <- input$dataset
    
    if(is.null(input$knots) || input$knots<=5) {
      knots=4
    } else { 
      knots <- input$knots 
      knots <- knots - knots%%2
    }
    se <- as.logical((input$nboot)>1)
    if(input$nboot == 1) nboot = 0
    nboot <- round(input$nboot)
    end <- input$endpt  
    out <- list()
    for(i in seq_along(dataset)){
      if(input$data_type == "ind"){
        out[[i]] <- iNEXT.Ind(dataset[[i]], Knots=knots, nboot=nboot, se=se, endpoint=end)
      }
      if(input$data_type == "sam"){
        out[[i]] <- iNEXT.Sam(dataset[[i]], Knots=knots, nboot=nboot, se=se, endpoint=end)
      }
    }
    names(out) <- input$dataset
    saveRDS(out, tempRD2) 
    return(out)    
  })
  
  
  output$inext <- renderUI({
    out <- out.iNEXT()
    tab <- list()
    for(i in seq_along(out)){
      data <- out[[i]]
      caption=paste("<H5>", names(out)[i], "</H5>", sep="")
      digits=2
      if(ncol(data)==3) {
        digits <- c(0, 0, 2, 3)
      }
      if(ncol(data)==7) {
        digits <- c(0, 0, 2, 2, 2, 3, 3, 3)
      }
      tab[[i]] <- print(xtable(data, caption=caption, digits=digits), 
                        type='html', 
                        caption.placement='top',
                        html.table.attributes="class='data table table-bordered table-condensed'",
                        print.results=FALSE)
    }
    HTML(paste(unlist(tab),collapse="\n"))
  })
  
  #Download iNEXT output 
  output$dlinext <- downloadHandler(
    filename = function() { paste('output_', Sys.Date(), '_[iNEXT].csv', sep='') },
    content = function(file) { 
      out <- readRDS(tempRD2)
      #out <- out.iNEXT()
      saveList2csv(out, file)
    }
  )
  
  #############################################################################
  # Plot Figures
  #############################################################################
  
  
  #Plot Fig 1.
  output$fig1 <-  renderPlot({
    out <- out.iNEXT()
    saveRDS(out, tempRD2)
    myplot1(out)
  })
  
  #Save Fig 1. as pdf
  output$dlfig1 <- downloadHandler(
    filename = function() { paste("Fig1_", Sys.Date(), "_[iNEXT].pdf", sep = "") },
    content = function(file) { 
      temp <- tempfile()
      on.exit(unlink(temp))
      pdf(file = temp)
      out <- readRDS(tempRD2)
      myplot1(out)
      dev.off()
      bytes <- readBin(temp, "raw", file.info(temp)$size)
      writeBin(bytes, file)
    }
  )
  
  #Plot Fig 2.
  output$fig2 <- renderPlot({
    out <- out.iNEXT()
    myplot2(out)
  })
  
  #Save Fig 2. as pdf
  output$dlfig2 <- downloadHandler(
    filename = function() { paste("Fig2_", Sys.Date(), "_[iNEXT].pdf", sep = "") },
    content = function(file) { 
      temp <- tempfile()
      on.exit(unlink(temp))
      pdf(file = temp)
      out <- readRDS(tempRD2)
      myplot2(out)   
      dev.off()
      bytes <- readBin(temp, "raw", file.info(temp)$size)
      writeBin(bytes, file)
    }
  )
  
  #Plot Fig 3.
  output$fig3 <- renderPlot({
    out <- out.iNEXT()
    myplot3(out)   
  })
  
  #Save Fig 3. as pdf  
  output$dlfig3 <- downloadHandler(
    filename = function() { paste("Fig3_", Sys.Date(), "_[iNEXT].pdf", sep = "") },
    content = function(file) { 
      temp <- tempfile()
      on.exit(unlink(temp))
      pdf(file = temp)
      out <- readRDS(tempRD2)
      myplot3(out)
      dev.off()
      bytes <- readBin(temp, "raw", file.info(temp)$size)
      writeBin(bytes, file)
    }
  )
  
  
})
