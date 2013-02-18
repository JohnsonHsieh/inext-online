# Load packages
library("shiny")
library("shinyIncubator")
library("xtable")

load('data/ex_data.RData')
data(list='ex_data')
source("iNEXT.R")


tempRD1 <- paste(tempfile(), ".RData", sep="")
tempRD2 <- paste(tempfile(), ".RData", sep="")
temphtml <- paste(tempfile(), ".html", sep="")

shinyServer(function(input, output) {
  source('sub.R', local = TRUE)
  
  #############################################################################
  # Data setting
  #############################################################################  
  
  output$choose_dataset <- renderUI({
    #Add user upload data in the feture
    
    
    if(input$data_type=="ind") {
      
      dat <- list("Oldgrowth"="Oldgrowth", "Secondgrowth"="Secondgrowth")
      if(input$import_data == TRUE){
        out <- loadPaste()
        out.name <- names(out)
        if(is.na(names(out)[1]) == FALSE) {
          dat <- out
          for(i in seq_along(out)){
            dat[[i]] <- out.name[i]
          }
        } 
      }
    }
    if(input$data_type=="sam") {
      dat <- list("Berlese"="Berlese", "Malaise"="Malaise", "fogging"="fogging")
      if(input$import_data == TRUE){
        out <- loadPaste()
        out.name <- names(out)
        if(is.na(names(out)[1]) == FALSE) {
          dat <- out
          for(i in seq_along(out)){
            dat[[i]] <- out.name[i]
          }
        } 
      }
    }
    selectInput("dataset", "Select dataset to show:", choices  = dat, selected = dat[1], multiple = TRUE)
  })
  
  output$ui_import_ind <- renderUI({
    tags$textarea(id="copyAndPaste_ind", rows=5, 
                  "Girdled 46 22 17 15 15  9  8  6  6  4  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1 \nLogged 88 22 16 15 13 10  8  8  7  7  7  5  4  4  4  3  3  3  3  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1  1  1")  
  })
  
  output$ui_import_sam <- renderUI({
    tags$textarea(id="copyAndPaste_sam", rows=5, 
                  "Y_1500 200   1   1   1   1   1   1   1   1   1   1   1   1   1   2   2   2   2   3   3   4   4   5   5   5   5   6   6   9   9   9   9  11  11 17  17  18  19  23  23  24  25  25  25  29  30  32  33  43  50  53  73  74  76  79 113 144")
  })
  
  loadPaste <- reactive({
    if(input$data_type=="ind"){
      text <- input$copyAndPaste_ind
    } else {
      text <- input$copyAndPaste_sam
    }
    temp <- lapply(readLines(textConnection(text)), function(x) scan(text = x, what='char'))
    out <- list()
    out.name <- 0
    for(i in seq_along(temp)){
      out.name[i] <- temp[[i]][1]
      out[[i]] <- as.numeric(temp[[i]][-1])
    }
    names(out) <- t(data.frame(out.name))
    out
  })
  
  selectedData <- reactive({
    if(is.null(input$dataset)) dataset <- NULL
    if(input$data_type=="ind"){
      text <- input$copyAndPaste_ind
    } else {
      text <- input$copyAndPaste_sam
    }
    if(input$import_data == FALSE || text==""){
      dataset <-lapply(input$dataset, get)
      names(dataset) <- input$dataset
    } else {
      out <- loadPaste()
      data.names <- input$dataset
      selected <- which(names(out)==input$dataset)
      dataset <- list()
      for(i in 1:length(selected)){
        k <- selected[i]
        dataset[[i]] <- out[[k]]
      }
      names(dataset) <- input$dataset
    }
    return(dataset)
    
  })
  
  
  
  
  
  #############################################################################
  # Data Summary
  #############################################################################  
  
  output$dataview <- renderPrint({  
    dataset <- selectedData()
    names(dataset) <- input$dataset
    lapply(dataset, function(dat) sort(subset(dat, dat>0), dec=TRUE))    
  })
  
  #Show basic data information
  output$summary <- renderPrint({
    dataset <- selectedData()
    names(dataset) <- input$dataset
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
    filename = function() { paste('SummaryData-', Sys.Date(), '.csv', sep='') },
    content = function(file) { 
      out <- readRDS(tempRD1)
      saveList2csv(out, file)      
    }
  )
  
  #############################################################################
  # Slider control
  #############################################################################  
  
  output$choose_ulsi_ind <- renderUI({
    if(input$data_type != "ind" | input$ul_ind_method != "si") return()
    dataset <- selectedData()
    names(dataset) <- input$dataset
    min <- max <- value <- 0
    for(i in seq_along(dataset)){  
      min[i] <- sum(dataset[[i]])
      value[i] <- 2*min[i]
      max[i] <- InvChat.Ind(dataset[[i]], 0.999)
    }
    min <- max(min)
    max <- max(max)
    value <- max(value)
    sliderInput("ulsi_ind", "", min=min, max=max, step=1, value=value)
  })
  
  output$choose_ulsi_sam <- renderUI({
    if(input$data_type != "sam" | input$ul_sam_method != "si") return()
    dataset <- selectedData()
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
    sliderInput("ulsi_sam", "", min=min, max=max, step=1, value=value)
  })
  
  output$choose_ulsc_ind <- renderUI({
    if(input$data_type != "ind" | input$ul_ind_method != "sc") return()
    dataset <- selectedData()
    names(dataset) <- input$dataset
    min <- value <- 0
    for(i in seq_along(dataset)){
      n <- sum(dataset[[i]])
      min[i] <- Chat.Ind(dataset[[i]], n)
      value[i] <- Chat.Ind(dataset[[i]], 2*n)
    }
    min <- max(min)
    value <- max(value)
    sliderInput("ulsc_ind", "", min=round(min,3), max=0.999, step=(1-min)/100, value=round(value,3))
  })
  
  output$choose_ulsc_sam <- renderUI({
    if(input$data_type != "sam" | input$ul_sam_method != "sc") return()
    dataset <- selectedData()
    names(dataset) <- input$dataset
    min <- value <- 0
    for(i in seq_along(dataset)){
      n <- max(dataset[[i]])
      min[i] <- Chat.Sam(dataset[[i]], n)
      value[i] <- Chat.Sam(dataset[[i]], 2*n)
    }
    min <- max(min)
    value <- max(value)
    sliderInput("ulsc_sam", "", min=round(min,3), max=0.999, step=(1-min)/100, value=round(value,3))
  })
  
  #############################################################################
  # Rarefaction and Prediction
  #############################################################################
  out.iNEXT <- reactive({
    if(is.null(input$data_type) | is.null(input$ul_ind_method) | is.null(input$ul_sam_method)) return()
    dataset <- selectedData()
    names(dataset) <- input$dataset
    
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

