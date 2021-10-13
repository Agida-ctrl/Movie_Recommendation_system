### Movie recommendation system ###
#type of recommendation system:item based collaborative filtering
#Packages:Recommenderlab,data.table,ggplot2,reshape2,skimr

##install required packages

install.packages(recommenderlab)
install.packages(reshape2)
install.packages(data.table)

#load required packages

library(recommenderlab)
library(reshape2)
library(data.table)
library(skimr)
library(ggplot2)
library(dplyr)


#read in the dataset

setwd("C:/Users/USER/Desktop/Data science projects/Movie recommendation system")
movies_data<-read.csv("movies.csv",stringsAsFactors = FALSE)
rating_data<-read.csv("ratings.csv")

skim(movies_data)
head(movies_data)
skim(rating_data)
head(rating_data)
rating_data %>% 
        group_by(userId) %>% 
        summarise(count=n())

                              ### DATA PREPROCESSING ####

# creating a one-hot encoding to create a matrix 
# that comprises of corresponding genres for each of the films
# that can be used with the userId and movieId since both columns are integer

genre<-as.data.frame(movies_data$genres)
genre_trans<-as.data.frame(tstrsplit(genre[,1],
                                      "[|]",type.convert = TRUE),
                            stringsAsFactors = FALSE)#split and transpose
colnames(genre_trans)<-c(1:10)
genre_list<-c("Action","Adventure","Animation","Children","Comedy",
              "Crime","Documentary","Drama","Fantasy","Film-Noir",
              "Horror","Musical","Mystery","Romance","Sci_Fic","Thriller",
              "War","Western")
genre_mat<-matrix(0,10330,18)#creating a matrix of zero
genre_mat[1,]<-genre_list
colnames(genre_mat)<-genre_list

for(i in 1:nrow(genre_trans)) {
        for(j in 1:ncol(genre_trans)) {
                gen_col=which(genre_mat[1,]== 
                                      genre_trans[i,j])
                genre_mat[i+1,gen_col]<-1
        }
}

genre_df<-as.data.frame(genre_mat[-1,],
                          stringsAsFactors = FALSE)
for(col in 1:ncol(genre_df)) {
        genre_df[,col]<-as.integer(genre_df2[,col])
}

str(genre_df)
# creating a search matrix

SearchMatrix <- bind_cols(movies_data[,-3], genre_df)
head(SearchMatrix)

# converting the rating dataset to a sparse matrix of class "realRatingMatrix" so recomenderlab
# can make sense of it

ratingMatrix<-reshape2::dcast(rating_data,userId~movieId,
                    value.var = "rating",na.rm=FALSE)#matrix with userID as row and movieID as col
ratingMatrix<-as.matrix(ratingMatrix[,-1])
ratingMatrix<-as(ratingMatrix,"realRatingMatrix")# convert to recommenderlab sparse matrix
ratingMatrix


                    ###Exploratory Analysis##

#exploring similar data since item based recommendation system is dependent on creating a relationship 
#of similarity between users

similarity_mat <-similarity(ratingMatrix[1:4,],
                             method = "cosine",
                             which="users") #similarity between first 4 users
as.matrix(similarity_mat)
image(as.matrix(similarity_mat), main = "User's Similarities")

#Delineate the similarity between movies
movie_similarity<-similarity(ratingMatrix[,1:4],
                             method = "cosine",
                             which = "items") #first 4 movies similarity
as.matrix(movie_similarity)
image(as.matrix(movie_similarity),main = "Movies similarity")

# checking the most unique ratings
rating_value<-as.vector(ratingMatrix@data)
table_of_rating<-table(rating_value)
table_of_rating

#checking most viewed movies

movie_views <- colCounts(ratingMatrix)#number of rating per column
table_views <- data.frame(movie = names(movie_views),
                          views = movie_views) 
table_views <- table_views[order(table_views$views,
                                 decreasing = TRUE), ]
table_views$title <- NA
for (index in 1:10325){
        table_views[index,3] <- as.character(subset(movies_data,
                                                    movies_data$movieId == table_views[index,1])$title)
}
ggplot(table_views[1:10, ], aes(x = title, y = views)) +
        geom_bar(stat="identity", fill = 'steelblue') +
        geom_text(aes(label=views), vjust=-0.3, size=3.5) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        
        ggtitle("Total Views of the Top Films")

image(ratingMatrix[1:20, 1:25],
      axes = FALSE, main = "Heatmap of the first 25 rows and 25 columns")


#Movies with the highest rating

