# Repo
Getting and cleaning data assignment

# Requirement
In this assignment it is assumed that the data is in the same folder structure as received and the root folder "UCI HAR Dataset" is in the working directory along with the script "run_analysis.R"

# Variables and script flow
In this section, a description of the variables along with the flow of the script is mentioned.

## Read Data
The first step is to read all raw data.
* Data variables : Variables "Activity_labels", "features", "subject_test", "X_test", "y_test", "subject_train", "X_train", "y_train" contain the data read from the dataset. These represent the raw data on which further processing is done to get the clean and tidy data in the end.

## Combine data of similar files for test and train datasets
In the next step all data is combined first for similar files (eg.: "subject_train" and "subject_test" combined into "AllSubject") using rbind().

## Use appropriate labels
The previous steps leads to vectors with all the data but still doesn't have descriptive labels for either the activities or the features. In this step this problem is solved along with combining all separate variables into a single data frame.
### Activity IDs to labels
* Since in the raw data the activity IDs and activity Labels are in two separate files, match() is used to find the label for each activity ID.
* The label-ID correspondence is read in the "activity_labels" variable as a data frame with ID in the 1st column and the label in the 2nd.
* match() returns the row index from the above data frame for every activity ID, which is converted to an acitivity label by accessing the 2nd column into the vector "Allactivity"
### Combine all variables into one data frame
* All individual variables are now combined into one data frame using cbind in the order SubjectIDs - Activity - Features.
* The result is in the "Alldata" data frame.
### give appropriate header
* one remaining step is to give appropriate header info to each variable
* The 2nd column of the "features" data frame contains the label for each used feature sorted in the same order as the raw data in columns.
* This is combined sequentially with apprpriate headers for the Subject ID and the activity using c() and then assigned to the vectir "AlldataHeader"

## Extracts only the measurements on the mean and standard deviation for each measurement. 
This corresponds to the step 2. of the problem statement
### find the correct column indices
* It is assumed that the problem statement refers to extract only those variables where mean or std of a measurement si calculated as a feature
* using grep(), the appropriate column  indices are extracted along with the SubjectID and ActivityLabel variables. This is in the vector "meanANDstdcols"
### extarct only corresponding data
* in this step the data is extracted for all the rows and stored in the data frame "MeasurementsMeanStdONLY"

##  independent tidy data set with the average of each variable for each activity and each subject
This corresponds to the step 5. of the problem statement
### separate data per subject per activity
* The data can be split per subject per activity using the split() function
* the parameter f in split, must be an intersection of the levels needed (subject and activity). This can be acheived using list().
* the result is a list with each element being a data frame contianing all the variables for the combination of a subject and an activity. This is stored in "SplitDataPerSubjectPerActivity"
### find mean of every variable per subject per activity
* Once the data is separated, the mean can calculated per list item using sapply(). The features whose mean has to be calculated is present in columns 3 to No. of columns and hence mean can be calculated with colMeans.
* A transpose is necessary to get the original data frame structure
* this results only in a dataframe with the features means. the subject ID and activity are not passed and need to be extracted from the list item name.
### find the subject id and activity label for each mean result
* the list element name is encoded as "activity_label.subject_ID"
* using strsplit() and unlist, the list element names is converted into a 1D character vector
* This 1D vector must next be converted into a 2 column vector corresponding to the original order (col1 = subject ID, col2 = activity label) using matrix() and interchanged to get the right order.
### make final tidy data
* the subjectID and activity label data is then combined with the means of the features to get the tidy data in "finalTidyData"
* To get the headers right, the current headers are first removed using rownames()
* The headers for the final tidy data are then created by combining the subject and activity headers and the headers for the features are suffixed with "MEAN". this is stored in "FinalDataHeader"
* the data is then converted into a data frame and the header is assigned to it

## write to file
in the final step the data frame with the tidy data is written to file
