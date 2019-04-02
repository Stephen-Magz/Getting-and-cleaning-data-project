#Check to see if the user has the "reshape2"package installed(this script relies on it)
if(!library(reshape2,logical.return = TRUE)){
        #It exists so we can continue
}

#Initialize some initial values
targetFolder<-'UCI HAR Dataset'
filename<-'getdata_dataset.zip'

#check if user has already unzipped the file
if(!file.exists(targetFolder)){
        #They have the zip file?
        if(!file.exists(filename)){
                
                #zip file doesn't exist, download it
                download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",filename)
        }
        
        #unzip the file
        unzip(filename)
}

#1. Merge the training and the test sets to create one data set.
#Read the data into the test and training sets
test.data<-read.table(file.path(targetFolder,"test","x_test.txt"))
test.activities<-read.table(file.path(targetFolder,"test","y_test.txt"))
test.subjects<-read.table(file.path(targetFolder,"test","subject_test.txt"))

train.data<-read.table(file.path(targetFolder,"train","x_train.txt"))
train.activities<-read.table(file.path(targetFolder,"train","y_train.txt"))
train.subjects<-read.table(file.path(targetFolder,"train","subject_train.txt"))

#Bind the rows for each of the dat sets together
data.data<-rbind(train.data,test.data)
data.activities<-rbind(train.activities,test.activities)
data.subjects<-rbind(train.subjects,test.subjects)

#Now combine the different columns into one table
full_data<-cbind(data.subjects,data.activities,data.data)

#2.Extract only meausurments on the mean and starndard deviation for each meausurement
#Get the full list of features
features<-read.table(file.path(targetFolder,"features.txt"))

#Filter the features you want
requiredFeautures<-features[grep("-(mean|std)\\(\\)",features[,2]),2]
full_data<-full_data[,c(1,2,requiredFeautures)]

#3.Use descriptive names to name the activities in the data set
#Read the activity lables
activities<-read.table(file.path(targetFolder,"activity_labels.txt"))

#update the activity name
full_data[,2]<-activities[full_data[,2],2]

#4.Appropriately label the data set with descriptive variable names.
colnames(full_data)<-c("subject","activity",gsub("\\-|\\(|\\)","",as.character(requiredFeautures)))

#Coerce the data into strings
full_data[,2]<-as.character(full_data[,2])

#5.From data set in step 4 create a second independent tidy data set with the average of each variable for each activity and subject.
#Melt the data so we have a unique row for each combination of subject and activities
final.melted<-melt(full_data,id=c("subject","activity"))

#Get mean value
final.mean<-dcast(final.melted,subject+activity~variable,mean)

#Emit data out to a file
write.table(final.mean,file = file.path("tidy.txt"),row.names = FALSE,quote = FALSE)


