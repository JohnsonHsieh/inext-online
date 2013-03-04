library(shiny)

# Define UI
shinyUI(pageWithSidebar(
  
  #app title
  headerPanel("iNEXT Online"),
  #input
  sidebarPanel(
    tags$head(
      tags$style(type="text/css", "label.radio { display: inline-block; }", ".radio input[type=\"radio\"] { float: none; }"),
      tags$style(type="text/css", "select { max-width: 250px; }"),
      tags$style(type="text/css", "input { max-width: 250px; }"),
      tags$style(type="text/css", "textarea { max-width: 230px; }"),
      #tags$style(type='text/css', ".well { padding: 5px; margin-bottom: 5px; max-width: 300px; }"),
      tags$style(type='text/css', ".span4 { max-width: 300px; }")
    ),
    p(h4("Data setting")),
    wellPanel(
      selectInput("data_type", "Select data type:", 
                  c("Abundance data"="ind", "Incidence data"="sam")),
      uiOutput("choose_dataset"),
      p(em("Using ctrl / command key to select multiple dataset you want")),
      
      checkboxInput("import_data", strong("Import your data"), FALSE),
      conditionalPanel(
        condition="input.import_data==true",
        
        conditionalPanel(
          condition="input.data_type == 'ind'",
          uiOutput("ui_import_ind")
        ),
        conditionalPanel(
          condition="input.data_type == 'sam'",
          uiOutput("ui_import_sam")
        ),
        
        p(em("Type R code to import data"))
      )
    ),
    
    p(h4("General Setting")),
    wellPanel(
      numericInput("knots", "Number of knots", 
                   min=20, max=200, step=10, value=40),
      numericInput("nboot", "Number of bootstraps", 
                   min=0, max=500, step=20, value=0),
      #p(em("Setting the number of bootstrap to zero will not compute 95% confidence band.")),
      
      conditionalPanel(
        condition = "input.data_type == 'ind'",
        selectInput("ul_ind_method", "Endpoint(s) control:", 
                    c("Number of individuals"="si", "Sample coverage"="sc")
        ),
        conditionalPanel(
          condition = "input.ul_ind_method == 'si'",
          uiOutput("choose_ulsi_ind")
        ),
        conditionalPanel(
          condition = "input.ul_ind_method == 'sc'",
          uiOutput("choose_ulsc_ind")
        )
      ),
      
      conditionalPanel(
        condition = "input.data_type == 'sam'",
        selectInput("ul_sam_method", "Endpoint(s) control:", 
                    c("Number of Samples"="si", "Sample coverage"="sc")
        ),
        conditionalPanel(
          condition = "input.ul_sam_method == 'si'",
          uiOutput("choose_ulsi_sam")
        ),
        conditionalPanel(
          condition = "input.ul_sam_method == 'sc'",
          uiOutput("choose_ulsc_sam")
        )
      ),
      p(em("Setting the upper limit by sliderbar."))
    ),
    
    #checkboxInput("advSet", h4("Advanced Settings"), FALSE),
    #conditionalPanel(condition = "input.advSet == true", 
    #                 helpText("coming soon ...")),
    
    includeMarkdown("www/footnote.md")    
    
  ),
  
  mainPanel(tabsetPanel(
    tabPanel("Data Summary", 
             h3("Basic data infomation"),
             checkboxInput("showRaw", "Show raw data (Observed frequencies)", FALSE),
             conditionalPanel(
               condition="input.showRaw == true",
               verbatimTextOutput("dataview")),
             verbatimTextOutput("summary"),
             downloadLink("dlsummary", "Download as csv file"),
             conditionalPanel(
               condition="input.data_type == 'ind'",
               includeMarkdown("www/summary_ind.md")),
             conditionalPanel(
               condition="input.data_type == 'sam'",
               includeMarkdown("www/summary_sam.md"))
             
    ),
    
    tabPanel("Rarefaction and Predction",
             h3("Rarefaction and Predction"),
             uiOutput("inext"),       
             downloadLink("dlinext", "Download as csv file"),
             conditionalPanel(
               condition="input.data_type == 'ind'",
               includeMarkdown("www/inext_ind.md")),
             conditionalPanel(
               condition="input.data_type == 'sam'",
               includeMarkdown("www/inext_sam.md"))                        
    ),
    
    tabPanel("Plot Figures",
             HTML("<center>"),
             HTML("<h4>(1) Sample-size-based rarefaction and extrapolation sampling curve</h4>"),  
             plotOutput("fig1", width="400px", height="400px"),
             HTML("</center>"),
             HTML("<br>Species richness estimates for a rarefied and extrapolated sample 
                  with sample size up to double the reference sample size.</br>"),
             downloadLink("dlfig1", "Download as PDF"),
             
             HTML("<center>"),
             HTML("<h4>(2) Sample completeness curve</h4>"),  
             plotOutput("fig2", width="400px", height="400px"),
             HTML("</center>"),
             HTML("<br>Sample completeness (as measured by sample coverage) with respect to sample 
                  size. This curve provides a bridge between sample-size- and coverage-based 
                  rarefaction and extrapolation.</br>"),  
             downloadLink("dlfig2", "Download as PDF"),
             
             HTML("<center>"),
             HTML("<h4>(3) Coverage-based rarefaction and extrapolation sampling curve</h4>"),  
             plotOutput("fig3", width="400px", height="400px"),
             HTML("</center>"),
             HTML("species richness estimates for rarefied sample and extrapolated sample with 
                  sample coverage up to double the reference sample size."),
             downloadLink("dlfig3", "Download as PDF")
    ),
    tabPanel("How to Cite", includeMarkdown("www/cite.md")),
    tabPanel("About", includeMarkdown("www/about.md"))
    
    
  ))
))
