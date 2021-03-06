# Processing and visualizing birth control survey data
[This is my code (written in R) to process, clean, analyze, and graph data from a survey on birth control methods.](https://github.com/artfulaction/Birth-control-survey-data/blob/master/BC_patients.R)

The survey contained multiple choice and user-entered responses that required cleaning to elimate typed variations.

Once the data are cleaned and processed, graphs are created and new, cleaned data is exported.

The data processing includes:
* filtering out null responses
* dropping irrelevant columns
* geolocating the IP addresses of survey participants and adding latitude, longitude, city, and state to the dataframe
* creating a dataframe of people who agreed to be interviewed
* counting total answers for various multiple-choice questions
* standardizing the user-entered question to discrete categories and counting total answers
* graphing the answer counts to each question
* exporting the graphs and dataframes created 

I made a quick visualization mapping out the survey data in Tableau. The latitude and longitude of each survey respondent was generated with the above R script. Each point represents one survey respondent, color-coded by the age at which they first thought about using birth control.  The tooltips display the respondent's current age, city, and birth control method. Take a look here: https://public.tableau.com/profile/princess7577#!/vizhome/BCsurveyresponsesacrossthenation/Sheet1
