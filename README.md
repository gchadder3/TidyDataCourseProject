TidyDataCourseProject
===============

This repo contains the course project for the Coursera Getting and Cleaning Data Course.  The following files are present in the directory:

* `README.md` -- this file
* `run_analysis.R` -- the R script for reading in the raw data sets (both train and test) from the Samsung data set, and extracting a tidy data set that summarizes 66 of the mean and standard-deviation features for each subject / activity group
* `CodeBook.md` -- the codebook file for the tidy data set that is constructed by the run_analysis.R script

## Using the run_analysis.R Script

1. Place the script in your R working directory.
2. Download this zip file: [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).
3. Unzip the archive so that the `UCI HAR Dataset` directory is in your R working directory.
4. Start R and type: `source('run_analysis.R')`.
5. A tidy data set file called `subj_activ_feat_summaries.txt` should be generated in the working directory.