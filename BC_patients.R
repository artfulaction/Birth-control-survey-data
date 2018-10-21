library (dplyr)
library (lubridate)
library(DT)
library(stringr)
library(rgeolocate)
library(tidyverse)
library(ggplot2)
library(forcats)
library(ggthemes)

setwd("~/coding/Environments/birth_control")

#read in the data from CheckBox. When exporting the data file of responses, check all boxes for export! (#13 was downloaded 10-17-2018)
patients <- read.csv("data/BirthControl_13.csv")

#filter out all the Null Responses from the dataframe. 
patients <- filter(patients, !is.na(ResponseID))
 
#parse out the date formats using lubridate month-day-year_hours-minutes-seconds format so we can filter responses by Year
patients$Started <- mdy_hms(patients$Started)
patients$Ended <- mdy_hms(patients$Ended)

#drop the rows from the 2015 survey
patients <- (filter(patients, year(Started) > "2015"))

#drop columns that we aren't using
patients <-select(patients, -ResponseGuid, -TotalTime, -LastEdit, -Language, -UniqueIdentifier, -Invitee, -FirstName, -LastName)

#geolocating the IP addresses. 
file <-  "data/IP2LOCATION-LITE-DB9_IPV6.BIN"
patients$IP <- as.character(patients$IP) #change IP column to character vector so we can use the geolocating package
located <- ip2location(patients$IP, file, c("region", "city","lat","long"))

#join the new data to main df
patients <- bind_cols(patients, located)

#rename some columns so that they are easier to work with. put these in the patients_cols dataframe

patients_cols <- patients %>% rename(Age=How.old.are.you.) %>%
  rename(Gender=What.is.your.gender.) %>% 
  rename(FirstThoughtBC=How.old.were.you.when.you.first.thought.about.using.birth.control.) %>% 
  rename(DiscussWithDoctor=Did.you.discuss.birth.control.with.your.doctor.) %>% 
  rename(TypesConsidered=What.types.of.birth.control.have.you.ever.considered...Please.check.all.that.apply.) %>% 
  rename(GoalsforBC=What.were.are.your.goals.for.birth.control...Please.check.all.that.apply.) %>% 
  rename(DidntKnowAbout=Did.your.doctor..or.Planned.Parenthood..tell.you.about.any.methods.you.didn.t.already.know.about...Please.check.all.that.apply.) %>% 
  rename(Concerns=Did.anything.concern.you.about.the.options.you.were.given.) %>% 
  rename(DidUHaveChoice=Did.you.feel.you.had.a.choice.between.your.options.) %>% 
  rename(WhyInterested=What.made.you.feel.more.or.less.interested.in.one.option.over.another.) %>% 
  rename(OptionChoice=What.option.s..did.you.choose.) %>% 
  rename(Concerns1=Did.anything.concern.you.about.the.options.you.knew.about.) %>% 
  rename(WhyInterested1=What.made.you.feel.more.or.less.interested.in.one.option.over.another..1) %>% 
  rename(DidUHaveChoice1=Did.you.feel.you.had.a.choice.between.your.options..1) %>% 
  rename(OptionChoice1=What.option.s..did.you.choose..1) %>% 
  rename(Liked=What.did.you.like.about.the.birth.control.method.s..you.chose.) %>% 
  rename(DidNotLike=What.did.you.NOT.like.about.the.birth.control.method.s..you.chose.) %>% 
  rename(Advice=What.advice.would.you.give.to.a.woman.considering.birth.control.options.) %>% 
  rename(WillYouSpeakWithUs=Would.you.be.willing.to.speak.with.us.over.the.phone.about.your.experience.) %>% 
  rename(FirstName=First.name.) %>% 
  rename(Email=E.mail.)

#filter remaining blank responses from the dataframe based on if the respondent didn't answer the first two questions after age and gender 
#(selected these two since some people made a response but didn't fill out their age or gender)
patients_cols <- filter(patients_cols, DiscussWithDoctor != "" & FirstThoughtBC != "") 

##### This was an attempt to see the difference between Concerns and Concerns1
patient_cols_concerns <- patients_cols %>% 
select (ResponseID, Concerns, Concerns1)
  
#####################
#There are two WhyInterested, DidUHaveChoice, OptionChoice columns. 
#This happened because people who answered "no" to discussing it with their doctor got these questions in a slightly different format. Here we are going to merge them into the other column?
# Was tryna get this to work but it looks like it's not :(


#patients_cols_combine[patients_cols==""] <- NA
#patients_cols_combined <- patients_cols(WhyInterested = coalesce(!!! DF), WhyInterested1 = coalesce(!!! rev(DF)))

#patients_cols$WhyInterested = case_when(patients_cols$WhyInterested == " " ~ NA)

#patients_cols_combined <- patients_cols %>% 
 # mutate(WhyInterested2 = case_when(
  #  WhyInterested1 == "" ~ NA)) %>%
  #mutate(WhyInterested2 = gsub(WhyInterested, WhyInterested1)) %>%
  #mutate(WhyInterested3 = coalesce(WhyInterested, WhyInterested2)) %>%
  #select (WhyInterested, WhyInterested1, WhyInterested2)
  
