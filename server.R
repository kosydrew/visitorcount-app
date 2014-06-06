
library(shiny)

##  DATA TO BE USED
apr.weather.data <- read.csv("data/Apr_data.csv", sep = ";", header = T)

apr.n.obs <- read.csv("data/Apr_n_obs.csv", sep = ";", header = T)

jan.to.mar.data <- read.csv("data/Jan_to_Mar_data.csv", sep = ";", header = T)

number_visitors <- as.numeric(apr.n.obs$n.visits)
time <- as.POSIXct(apr.n.obs$april.hrs.full, format = "%Y-%m-%d")

# Fitted model based upon data from Jan to Mar with weather covariates
predict.glm.quasi <- glm(n.visits ~ temp.c + p.clouds + workdayDE + Saturday + cos(2*pi*hour2/24)+sin(2*pi*hour2/24), family = quasipoisson, data = jan.to.mar.data)
# Predicted Apr values
p1 <- predict(predict.glm.quasi, newdata = apr.weather.data, se.fit = TRUE)
predicted_n <- as.numeric(exp(p1$fit))

# Fitted model based without weather covariates
predict.no.w <- glm(n.visits ~ workdayDE + Saturday + cos(2*pi*hour2/24)+sin(2*pi*hour2/24), family = quasipoisson, data = jan.to.mar.data)
# Predicted Apr values
p2 <- predict(predict.no.w, newdata = apr.weather.data, se.fit = TRUE)
predicted_no_weather <- as.numeric(exp(p2$fit))


##  Code reactive elements
shinyServer(function(input, output) {
  output$aprilplot <- renderPlot({
    
    time.min <- difftime(input$dates[1], "2014-04-01", units = "hours")
    time.max <- difftime(input$dates[2], "2014-04-01", units = "hours")
    
    x <- time.min:time.max
    data <- rep(NA, length(x))
    ylim <- range(number_visitors)
    
    if(input$n.visitors) {
      data <- number_visitors[x]
    }
    
    plot(x = x,
        y = data,
        type = "p",
        col = "black",
        pch = 20, 
        cex = 0.3, 
        xlab = "hourly observations", 
        ylab = "",
        ylim = ylim,
        xaxt = "n")
    
    tick <- ((ceiling(min(x/24)):floor(max(x/24)))*24)
    labels <- format(time[tick], format = "%e %b")
    # For a view with days of the week instead, use code in next line
    #labels <- weekdays(time[tick], abbreviate = TRUE)
    axis(side = 1, 
         at = tick, 
         labels = labels,
         tick = TRUE,
         cex.axis = 0.7)
    
    if(input$clouds.obs) {
      points(apr.weather.data$p.clouds[x] ~ x, 
             type = "h", col = "skyblue", lwd = 3)
    }
    
    if(input$temp.obs) {
      points(apr.weather.data$temp.c[x] ~ x, 
             type = "l", col = "darkgrey")
    }
    
    if(input$n.predicted.no.weather) {
      lines(predicted_no_weather[x] ~ x, col = "blue")
    }
    
    if(input$n.predicted) {
      lines(predicted_n[x] ~ x, col = "red")
    }
    
    if(input$n.visitors) {
      points(data ~ x, type = "p", pch = 20, cex = 0.3, col = "black")
    }
    
  })
  
  model.pred <- reactive({
    
    # "hour2" "workdayDE" "Saturday" "temp.c" "p.clouds"
    hour2 <- switch(input$hour,
                    "0:00" = 0, "1:00" = 1, "2:00" = 2, "3:00" = 3, "4:00" = 4, "5:00" = 5, "6:00" = 6, "7:00" = 7, "8:00" = 8, "9:00" = 9, "10:00" = 10, "11:00" = 11, "12:00" = 12, "13:00" = 13, "14:00" = 14, "15:00" = 15, "16:00" = 16, "17:00" = 17, "18:00" = 18, "19:00" = 19, "20:00" = 20, "21:00" = 21, "22:00" = 22, "23:00" = 23)
    temp.c <- input$temp
    p.clouds <- input$clouds
    Saturday <- switch(input$day,
                       "Saturday" = 1,
                       "weekday" = 0,
                       "Sunday/holiday"= 0)
    workdayDE <- switch(input$day,
                        "weekday" = 1,
                        "Saturday" = 1,
                        "Sunday/holiday"= 0)
    newdata <- as.data.frame(cbind(hour2, workdayDE, Saturday, temp.c, p.clouds))
    names(newdata) <- names(apr.weather.data[-4])
    model.pred <- round(as.numeric(exp(predict(predict.glm.quasi, newdata = newdata))), digits = 0)
  })
  
  output$demo <- renderText ({ model.pred() })
  
  output$obs_vs_pred_plot <- renderPlot({
    plot(predicted_n, number_visitors, pch = 20, cex = 0.3, xlab = "predicted number of customers", ylab = "observed", xlim = c(0, 100), ylim = c(0,100), main = "Model Predicted Values vs. Observed in April", sub = "(predicted model based upon data from Jan to Mar 2014)", cex.sub = 0.8)
    abline(a = 0, b = 1, col = "red", lwd = 2)
  })
    
  
})
