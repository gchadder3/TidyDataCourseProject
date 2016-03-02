## run_analysis.R -- script for course project of Getting and Cleaning Data
##
## This script should be run with the unzipped UCI HAR dataset in the 
## working directory in a subdirectory called /UCI HAR Data.
## It will generate a tidy data file called subj_activ_feat_summaries.txt.
## For each of the pairs of (30) subjects and (6) activity labels, this 
## file will contain the means of 66 mean and standard deviation features
## for these 30 x 6 groupings.  This can be used downstream to analyze
## the main effects and interactions of subject and activity on the 
## observed accelerometer feature variables.
##
## Last update: 3/1/16 (George Chadderdon)

## Set up data directory paths.
rawDataPath <- "./UCI HAR Dataset"
trainDataPath <- sprintf("%s/train", rawDataPath)
testDataPath <- sprintf("%s/test", rawDataPath)


## Load the training data and splice it together.

## Load the X data (561 features).
fileName <- sprintf("%s/X_train.txt", trainDataPath)
dfr.Xtrain <- read.table(fileName)

## Load the y data (activity classes).
fileName <- sprintf("%s/y_train.txt", trainDataPath)
dfr.ytrain <- read.table(fileName)

## Load the subjects data.
fileName <- sprintf("%s/subject_train.txt", trainDataPath)
dfr.subjtrain <- read.table(fileName)

## Use cbind to put the X, y, and subjects train tables together.
dfr.train <- cbind(dfr.Xtrain, dfr.ytrain, dfr.subjtrain)

## Rename the last 2 column variables so they can be mutated more
## easily later.
names(dfr.train)[562] <- "V562"
names(dfr.train)[563] <- "V563"


## Load the test data and splice it together.

## Load the X data (561 features).
fileName <- sprintf("%s/X_test.txt", testDataPath)
dfr.Xtest <- read.table(fileName)

## Load the y data (activity classes).
fileName <- sprintf("%s/y_test.txt", testDataPath)
dfr.ytest <- read.table(fileName)

## Load the subjects data.
fileName <- sprintf("%s/subject_test.txt", testDataPath)
dfr.subjtest <- read.table(fileName)

## Use cbind to put the X, y, and subjects test tables together.
dfr.test <- cbind(dfr.Xtest, dfr.ytest, dfr.subjtest)

## Rename the last 2 column variables so they can be mutated more
## easily later.
names(dfr.test)[562] <- "V562"
names(dfr.test)[563] <- "V563"


## Use rbind to put together a table for all data, training and test.
dfr.all <- rbind(dfr.train, dfr.test)

## Sort the all set by the last column, so data is in order of
## subjects.  This is the complete data set with train and test 
## subsets merged.
library(dplyr)
dfr.all <- arrange(dfr.all, V563)


## Read the feature indices and names from the features.txt file into
## a character vector.
fileName <- sprintf("%s/features.txt", rawDataPath)
con <- file(fileName)
featureLines <- readLines(con)
close(con)

## Set up functions for pulling out first and second elements.
firstElement <- function(x) {x[1]}
secondElement <- function(x) {x[2]}

## Grep for lines that have "mean(" or "std(" in them.
goodFeatureLines <- grep("(mean[(])|(std[(])", featureLines, value=TRUE)

## Split the lines into the (column) indices and the raw feature names.
goodFeatureInfo <- strsplit(goodFeatureLines, " ")
goodFeatureInds <- as.integer(sapply(goodFeatureInfo, firstElement))
goodFeatureNames <- sapply(goodFeatureInfo, secondElement)

## Use gsubs to wrangle the raw feature names into nicer versions.
goodFeatureNames <- gsub("-m", "M", goodFeatureNames)
goodFeatureNames <- gsub("-s", "S", goodFeatureNames)
goodFeatureNames <- gsub("-X", "X", goodFeatureNames)
goodFeatureNames <- gsub("-Y", "Y", goodFeatureNames)
goodFeatureNames <- gsub("-Z", "Z", goodFeatureNames)
goodFeatureNames <- gsub("[(][)]", "", goodFeatureNames)


## Cull the columns we're interested in (the goodFeatureInds columns
## and the last two columns) and make a newer, smaller data.frame from 
## that.
dfr.clean <- select(dfr.all, c(goodFeatureInds, 562, 563))

## Change the column names over to the desired names for the 66
## features.
for (ind in seq_along(goodFeatureInds))
{
    names(dfr.clean)[ind] <- goodFeatureNames[ind]
}

## Change the last two columns to give what we want ("Activity" and 
## "Subject".)
names(dfr.clean)[length(goodFeatureInds) + 1] <- "Activity"
names(dfr.clean)[length(goodFeatureInds) + 2] <- "SubjectID"

## Create an activity number to string label converter function.
activNum2Str <- function(id)
{
    activStrs <- c("Walk", "WalkUpstairs", "WalkDownstairs", 
        "Sit", "Stand", "Lie")
    activStrs[id]
}

## Set the entries in the Activity column to the strings for those
## activities.
dfr.clean$Activity <- sapply(dfr.clean$Activity, activNum2Str)

## Convert the Activity column to a factor variable.
dfr.clean$Activity <- factor(dfr.clean$Activity, levels=c("Walk", 
    "WalkUpstairs", "WalkDownstairs", "Sit", "Stand", "Lie"))

## At this point, dfr.clean is the (tidy) dataset we have to work 
## with, by the end of Step 4 of the Course Project instructions.


## Create the final tidy data set (Step 5).

## Set up a grouping of the dataset by SubjectID / Activity pair.
subjActivGrp <- group_by(dfr.clean, SubjectID, Activity)

## Get summary table taking means of all of the variables.
## THIS IS THE FINAL TIDY SET I BELIEVE WE NEED TO WRITE TO A
## FILE.
## However, the two aggregate data frames below also provide useful
## summary information about the data collapsing over the the subjects
## and activities, respectively.
dfr.summary <- summarize_each(subjActivGrp, funs(mean))

## Set up groupings of the summary dataset by Activity.
activGrp <- group_by(dfr.summary, Activity)

## Create a summary collapsing across subjects.
dfr.actSummary <- summarize_each(activGrp, funs(mean)) 
dfr.actSummary <- select(dfr.actSummary, -SubjectID)

## Set up groupings of the summary dataset by SubjectID.
subjGrp <- group_by(dfr.summary, SubjectID)

## Create a summary collapsing across activities.
dfr.subjSummary <- summarize_each(subjGrp, funs(mean)) 
dfr.subjSummary <- select(dfr.subjSummary, -Activity)


## Write out the appropriate tidy data file to a file called
## subj_activ_feat_summaries.txt which is in the working 
## directory.
write.table(dfr.summary, "./subj_activ_feat_summaries.txt", 
    row.names=FALSE)