######################

# let's make a dataframe (contact_list or contact_list_cols) where it's only people who gave us their email to contact them
contact_list <- filter(patients, E.mail. != "")
contact_list_cols <- filter(patients_cols, Email != "")

#create a df that shows how many responses we got from each state
answersbyState <- patients_cols %>% 
  group_by(region) %>% 
  summarize(total=n()) %>%
  arrange(desc(total))

#create a df that shows how many responses we got from each age group
answersbyAge <- patients_cols %>% 
  group_by(Age) %>% 
  summarize(total=n()) %>%
  arrange(desc(total))

#create a df that shows how many responses we got for each stated goal of taking BC
answersbyGoals <- patients_cols %>%
  mutate(GoalsforBC= strsplit(as.character(GoalsforBC), ",")) %>% #split the row by commas so we have a single goal on each row
  unnest(GoalsforBC) %>% #make each split its own row
  mutate(GoalsforBC= trimws(GoalsforBC)) %>% #trim whitespace after splitting so we don't get multiple readings of the same goal
  group_by(GoalsforBC) %>% 
  summarize(total=n()) %>%
  arrange(desc(total))

#create a df that shows how many responses we got for each individual concern about taking BC
#requires clean-up of comma-separated errors that are introduced. 
answersbyConcerns <- patients_cols %>%
  mutate(Concerns= strsplit(as.character(Concerns), ",")) %>% #split the row by commas so we have a single goal on each row
  unnest(Concerns) %>% 
  mutate(Concerns= trimws(Concerns)) %>% #trim whitespace after splitting so we don't get multiple readings of the same goal
  group_by(Concerns) %>% 
  summarize(total=n()) %>%
  filter(!Concerns %in% c("or having an IUD put in)", "not men")) %>% # this is my not-ideal way to address the comma-separated error -- maybe edit the obvs directly instead to clean this up
  arrange(desc(total))

###### Filtering the answers to which birth control option they choose #######
#this is how you deal with user-entered data that should have been a multiple-choice question instead!!!!!!

#setting up the array for filtering the BC options in answersbyChoice. this sets up for my tidyverse magnum opus.
filter_actual_choices <- c("birth control pills", "IUD", "withdrawal","nuvaring","fertility awareness", "patch", "cervical cap", "implant", "spermicide", "condoms")

#this creates a discrete dataframe of the birth control option they utimately choose. some people typed in more than one answer, this
#splits them into their own categories for making tidy data, graphing, etc
answersbyChoice <- patients_cols %>%
  mutate(OptionChoice= strsplit(as.character(OptionChoice), ",")) %>% #split the row by commas so we have a single goal on each row
  unnest(OptionChoice) %>% #make each item we comma-separated its own row
  mutate(OptionChoice= strsplit(as.character(OptionChoice), "&")) %>% #getting the person who split their answers by &
  unnest(OptionChoice) %>%
  mutate(OptionChoice= strsplit(as.character(OptionChoice), ";")) %>% #getting the person who split their answers by a semicolon
  unnest(OptionChoice) %>%
  mutate(OptionChoice= strsplit(as.character(OptionChoice), "and")) %>% #getting the person who split their answers by "and"
  unnest(OptionChoice) %>%
  mutate(OptionChoice= strsplit(as.character(OptionChoice), "\\.")) %>% #getting the person who split their answers by "and"
  unnest(OptionChoice) %>%
  mutate(OptionChoice= trimws(OptionChoice)) %>% #trim whitespace after splitting so we don't get multiple readings of the same goal
  mutate(OptionChoice= str_to_lower(OptionChoice)) %>% #easier to match duplicates if we eliminate variation in capitalization
  #collasped "yaz" into "birth control pills" even though it's progestin-only. We can change this if we want to pull it out later
  mutate(OptionChoice=str_replace(OptionChoice, ".*(pill|oral contraceptive|junel|yaz).*","birth control pills")) %>% #is this regex??? love it, because it find all instances of "pill" or "oral contraceptive" with anything on either side of it and replaces the whole thing!!!!! (heart eye emoji)
  mutate(OptionChoice=str_replace(OptionChoice, ".*condom.*","condoms")) %>% 
  mutate(OptionChoice=str_replace(OptionChoice, ".*(iud|mirena).*","IUD")) %>% 
  mutate(OptionChoice=str_replace(OptionChoice, ".*(withdrawal|withdrawls).*","withdrawal")) %>% 
  mutate(OptionChoice=str_replace(OptionChoice, ".*ring.*","nuvaring")) %>% 
  mutate(OptionChoice=str_replace(OptionChoice, ".*patch.*","patch")) %>% 
  mutate(OptionChoice=str_replace(OptionChoice, ".*(fam|nfp).*","fertility awareness")) %>% 
  group_by(OptionChoice) %>% 
  summarize(total=n()) %>%
  filter(OptionChoice %in% filter_actual_choices) %>% #filter out the errors that the str_splits introduced
  arrange(desc(total))

