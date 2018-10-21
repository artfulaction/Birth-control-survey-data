# Birth-control-survey-data
This is my code (written in R) to process data from a survey on birth control methods. 

The survey contained multiple choice and user-centered responses. 

The data processing includes:
* filtering out null responses
* dropping irrelevant columns
* geolocating the IP addresses of survey participants and adding city and state to the dataframe
* creating a dataframe of people who agreed to be interviewed
* counting total answers for various multiple-choice questions
* standardizing the user-entered question to discrete categories and counting total answers
* graphing the answer counts to each question
* saving the graphs and dataframes created 
