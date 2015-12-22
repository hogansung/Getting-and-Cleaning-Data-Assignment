# Setting environment
setwd('UCI HAR Dataset/')
library(data.table)
library(dplyr)



# Read all data
tn_x = read.table('train/X_train.txt')
tn_y = read.table('train/y_train.txt')
tn_s = read.table('train/subject_train.txt')

tt_x = read.table('test/X_test.txt')
tt_y = read.table('test/y_test.txt')
tt_s = read.table('test/subject_test.txt')

feature_config = read.table('features.txt', col.names=c("featureId", "featureLabel"))
activity_config = read.table('activity_labels.txt', col.names=c("activityId", "activityLabel"))



# 1. Merges the training and the test sets to create one data set.
x = rbind(tn_x, tt_x)
y = rbind(tn_y, tt_y)
s = rbind(tn_s, tt_s)



# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
target = grep('mean\\(|std\\(', feature_config$featureLabel)
x = x[, target]



# 3. Uses descriptive activity names to name the activities in the data set
temp_y = merge(x=y, y=activity_config, by.x='V1', by.y='activityId', sort=FALSE)
y = mutate(y, activityLabel=temp_y$activityLabel)



# 4. Appropriately labels the data set with descriptive variable names. 
colnames(x) = feature_config$featureLabel[target]



# Merge the Dataset
colnames(s) = 'subject'
dat = cbind(s, x, y)
write.table(dat, 'tidy_data.txt')



# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
dat = data.table(dat)
dat = dat[, lapply(.SD, mean), by=c('subject', 'activityLabel')]
write.table(dat, 'ave_tidy_data.txt')
