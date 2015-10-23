# get current working directory. Data is assumed to be in this directory
WD <- getwd()

# Read the acitivity labels
activity_labels_filepath <- paste(WD,"/UCI HAR Dataset/activity_labels.txt",sep = "")
activity_labels <- read.table(activity_labels_filepath, sep=" ") # data is separated by space

# Read the features list
features_filepath <- paste(WD,"/UCI HAR Dataset/features.txt",sep = "")
features <- read.table(features_filepath, sep=" ") # data is separated by space

# read test data
subject_test <- read.table(paste(WD,"/UCI HAR Dataset/test/subject_test.txt",sep = ""))
X_test <- read.table(paste(WD,"/UCI HAR Dataset/test/X_test.txt",sep = ""))
y_test <- read.table(paste(WD,"/UCI HAR Dataset/test/y_test.txt",sep = ""))

# read train data
subject_train <- read.table(paste(WD,"/UCI HAR Dataset/train/subject_train.txt",sep = ""))
X_train <- read.table(paste(WD,"/UCI HAR Dataset/train/X_train.txt",sep = ""))
y_train <- read.table(paste(WD,"/UCI HAR Dataset/train/y_train.txt",sep = ""))

# combine test/train data together - both test and train datasets have same number and order of columns
AllSubject <- rbind(subject_test,subject_train) # combines all subject IDs
AllX <- rbind(X_test,X_train) # combines all feature data
Ally <- rbind(y_test,y_train) # combines all activity IDs

# make single dataset : 1. Merges the training and the test sets to create one data set.
Allactivity <- as.character(activity_labels[match(Ally[,1],activity_labels[,1]),2]) # find activity label : 3. Uses descriptive activity names to name the activities in the data set
Alldata <- cbind(AllSubject,Allactivity,AllX) # combine all input together to make a complete data frame with subjectIDs, appropriate activity labels and all features
AlldataHeader <- c("SubjectID","ActivityLabel",as.character(features[,2])) # make header by using the featuresname
names(Alldata) <- AlldataHeader # change header : 4. Appropriately labels the data set with descriptive variable names. 


# 4: extract only measurements on mean and std for each measurement
meanANDstdcols <- c(grep('SubjectID',names(Alldata),'r'),grep('ActivityLabel',names(Alldata),'r'),grep('*mean*',names(Alldata),'r'),grep('*std*',names(Alldata),'r')) # find the column numbers of subjectID, activitylabel and with 'mean' and 'std' in header
MeasurementsMeanStdONLY <- Alldata[,meanANDstdcols] # extract data with above column headers

SplitDataPerSubjectPerActivity <- split(MeasurementsMeanStdONLY,list(MeasurementsMeanStdONLY$ActivityLabel,MeasurementsMeanStdONLY$SubjectID),drop=T) # splits data for each combination of subject and activity
MeanPerSubjectPerActivity <- t(sapply(SplitDataPerSubjectPerActivity,function(x){colMeans(x[,3:length(names(MeasurementsMeanStdONLY))])},USE.NAMES=F)) # returns means of columns 3:81 for each combination
x <- unlist(strsplit(rownames(MeanPerSubjectPerActivity),"[.]")) # separate the List name for eevry mean, returns a 1D vector
y <- matrix(x,nrow=length(x)/2,ncol=2,byrow=T) # convert 1D vector into 2D matrix
y[,c(1,2)] <- y[,c(2,1)] # Interchange matrix columns, column1 <-> column2, this is done to keep the order as in original data
finalTidyData <- cbind(y,MeanPerSubjectPerActivity) # combine the subjectID, Activity label with the computed means per feature
rownames(finalTidyData) <- NULL # remove row.names
FinalDataHeader <- cbind(AlldataHeader[1],AlldataHeader[2],t(unlist(lapply(names(MeasurementsMeanStdONLY)[3:length(names(MeasurementsMeanStdONLY))],function(x){paste('MEAN',x)})))) # make correct data headers by adding "MEAN" as suffix to feature names
finalTidyData <- as.data.frame(finalTidyData) # convert to data frames
names(finalTidyData) <- FinalDataHeader # give appropriate headers
write.table(finalTidyData, "tidy_data.txt",row.name = F) # write file to disk
