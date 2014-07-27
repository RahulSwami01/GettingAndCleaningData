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


