
### Getting and Cleaning Data Course Project 

# Clean up workspace
rm(list=ls())

library(reshape2)
library(plyr)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, mode='wb')
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}


setwd(paste0(getwd(),"/UCI HAR Dataset"))


# Question 1 
# Merge the training and test sets to create one data set

# Load activity labels and features
activityLabels <- read.table("activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresExtracted<- grep(".*mean.*|.*std.*", features[,2])
featuresExtracted.names <- features[featuresExtracted,2]
featuresExtracted.names <- gsub('-mean', 'Mean', featuresExtracted.names)
featuresExtracted.names <- gsub('-std', 'Std', featuresExtracted.names)
featuresExtracted.names <- gsub('[-()]', '', featuresExtracted.names)

# Load the datasets
train_X <- read.table("train/X_train.txt")[featuresExtracted]
trainActivities_Y <- read.table("train/Y_train.txt")
trainSubjects <- read.table("train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities_Y, train_X)

test_X <- read.table("test/X_test.txt")[featuresExtracted]
testActivities_Y <- read.table("test/Y_test.txt")
testSubjects <- read.table("test/subject_test.txt")
test <- cbind(testSubjects, testActivities_Y, test_X)

# merge datasets 

allData <- rbind(train, test)

#Appropriately label the data set with descriptive variable names

colnames(allData) <- c("subject", "activity", featuresExtracted.names)

# The average of each variable for each activity and each subject
# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
Averageofall <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(Averageofall, "tidy.txt", row.names = FALSE, quote = FALSE)

