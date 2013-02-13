# Load packages
library("shiny")
load('data/ex_data.RData')
data(list='ex_data')
#source("mySub.R")
source("iNEXT.R")
source("sub.R")


tempRD1 <- paste(tempfile(), ".RData", sep="")
tempRD2 <- paste(tempfile(), ".RData", sep="")

shinyServer(function(input, output) {
  source('sub.R', local = TRUE)
  
  output$choose_dataset <- reactiveUI(function() {
    #Add user upload data in the feture
    if(input$data_type=="ind") {
      dat <- list("Oldgrowth"="Oldgrowth", "Secondgrowth"="Secondgrowth")
      #dat <- list("Girdled"="Girdled", "Logged"="Logged")
      #dat <- c(dat1, dat2)
    } else {
      dat <- list("Berlese"="Berlese", "Malaise"="Malaise", "fogging"="fogging")
      #dat2 <- list("y50"="y50", "y500"="y500", "y1070"="y1070", "y1500"="y1500", "y2000"="y2000")
      #dat <- c(dat1, dat2)
    }
    selectInput("dataset", "Select dataset to show:", choices  = dat, selected = dat[1], multiple = TRUE)
  })
  
  
  output$choose_ulsi_ind <- reactiveUI(function() {
    if(input$data_type != "ind" | input$ul_ind_method != "si") return()
    dataset <- lapply(input$dataset, get)
    min <- max <- value <- 0
    for(i in seq_along(dataset)){  
      min[i] <- sum(dataset[[i]])
      value[i] <- 2*min[i]
      max[i] <- InvChat.Ind(dataset[[i]], 0.999)
    }
    min <- max(min)
    max <- max(max)
    value <- max(value)
    sliderInput("ulsi_ind", "",
                min=min, max=max, step=1, value=value)
  })
  
  output$choose_ulsi_sam <- reactiveUI(function() {
    if(input$data_type != "sam" | input$ul_sam_method != "si") return()
    dataset <- lapply(input$dataset, get)
    names(dataset) <- input$dataset
    min <- max <- value <- 0
    for(i in seq_along(dataset)){
      min[i] <- dataset[[i]][1]
      value[i] <- 2*min[i]
      max[i] <- InvChat.Sam(dataset[[i]], 0.999)
    }
    min <- max(min)
    max <- max(max)
    value <- max(value)
    sliderInput("ulsi_sam", "",
                min=min, max=max, step=1, value=value)
  })
  
  output$choose_ulsc_ind <- reactiveUI(function() {
    if(input$data_type != "ind" | input$ul_ind_method != "sc") return()
    dataset <- lapply(input$dataset, get)
    min <- value <- 0
    for(i in seq_along(dataset)){
      n <- sum(dataset[[i]])
      min[i] <- Chat.Ind(dataset[[i]], n)
      value[i] <- Chat.Ind(dataset[[i]], 2*n)
    }
    min <- max(min)
    value <- max(value)
    sliderInput("ulsc_ind", "",
                min=round(min,3), max=0.999, step=(1-min)/100, value=round(value,3))
  })
  
  output$choose_ulsc_sam <- reactiveUI(function() {
    if(input$data_type != "sam" | input$ul_sam_method != "sc") return()
    dataset <- lapply(input$dataset, get)
    min <- value <- 0
    for(i in seq_along(dataset)){
      n <- max(dataset[[i]])
      min[i] <- Chat.Sam(dataset[[i]], n)
      value[i] <- Chat.Sam(dataset[[i]], 2*n)
    }
    min <- max(min)
    value <- max(value)
    sliderInput("ulsc_sam", "",
                min=round(min,3), max=0.999, step=(1-min)/100, value=round(value,3))
  })
  
  
  #############################################################################
  # Data Summary
  #############################################################################  
  
  #Show basic data information
  output$summary <- reactivePrint(function() {
    #if(is.null(input$dataset)) input$dataset <- "Secondgrowth"
    
    dataset <-lapply(input$dataset, get)
    names(dataset) <- input$dataset
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
    filename = function() { paste('SummaryData-', Sys.Date(), '.csv', sep='') },
    content = function(file) { 
      out <- readRDS(tempRD1)
      saveList2csv(out, file)      
    }
  )
  
  #############################################################################
  # Rarefaction and Prediction
  #############################################################################
  out.iNEXT <- reactive(function() {
    if(is.null(input$data_type) | is.null(input$ul_ind_method) | is.null(input$ul_sam_method)) return()
    dataset <- lapply(input$dataset, get)
    if(is.null(input$knots) | input$knots<=5) {
      knots=4
    } else { 
      knots <- input$knots 
      knots <- knots - knots%%2
    }
    se <- as.logical((input$nboot)>1)
    if(input$nboot == 1) nboot = 0
    nboot <- round(input$nboot)
    out <- list()
    for(i in seq_along(dataset)){
      if(input$data_type == "ind" & input$ul_ind_method == "si"){
        end <- input$ulsi_ind
        out[[i]] <- iNEXT.Ind(dataset[[i]], Knots=knots, nboot=nboot, se=se, endpoint=end)
      }
      if(input$data_type == "ind" & input$ul_ind_method == "sc"){
        end <- InvChat.Ind(dataset[[i]], input$ulsc_ind)
        out[[i]] <- iNEXT.Ind(dataset[[i]], Knots=knots, nboot=nboot, se=se, endpoint=end)
      }
      if(input$data_type == "sam" & input$ul_sam_method == "si"){
        end <- input$ulsi_sam
        out[[i]] <- iNEXT.Sam(dataset[[i]], Knots=knots, nboot=nboot, se=se, endpoint=end)
      }
      if(input$data_type == "sam" & input$ul_sam_method == "sc"){
        end <- InvChat.Sam(dataset[[i]], input$ulsc_sam)
        out[[i]] <- iNEXT.Sam(dataset[[i]], Knots=knots, nboot=nboot, se=se, endpoint=end)
      }
    }
    names(out) <- input$dataset
    return(out)    
  })
  
  output$inext <- reactivePrint(function() {
    out <- out.iNEXT()
    saveRDS(out, tempRD2)
    out
  })
  
  #Download iNEXT output 
  output$dlinext <- downloadHandler(
    filename = function() { paste('iNEXToutput-', Sys.Date(), '.csv', sep='') },
    content = function(file) { 
      out <- readRDS(tempRD2)
      saveList2csv(out, file)
    }
  )
  
  #############################################################################
  # Plot Figures
  #############################################################################
  
  
  #Plot Fig 1.
  output$fig1 <-  reactivePlot(function() {
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
  output$fig2 <- reactivePlot(function() {
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
  output$fig3 <- reactivePlot(function() {
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