#this was definitely the hardest one. All the others are multiple choice.
##########


###df of Bc options they didnt know about. Includes clean-up of comma-separated errors in an array
answersbyDidntKnow<- patients_cols %>%
  mutate(DidntKnowAbout= strsplit(as.character(DidntKnowAbout), ",")) %>% #split the row by commas so we have a single goal on each row
  unnest(DidntKnowAbout) %>%
  mutate(DidntKnowAbout= trimws(DidntKnowAbout)) %>% #trim whitespace after splitting so we don't get multiple readings of the same goal
  group_by(DidntKnowAbout) %>% 
  summarize(total=n()) %>%
  filter(!DidntKnowAbout %in% c("Nexplanon)", "sex only on safe days)", "Skyla)", "Essure)")) %>% #filter out the errors that the comma separation introduced
  arrange(desc(total))

########## MAKE AND SAVE GRAPHS ##############

#make a bar graph of the respondents' AGES. used patients_cols to simplify and just use the count for y
 ggplot(patients_cols,
       aes(x=Age))+ 
  geom_bar()+
  labs(x="Respondent Age", y="Number of Respondents",
       title= "How old are you?",
       caption="Emmi birth control survey 2018") +
   theme_economist_white() +
   ggsave("graphs/Age_Graph2018.jpg")


 #make a bar graph of the respondents' GOALS. Wanted to preserve the editing of the values I did earlier so used answersbygoals
 #and y=total, stat="identity" to make it work. Flipped the coordinates for readability
 ggplot(answersbyGoals) +
   geom_bar(aes(x=GoalsforBC, y=total), stat="identity") +
   coord_flip()
 
####make the same GOALS graph but in descending order.  this one does the same thing but it's probably cleaner to put the aes in ggplot
 # even though this creates the exact same dataframe as the one its passed, still necessary to reorder in the graph? 
 #can't believe that the -total actually worked to reverse the order!!!
  answersbyGoalsgg <- answersbyGoals %>% 
   mutate(GoalsforBC = fct_reorder(GoalsforBC, desc(-total)))

 ggplot(answersbyGoalsgg, aes(x=GoalsforBC, y=total)) +
   geom_bar (stat="identity") +
   coord_flip()+
   labs( y="Number of Answers", x="",
        title="What were your goals for birth control?",
        caption="Respondents could select multiple options. From the Emmi birth control survey 2018") +
   theme_economist_white() +
   ggsave("graphs/BC_Goals_Graph2018.jpg")

 
 ####CONCERNS graph
 answersbyConcernsgg <- answersbyConcerns %>% 
   mutate(Concerns = fct_reorder(Concerns, desc(-total)))
 
 ggplot(answersbyConcernsgg, aes(x=Concerns, y=total)) +
   geom_bar (stat="identity") +
   coord_flip()+
   labs( y="Number of Answers", x="",
         title="Any concerns about the options you were given?",
         caption="Respondents could select multiple options. From the Emmi birth control survey 2018") +
   theme_economist_white() +
   ggsave("graphs/BC_Concerns_Graph2018.jpg")
 
 ####DIDNT KNOW graph
 answersbyDidntKnowgg <- answersbyDidntKnow %>% 
   mutate(DidntKnowAbout = fct_reorder(DidntKnowAbout , desc(-total)))
 
 ggplot(answersbyDidntKnowgg, aes(x=DidntKnowAbout, y=total)) +
   geom_bar (stat="identity") +
   coord_flip() +
   labs( y="Number of Answers", x="",
         title="Did your doctor tell you about any methods you didn't already know about?",
         caption="Respondents could select multiple options. From the Emmi birth control survey 2018") +
   theme_economist_white() +
   ggsave("graphs/BC_DidntKnow_Graph2018.jpg")
 
 ####CHOICE graph (made possible by heavily modifying answersbyChoice)
 answersbyChoicegg <- answersbyChoice %>% 
   mutate(OptionChoice = fct_reorder(OptionChoice, desc(-total)))
 
 ggplot(answersbyChoicegg, aes(x=OptionChoice, y=total)) +
   geom_bar (stat="identity") +
   coord_flip() +
   labs( y="Number of Answers", x="",
         title="What options did you choose?",
         caption="Respondents could select multiple options. From the Emmi birth control survey 2018") +
   theme_economist_white() +
   ggsave("graphs/BC_OptionChoice_Graph2018.jpg")
 
 ################# EXPORT CLEANED DATA ##############
 
#export the cleaned up data frame for design to use
write_csv(patients_cols, "data/BirthControlSurvey_2018_cleaned.csv", na="")

#export the cleaned up data frame for design to use
write_csv(contact_list_cols, "data/BirthControlSurvey_CONTACT_LIST_2018_cleaned.csv", na="")
