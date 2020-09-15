#required packages
library(dplyr)

###########################################
#Part 0: Download and unzip data
###########################################

##This creates a storage directory in the workspace 
##and downloads the file from the given URL

if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="./data/coursera.zip")
## since it's all zipped, we call this function
unzip(zipfile="./data/coursera.zip",exdir="./data")
###########################################
#End of Part 0
###########################################

###########################################
# Part I:  Read in all the files to R
###########################################

###########################################
# Step 1: Go through all the files, build R objects
###########################################

# We'll name them the same as the .txt and go
# sequentially and alphabetically in folders/subfolders

#test data folder ./data/UCI HAR Dataset/test
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

#train data folder ./data/UCI HAR Dataset/test
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

#everything we need in the ./data

activity_labels = read.table('./data/UCI HAR Dataset/activity_labels.txt')
features <- read.table('./data/UCI HAR Dataset/features.txt')

###########################################
#Step 2:  Fix the table headers
###########################################
#we could have done this in the read.table() but it's harder
#to read the code with lots of options

colnames(subject_test) <- "Subject_ID"
colnames(X_test) <- features[,2] 
colnames(y_test) <- "Activity_ID"

colnames(subject_train) <- "Subject_ID"
colnames(X_train) <- features[,2]
colnames(y_train) <-"Activity_ID"

colnames(activity_labels) <- c('activityId','activityType')

###########################################
#Step 3:  Merge it all sensibly
###########################################

#not sure the bind order matters much, went alphabetical
#Then train, test.   It's all structured the same.
#We use rbind as we are putting the training/test split
#back together left/right

subject_data <- rbind(subject_train,subject_test)
X_data <- rbind(X_train,X_test)
y_data <- rbind(y_train,y_test)

## Probably want this order, seems intuitive, note the cbind
## We're combindingn columns left/right

full_data <- cbind(subject_data,y_data,X_data)

###################################################
#End of Part I
##################################################


##################################################
#Part II:  Means and StDev
##################################################

#This seems deceptively easy.  Only works because one
#can examine the headers to see structure with names()

mean_sd_data <- full_data %>%
  select(Subject_ID, Activity_ID, contains("mean"), contains("std"))

##################################################
#End of Part II
##################################################



##################################################
#Part III:  Change Activity_ID to actual activities
##################################################

#we finally use the activity file to do something with this data.
#saw something on Stack Exchange and in course video that gave the
#the activity_labels[] code bit.  I think this is supposed
#to be harder

mean_sd_data$Activity_ID <- 
  activity_labels[mean_sd_data$Activity_ID, 2]

#######################################################
#End of Part III
#######################################################


#######################################################
#Part IV: Rename the Vague Columns
#######################################################

#There's probably an elegant way to do this with regex
#I struggle there so I used head() to check names
#and gsub() like in the videos

#look at values to change
names(mean_sd_data)

#run through alphabetically, this is very brute force, but it works
names(mean_sd_data)<-gsub("Acc", "Accelerometer_", names(mean_sd_data))
names(mean_sd_data)<-gsub("angle", "Angle_", names(mean_sd_data))
names(mean_sd_data)<-gsub("BodyBody", "Body_", names(mean_sd_data))
names(mean_sd_data)<-gsub("gravity", "Gravity_", names(mean_sd_data))
names(mean_sd_data)<-gsub("Gyro", "Gyroscope_", names(mean_sd_data))
names(mean_sd_data)<-gsub("Jerk", "Jerk_", names(mean_sd_data))
names(mean_sd_data)<-gsub("Mag", "Magnitude_", names(mean_sd_data))
names(mean_sd_data)<-gsub("tBody", "Time_Body_", names(mean_sd_data))

#minor capitalization and cleanup, probably optional
names(mean_sd_data)<-gsub("^t", "Time_", names(mean_sd_data))
names(mean_sd_data)<-gsub("^f", "Frequency_", names(mean_sd_data))
names(mean_sd_data)<-gsub("-mean()", "Mean", names(mean_sd_data), ignore.case = TRUE)
names(mean_sd_data)<-gsub("-std()", "Standard_Deviation", names(mean_sd_data), ignore.case = TRUE)
names(mean_sd_data)<-gsub("-freq()", "_Frequency", names(mean_sd_data), ignore.case = TRUE)

#look at new names
names(mean_sd_data)

#much more descriptive

###########################################
#End of Part IV
###########################################

###########################################
#Part V: 2nd Dataset with means by Subject_ID and Activity_ID.
###########################################

tidy_Data <- mean_sd_data %>%
  group_by(Subject_ID, Activity_ID) %>%
  summarise_all(list(mean))

#last check before saving
head(tidy_Data)

#output to wd
write.table(tidy_Data, "./data/Final Tidy Data.txt", row.name=FALSE)

###########################################
#End Part V and End of Project
###########################################
