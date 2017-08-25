# This is an R script that does the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each
#    measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set
#    with the average of each variable for each activity and each subject.

# Load libraries
library("data.table")
library(reshape2)

# Load activity labels
activityLabels <- read.table(".\\UCI HAR Dataset\\activity_labels.txt")[, 2]

# Load variable names
features <- read.table(".\\UCI HAR Dataset\\features.txt")[, 2]

# Create dataset from training subject data file
trainSubjectData <- read.table(".\\UCI HAR Dataset\\train\\subject_train.txt")

# Set the variable name for subject
names(trainSubjectData) <- "subject"

# Create dataset from training labels data file
trainYData <- read.table(".\\UCI HAR Dataset\\train\\y_train.txt")
trainYData[, 2] <- activityLabels[trainYData[, 1]]

# Set the variable names for activities
names(trainYData) <- c("activityclass", "activityname")

# Create dataset from training data file
trainXData <- read.table(".\\UCI HAR Dataset\\train\\X_train.txt")

# Set the variable names for measurements
names(trainXData) <- features

# Create a training dataset adding all the datasets
trainData <- cbind(as.data.table(trainSubjectData), trainYData, trainXData)

# Create dataset from test subject data file
testSubjectData <- read.table(".\\UCI HAR Dataset\\test\\subject_test.txt")

# Set the variable name for subject
names(testSubjectData) <- "subject"

# Create dataset from training labels data file
testYData <- read.table(".\\UCI HAR Dataset\\test\\y_test.txt")
testYData[, 2] <- activityLabels[testYData[, 1]]

# Set the variable names for activities
names(testYData) <- c("activityclass", "activityname")

# Create dataset from test data file
testXData <- read.table(".\\UCI HAR Dataset\\test\\X_test.txt")

# Set the variable names for measurements
names(testXData) <- features

# Create a test dataset adding all the datasets
testData <- cbind(as.data.table(testSubjectData), testYData, testXData)

# Merge training and test datasets
data <- rbind(trainData, testData)

# Get the measurements on the mean and standard deviation for each
# measurement
dataMeanAndStd <- data[, grep("-mean()|-std()|subject|activityclass|activityname",
                              colnames(data)), with=FALSE]

# Set the id variables and the measure variables by melting the dataset
idVars <- c("subject", "activityclass", "activityname")
measureVars <- setdiff(colnames(dataMeanAndStd), idVars)
meltDataMeanAndStd <- melt(dataMeanAndStd, id = idVars, measure.vars = measureVars)

# Get the average of each variable for each activity and each subject
tidyData <- dcast(meltDataMeanAndStd, subject + activityclass ~ variable, mean)
write.table(tidyData, file = ".\\tidy_data.txt", row.name = FALSE)