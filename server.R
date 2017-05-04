library(shiny)
library(caret)
library(e1071)


train.col.types <- c('integer', # PassengerID
                     'factor', # Survived
                     'factor', # Pclass
                     'character', # Name
                     'factor', # Sex
                     'numeric', #Age
                     'integer', # SibSp
                     'integer', # Parch
                     'character', # Ticket
                     'numeric', # Fare
                     'character', # Cabin
                     'factor' # Embarked
)

train.raw <- read.csv("Data/train.csv", colClasses = train.col.types, na.strings = c("NA", ""))

getTitle <- function(data) {
  title.start <- regexpr("\\, [A-Z]{1,20}\\.", data$Name, TRUE)
  title.end <- title.start + attr(title.start, "match.length")-1
  data$Title <- substr(data$Name, title.start+2, title.end-1)
  return(data$Title)
}

train.raw$Title <- getTitle(train.raw)

# We only consider titles in these groups
title.filter <- c("Mr", "Mrs", "Miss", "Master", "Professional")

recodeTitle <- function(data, title, filter) {
  if(! (data %in% title.filter))
    data = "Professional"
  return(data)
}
train.raw$Title <- sapply(train.raw$Title, recodeTitle, title.filter)

imputeAge <- function(Age, Title, title.filter) {
  for(v in title.filter) {
    Age[is.na(Age)] = median(Age[Title==v], na.rm = T)
  }
  return(Age)
}

title.filter <- c("Mr", "Mrs", "Miss", "Master", "Professional")
train.raw$Age <- imputeAge(train.raw$Age, train.raw$Title, title.filter)

imputeEmbarked <- function(Embarked) {
  Embarked[is.na(Embarked)] <- "S"
  return(Embarked)
}
train.raw$Embarked <- imputeEmbarked(train.raw$Embarked)

imputeFare <- function(fare, pclass, pclass.filter) {
  for(v in pclass.filter) {
    fare[is.na(fare)] <- median(fare[pclass==v], na.rm = T)
  }
  return(fare)
}
pclass.filter <- c(1,2,3)
train.raw$Fare <- imputeFare(train.raw$Fare, train.raw$Pclass, pclass.filter)

model.logit.2 <- train(Survived~Sex+Pclass+Age+Embarked+Fare+Title+SibSp+
                         Parch, data = train.raw, method="glm")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  Sex = reactive({input$e0})
  Pclass = reactive({as.factor(input$e1)})
  Age = reactive({input$e2})
  em = reactive({input$e3})
  Embarked = reactive({ifelse(em() == 'Cherbourg', 'C', ifelse(em() == 'Queenstown', 'Q', 'S'))}) 
  Title = reactive({input$e4}) 
  # These are default values. We assume no sibling and no parents
  SibSp = 0; Parch = 0; Fare = median(train.raw$Fare)
  test = reactive(data.frame(Sex = Sex(), Pclass = Pclass(), 
                             Age = Age(), Embarked = Embarked(), Title = Title(), 
                             SibSp, Parch, Fare))
  a = reactive(predict(model.logit.2, test()))
  output$model_text <- renderText({
    if(a() == 0) {
      print('Sorry, you probabaly will die there!')
    }
    else if(a() == 1) {
      print('OMG, you will survive!!! Yeah!!!!')
    }
  })
  
})