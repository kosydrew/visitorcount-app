
library(shiny)

# ui.R

shinyUI(fluidPage(
  titlePanel("Predicted hourly visitor counts based upon weather, date, and time"),
  
  fluidRow(
    column(4,
      wellPanel(
        h4("Items below display in figure 1", 
                 style = "color:blue"),
        br(),
        
        checkboxInput("n.visitors", 
                    label = "observed visitor count per hour",
                    value = TRUE),
        
        checkboxInput("n.predicted", 
                    label = "model of visitor count with weather variables",
                    value = TRUE),
        helpText("(visitor count = temp + %clouds + time + day)"),
        
        checkboxInput("n.predicted.no.weather", 
                    label = "model of visitor count w/out weather variables",
                    value = FALSE),
        helpText("(visitor count = time + day)"),
        
        checkboxInput("temp.obs", 
                      label = "temperature (celcius) in Berlin",
                      value = FALSE),
        
        checkboxInput("clouds.obs", 
                      label = "% clouds in Berlin",
                      value = FALSE),
        
        dateRangeInput("dates", 
                    label = h4("select dates to display"),
                    min = "2014-04-01",
                    max = "2014-04-29",
                    start = "2014-04-01",
                    end = "2014-04-08")
        ),
      
      wellPanel(
        h4("Manipulate the variables below"),
        p("Numeric result displayed at right & below figure 1",
                 style = "color:blue"),
        br(),
        
        sliderInput("temp", 
                    label = "temperature (celcius)",
                    min = -13, max = 22, value = 8),
        
        sliderInput("clouds", 
                    label = "% cloud cover",
                    min = 0, max = 90, value = 0),
        
        selectInput("day",
                  label = "day of the week",
                  choices = list("weekday", "Saturday", "Sunday/holiday")),
        
        selectInput("hour",
                    label = "time of day",
                    choices = list("0:00", "1:00", "2:00", "3:00", "4:00", "5:00", "6:00", "7:00", "8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"),
                    selected = "17:00"),
        
        p("Use the variables above to determine how many visitors are predicted to be in the store based upon the following generalized linear model:",
          style = "color:grey"),
        p("n ~ temp + %clouds + time + workday + Saturday",
          style = "color:grey", 
          align = "center")
        )
        
      ),
    
    column(8,
           br(),
           h4("Figure 1. Vistor count & weather in April 2014", 
              align = "center",
              style = "color:grey"),
      plotOutput("aprilplot"),
      br(),
      br(),
      br(),
      wellPanel(
        h4("Predicted Visitor Count", style = "color:black"),
        h4(textOutput("demo")), style = "color:blue")
    )
  ),
  
  fluidRow(
    column(8,
           wellPanel(
             h4("Notes regarding the fitted model presented above"),
             p("The model above is only a rough approximation of the results and must be interpreted with great care. Due to statisical limitations, the fitted model presented above is similar to, but not the same as, the one most appropriate for analysis given this dataset. That said, the values given above are approximately accurate and can provide insights into the effect of weather in Berlin on visitor counts."),
             br(),
             p("The client was interested in knowing if their visitor count was influenced by weather. After assessing a variety of weather variables, I found four that were not collinear and I used these variables to build predictive models: temperature (celcius), wind speed (mps), cloud cover (%), and rain (mm)."),
             p("Modeling of the data indicated that rain was not predictive and that wind was not informative. Therefore these variables were not included in the graphs nor models above."),
             p("The addition of temperture and percent cloud cover had a statistical affect on the visitor count.  However, temperature and cloud cover explained less than 1% of the total variance in the data.  In order to illustrate that these variables had a negliable affect on visitor count, I presented options for reviewing the predicted results without these weather variables in the model, and I also provided a method for manipulating the data in order to see the effect on the predicted visitor count."),
             p("It should be noted that the data had difficult statistical issues and limitations. Failure to account for the following major issues (and several additional ones not listed) can result in false inference. First, the visitor count results in a Poisson distribution, so a generlized linear model was required. Second, the visitor count was heavily influenced by time of day (as a harmonic), and the day of the week. These effects were so strong that if they were included in the model as fixed effects then they swamped out any effects of the weather. To solve this problem I included these variables as random effects. Third, the data was auto-correlated and required an auto-regressive model. Fourth, the model had overdispersion, so I used a quasi-Poisson link in order to correct the coefficient estimates. Fifth, a large number of models needed to be compared (preferably with multimodel inference) and the results used to predict values in future months. In order to generate predictions, I was forced to simplify the model. Thus the results above are from a generalized linear model that has no random effects nor correlation structure (i.e. auto-regressive).")
             
             )),
    
    column(4,
           p("Figure 2. Below is a graph of the observed visitor counts from April against the predicted counts from the generalized linear model (GLM) calculated using data from January to March. This GLM was used to calculate the predicted results shown above",
             span("Important note: this GLM is an approximation of the fitted model. Thus the graph is skewed due to a variety of statistical factors discussed in the notes section to the left. ", style = "color:red"),
             "The following equation was used with a Poisson distribution:"),
           p("n ~ temp + %clouds + time + workday + Saturday"),
           plotOutput("obs_vs_pred_plot"))
    )  
  
  
))