movie_rating<-colMeans(ratingMatrix)
table_rating<-data.frame(movie=names(movie_rating),
                         rating=movie_rating)
table_rating<-table_rating[order(table_rating$rating,
                                    decreasing = TRUE),]

table_rating$title <- NA
for (index in 1:10325){
  table_rating[index,3] <- as.character(subset(movies_data,
                                              movies_data$movieId == table_rating[index,1])$title)
}


ggplot(table_rating[1:10,], aes(x=title,y=rating)) +
  geom_bar(stat="identity", fill = 'steelblue') +
  geom_text(aes(label=rating),vjust =-0.3,size=3.5) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  ggtitle("Top 10 higest rated movies")

#there are 118 movies which are rated 5.0 and above are the first 10

                               ### DATA PREPARATION ###

#Selecting useful data

movie_ratings <- ratingMatrix[rowCounts(ratingMatrix) > 50,
                              colCounts(ratingMatrix) > 50]
#minimum threshold for number of users that have rated a movie
Movie_ratings

minimum_movies<- quantile(rowCounts(movie_ratings), 0.98)
minimum_users <- quantile(colCounts(movie_ratings), 0.98)
image(movie_ratings[rowCounts(movie_ratings) > minimum_movies,
                    colCounts(movie_ratings) > minimum_users],
      main = "Heatmap of the top users and movies")



average_ratings <- rowMeans(movie_ratings)
qplot(average_ratings, fill=I("steelblue"), col=I("red")) +
        ggtitle("Distribution of the average rating per user")


#Data Normalization

normalized_ratings <- normalize(movie_ratings)
sum(rowMeans(normalized_ratings) > 0.00001)

image(normalized_ratings[rowCounts(normalized_ratings) > minimum_movies,
                         colCounts(normalized_ratings) > minimum_users],
      main = "Normalized Ratings of the Top Users")

#Binarizing the data 

binary_minimum_movies <- quantile(rowCounts(movie_ratings), 0.95)
binary_minimum_users <- quantile(colCounts(movie_ratings), 0.95)
movies_watched <- binarize(movie_ratings, minRating = 1)

good_rated_films <- binarize(movie_ratings, minRating = 3)
image(good_rated_films[rowCounts(movie_ratings) > binary_minimum_movies,
                       colCounts(movie_ratings) > binary_minimum_users],
      main = "Heatmap of the top users and movies")

                  ###Item based Collaborative filtering system###

#Splitting data in train and test set
sampled_data<- sample(x = c(TRUE, FALSE),
                      size = nrow(movie_ratings),
                      replace = TRUE,
                      prob = c(0.8, 0.2))
training_data <- movie_ratings[sampled_data, ]
testing_data <- movie_ratings[!sampled_data, ]

recommendation_system <- recommenderRegistry$get_entries(dataType ="realRatingMatrix")
recommendation_system$IBCF_realRatingMatrix$parameters

recommen_model <- Recommender(data = training_data,
                              method = "IBCF",
                              parameter = list(k = 30))

recommen_model
class(recommen_model)

model_info <- getModel(recommen_model)
class(model_info$sim)
dim(model_info$sim)
top_items <- 20
image(model_info$sim[1:top_items, 1:top_items],
      main = "Heatmap of the first rows and columns")

sum_rows <- rowSums(model_info$sim > 0)
table(sum_rows)

sum_cols <- colSums(model_info$sim > 0)
qplot(sum_cols, fill=I("steelblue"), col=I("red"))+ 
        ggtitle("Distribution of the column count")

#model validation

top_recommendations <- 10 # the number of items to recommend to each user
predicted_recommendations <- predict(object = recommen_model,
                                     newdata = testing_data,
                                     n = top_recommendations)
predicted_recommendations


user1 <- predicted_recommendations@items[[1]] # recommendation for the first user
movies_user1 <- predicted_recommendations@itemLabels[user1]
for (index in 1:10){
  movies_user1[index] <- as.character(subset(movies_data,
                                                   movies_data$movieId == movies_user1[index])$title)
}
movies_user1


recommendation_matrix <- sapply(predicted_recommendations@items,
                                function(x){ as.integer(colnames(movie_ratings)[x]) }) # matrix with the recommendations for each user
dim(recommendation_matrix)

for (i in 1:10){
  for (j in 1:102) {
    recommendation_matrix[i,j] <- as.character(subset(movies_data,
                                                         movies_data$movieId == recommendation_matrix[i,j])$title)
  }
}
recommendation_matrix[,1:4] # Recommendation for the first 4 users