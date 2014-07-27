GettingAndCleaningData
======================
# ReadDataFileFile function:-> for reading dataset and merging all files
# PrefixPath:-> path for datafile.
# The SuffixFname:->File name suffix to create the complete file name.
#
# This also subsets the data to extract only the measurements on the mean and standard deviation for each measurement.
# The required columns in the subset is determined by selecting only those columns that have either "mean()" or "std()" in their names.
# Subsetting is done early on to help reduce memory requirements.

# read test data set, in a folder named "test", and data file names suffixed with "test"

# read test data set, in a folder named "train", and data file names suffixed with "train"

# Merge both train and test data sets
# Also make the column names nicer

# Add the activity names as another column

# Combine training and test data sets and add the activity label as another column

# Create a tidy data set that has the average of each variable for each activity and each subject.

# Create the tidy data set and save it on to the named file
