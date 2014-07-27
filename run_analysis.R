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

mergeData <- function() {
    data <- rbind(ReadTestDataFile(), ReadTrainDataFile())
    cnames <- colnames(data)
    cnames <- gsub("\\.+mean\\.+", cnames, replacement="Mean")
    cnames <- gsub("\\.+std\\.+",  cnames, replacement="Std")
    colnames(data) <- cnames
    data
}

applyActivityLabel <- function(data) {
    activity_labels <- read.table("activity_labels.txt", header=F, as.is=T, col.names=c("ActivityID", "ActivityName"))
    activity_labels$ActivityName <- as.factor(activity_labels$ActivityName)
    data_labeled <- merge(data, activity_labels)
    data_labeled
}



    applyActivityLabel(mergeData())
}



getTidyData <- function(merged_labeled_data) {
if (!require("data.table")) {
  install.packages("data.table")
}


