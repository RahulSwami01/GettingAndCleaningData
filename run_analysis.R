# ReadDataFileFile function:-> for reading dataset and merging all files
# PrefixPath:-> path for datafile.
# The SuffixFname:->File name suffix to create the complete file name.
#
# This also subsets the data to extract only the measurements on the mean and standard deviation for each measurement.
# The required columns in the subset is determined by selecting only those columns that have either "mean()" or "std()" in their names.
# Subsetting is done early on to help reduce memory requirements.
ReadDataFile <- function(SuffixFname, PrefixPath) {
    FilePath <- file.path(PrefixPath, paste0("y_", SuffixFname, ".txt"))
    DataY <- read.table(FilePath, header=F, col.names=c("ActivityID"))
    
    FilePath <- file.path(PrefixPath, paste0("subject_", SuffixFname, ".txt"))
    subject_data <- read.table(FilePath, header=F, col.names=c("SubjectID"))
    
    # read the column names
    data_cols <- read.table("features.txt", header=F, as.is=T, col.names=c("MeasureID", "MeasureName"))
    
    # read the X data file
    FilePath <- file.path(PrefixPath, paste0("X_", SuffixFname, ".txt"))
    data <- read.table(FilePath, header=F, col.names=data_cols$MeasureName)
    
    # names of subset columns required
    subset_data_cols <- grep(".*mean\\(\\)|.*std\\(\\)", data_cols$MeasureName)
    
    # subset the data (done early to save memory)
    data <- data[,subset_data_cols]
    
    # append the activity id and subject id columns
    data$ActivityID <- DataY$ActivityID
    data$SubjectID <- subject_data$SubjectID
    
    # return the data
    data
}


# read test data set, in a folder named "test", and data file names suffixed with "test"
ReadTestDataFile <- function() {
    ReadDataFile("test", "test")
}


# read test data set, in a folder named "train", and data file names suffixed with "train"
ReadTrainDataFile <- function() {
    ReadDataFile("train", "train")
}


# Merge both train and test data sets
# Also make the column names nicer
mergeData <- function() {
    data <- rbind(ReadTestDataFile(), ReadTrainDataFile())
    cnames <- colnames(data)
    cnames <- gsub("\\.+mean\\.+", cnames, replacement="Mean")
    cnames <- gsub("\\.+std\\.+",  cnames, replacement="Std")
    colnames(data) <- cnames
    data
}


# Add the activity names as another column
applyActivityLabel <- function(data) {
    activity_labels <- read.table("activity_labels.txt", header=F, as.is=T, col.names=c("ActivityID", "ActivityName"))
    activity_labels$ActivityName <- as.factor(activity_labels$ActivityName)
    data_labeled <- merge(data, activity_labels)
    data_labeled
}


# Combine training and test data sets and add the activity label as another column
getMergedLabeledData <- function() {
    applyActivityLabel(mergeData())
}


# Create a tidy data set that has the average of each variable for each activity and each subject.
getTidyData <- function(merged_labeled_data) {
if (!require("data.table")) {
  install.packages("data.table")
}


if (!require("reshape2")) {
  install.packages("reshape2")
}

    library(reshape2)
    
    # melt the dataset
    id_vars = c("ActivityID", "ActivityName", "SubjectID")
    measure_vars = setdiff(colnames(merged_labeled_data), id_vars)
    melted_data <- melt(merged_labeled_data, id=id_vars, measure.vars=measure_vars)
    
    # recast 
    dcast(melted_data, ActivityName + SubjectID ~ variable, mean)    
}


# Create the tidy data set and save it on to the named file
createTidyDataFile <- function(fname) {
    tidDataY <- getTidyData(getMergedLabeledData())
    write.table(tidDataY, fname)
}

print("Assuming data files from the \"UCI HAR Dataset\" are availale in the current directory with the same structure as in the downloaded archive.")
print("    Refer Data:")
print("    archive: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
print("    description: dataset: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones")
print("Creating tidy dataset as tidy.txt...")

createTidyDataFile("tidy.txt")
print("Done.")


