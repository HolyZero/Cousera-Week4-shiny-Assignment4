library(shiny)
library(shinythemes)

fluidPage(
  theme = shinytheme('darkly'),
  titlePanel('Will You Survive On Titanic???'),
  sidebarLayout(
    sidebarPanel(
      h4('Make Your Own Choice to See Results: '),
      selectizeInput(
        'e0', 'What is your gender?', choices = c('male', 'female')
      ),
      selectizeInput(
        'e1', 'What is your passenger class?',
        choices = c(1,2,3)
      ),
      numericInput(
        'e2', 'What is your age?', value = 1.0
      ),
      selectizeInput(
        'e3', 'What is your port of embarkation?', choices = c('Cherbourg', 'Queenstown', 'Southampton'),
        options = list(create = TRUE)
      ),
      selectizeInput(
        'e4', 'What is your title?', choices = c("Mr", "Mrs", "Miss", "Master", "Professional")
      )
      
    ),
    mainPanel(
       h3('Have you ever imagined if you were on Titanic?'),
       h5('  This is a fun app for famous Titanic datasets from Kaggle. The goal of the app is
          predicting whether a passenger will survive on Titanic or not. The model used for
          predicting is logistic regression. Features used in model are gender, passenger 
          class, age, embark place, title, number of sibling, number of parents. The model
          assumes you are the only one so number of sibling and number of paretns are default
          zeros. Make your choices for other features on the left panel and then result will
          be shown below. The output will be either 0-die, 1-survive. Now, go ahead and play
          with this app~'),
       h5('Based on exploratory analysis, female and children will likely survive. Low
          passenger class passengers likely die.'),
       img(src='titanic.jpg', align = 'mid', height = 300, width = 500),
       h4('Wait...Model is loading your data...Will give your result soon...'),
       h5('The result is: '),
       textOutput("model_text")
    )
  )
)
