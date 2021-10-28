# Movie_Recommendation_system
This is a system aimed at suggesting relevant movies to users based on past interactions.In an era of information overload it is difficult for users to get items they are really interested in,the goal of this project is to develop a model that will predict movies users are interested using rating data collected to enhance user experience in an online streaming service

**The Algorithm**
Collaborative Filtering evaluates products using users’ ratings (explicit or implicit) from historical
data. It works by developing a database of the user’s preferences for items. Active users will be mapped against this database to reveal the active user’s neighbors with similar purchase
preferences. There have been many
collaborative filtering algorithm measures that calculate the similarities among users. The similarity measures used is cosine
similarity, Spearman correlation, and adjusted cosine similarity. Collaborative filtering is the commonly used choice for recommendation system, and it does not require domain knowledge because the embeddings
are automatically learned. Embedding of items in a recommender system refers to mapping items to a sequence of numbers. This way of representing items with learned vectors, is used to train algorithms
to find the relationship between items and extract their features. Next, an advantage of collaborative filtering is that it generates models that help users discover new interests. Finally, collaborative
filtering is a great starting point for other Recommendation system, as the Recommendation System only requires the rating matrix R to develop a
factorization model. The rating matrix R is a two-dimensional matrix of n users and m items; each
entry in this matrix, rij represents the rating provided of user i to item j. Although being favorable in
many aspects, collaborative filtering has several disadvantages, such as the cold-start problem.
The algorithm used innthis work is an item based recommendation system which is a type of recommendation method based solely on the past interaction recorded between user and items in order to produce new recommendation stored in user-item interaction matrix.

**Dataset**
Dataset used is the movielens 100k dataset with 100,000 rating from 1000 users on 1700 movies. dataset is available in the dataset folder which contains two csv files movies.csv and rating.csv
