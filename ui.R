GTM <- "
<!-- Google Tag Manager -->
  <noscript><iframe src=\"//www.googletagmanager.com/ns.html?id=GTM-BM4R\"
height=\"0\" width=\"0\" style=\"display:none;visibility:hidden\"></iframe></noscript>
  <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
                                                          new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
                               j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
                                 '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
  })(window,document,'script','dataLayer','GTM-BM4R');</script>
  <!-- End Google Tag Manager -->
"
  


library(shiny)

# Define UI
shinyUI(pageWithSidebar(

  #app title
  headerPanel("iNEXT Online"),
  #input
  sidebarPanel(
    tags$head(
      div(id="GTM", HTML(GTM)), #add google tag manager
      tags$style(type="text/css", "label.radio { display: inline-block; }", ".radio input[type=\"radio\"] { float: none; }"),
      tags$style(type="text/css", "select { max-width: 250px; }"),
      tags$style(type="text/css", "input { max-width: 250px; }"),
      tags$style(type="text/css", "textarea { max-width: 230px; }"),
      #tags$style(type='text/css', ".well { padding: 5px; margin-bottom: 5px; max-width: 300px; }"),
      tags$style(type='text/css', ".span4 { max-width: 300px; }")
      
    ),
    p(h4("Data Setting")),
    wellPanel(  
      selectInput("data_type", "Select data type:", 
                  c("Abundance data"="ind", "Incidence data"="sam")),
      uiOutput("choose_dataset"),
      p(em("Using ctrl / command key to select multiple datasets you want")),

      p("Import data:"),
      conditionalPanel(
        condition="input.data_type == 'ind'",
        tags$textarea(id="copyAndPaste_ind", rows=5, 
                      "Girdled 46 22 17 15 15  9  8  6  6  4  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1 \nLogged 88 22 16 15 13 10  8  8  7  7  7  5  4  4  4  3  3  3  3  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1  1  1")  
      ),
      conditionalPanel(
        condition="input.data_type == 'sam'",
        tags$textarea(id="copyAndPaste_sam", rows=5, 
                      "Ants_1500m 200 144 113 79 76 74 73 53 50 43 33 32 30 29 25 25 25 24 23 23 19 18 17 17 11 11 9 9 9 9 6 6 5 5 5 5 4 4 3 3 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 \nAnts_2000m 200 80 59 34 23 19 15 13 8 8 4 3 2 2 1")
      ),          
      p(em("Refer to user guide for importing data"))
    ),
    
    p(h4("General Setting")),
    wellPanel(
      uiOutput("set_endpt"),
     
      numericInput("knots", "Number of knots", 
                   min=20, max=200, step=10, value=40),
      numericInput("nboot", "Number of bootstraps", 
                   min=0, max=500, step=20, value=0)
    ),
    
    #checkboxInput("advSet", h4("Advanced Settings"), FALSE),
    #conditionalPanel(condition = "input.advSet == true", 
    #                 helpText("coming soon ...")),
    
    includeMarkdown("www/footnote.md")    
    
  ),
  
  mainPanel(tabsetPanel(
    tabPanel("Data Summary", 
             h3("Basic data information"),
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
    
    tabPanel("Rarefaction/Extrapolation",
             h3("Rarefaction and Extrapolation"),
             uiOutput("inext"),       
             downloadLink("dlinext", "Download as csv file"),
             conditionalPanel(
               condition="input.data_type == 'ind'",
               includeMarkdown("www/inext_ind.md")),
             conditionalPanel(
               condition="input.data_type == 'sam'",
               includeMarkdown("www/inext_sam.md"))                        
    ),
    
    tabPanel("Figure plots",
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
    #tabPanel("How to Cite", includeMarkdown("www/cite.md")),
    tabPanel("User Guide", includeMarkdown("www/about.md"))
    
    
             ))
  ))
