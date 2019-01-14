# Processing and visualizing birth control survey data
This is my code (written in R) to process, clean, analyze, and graph data from a survey on birth control methods. 

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


___

 For the #SWDchallenge, I decided to use Tableau. I was working with a dataset that was a survey of how birth control options were used among women. Previously, I had been working with this dataset in R. I wrote code that cleaned and analyzed the data -- removing nulls, duplicate user-entered responses and typos, and adding in geolocation of each user by response IP address. I made graphs and charts from the data in R, but I wanted to do something more.

Since I had the latitude and longitude already from the geolocation, I decided to use Tableau to map it. At first when I selected the map function, Tableau generated its own data points on the map, but a few were missing. Since I'm not familiar with how this automated generation of points works, I removed the Tableau-generated latitude and longitude from the map and instead used the latitude and longitude columns I'd generated myself during the geolocation process. This made sure that all of the points were on the map. I then added in some tooltips and found that process fairly straightforward.

I'd used Tableau a bit before but I surprised myself that I actually didn't like how "drag-and-drop" it is. Maybe it's that I'm more used to hand-coding things more in R, but the missing data points example seems to show that it would be easy to get into trouble if you weren't really watching! But its ease of use makes a lot of sense for making a quick graphic without a lot of fuss.

Below is the link to the Tableau map. The latitude and longitude of each survey respondent was generated with the above R code. Each point represents one survey respondent, color-coded by the age at which they first thought about using birth control.  The tooltips display the respondent's current age, city, and birth control method. Take a look here: https://public.tableau.com/profile/princess7577#!/vizhome/BCsurveyresponsesacrossthenation/Sheet1
