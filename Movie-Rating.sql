* SQL Movie-Rating Query Exercises

Q1
-- 1/1 point (graded)
-- Find the titles of all movies directed by Steven Spielberg.
SELECT title FROM Movie WHERE director = 'Steven Spielberg';

Q2
-- 1/1 point (graded)
-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
SELECT year FROM Movie WHERE mID in (SELECT mID FROM Rating WHERE stars = 5 or stars = 4) ORDER by year ;

Q3
-- 1/1 point (graded)
-- Find the titles of all movies that have no ratings.
SELECT title FROM Movie where mID not in (SELECT mID FROM Rating);

Q4
-- 1/1 point (graded)
-- Some reviewers didn"\'t" provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
SELECT name FROM Reviewer where rID in ( SELECT rID FROM Rating WHERE ratingDate is  NULL);

Q5
-- 1/1 point (graded)
-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
SELECT name, title, stars, ratingDate
FROM Reviewer JOIN Rating join Movie
on Reviewer.rID = Rating.rID and Movie.mID = Rating.mID
ORDER by name, title, stars;

Q6
-- 1/1 point (graded)
-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.
SELECT name, title
FROM Movie JOIN Rating R1 using (mID) JOIN Rating R2 USING (rID, mID) JOIN Reviewer USING (rID)
WHERE R1.mID = R2.mID and R1.stars < R2.stars and R1.ratingDate < R2.ratingDate;

Q7
-- 1/1 point (graded)
-- For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.
SELECT title , max(stars)
from Movie NATURAL JOIN Rating
GROUP by title
ORDER by title;

Q8
-- 1/1 point (graded)
-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.
SELECT title , ( max(stars) - min(Stars)) as Spread
from Movie NATURAL JOIN Rating
GROUP by title
ORDER by Spread DESC , title ;

Q9
-- 1/1 point (graded)
-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)
SELECT avg(avgL80.avg1) - avg(avgM80.avg2)
FROM  (SELECT avg(stars) as avg1 FROM Rating NATURAL JOIN Movie WHERE year < 1980 GROUP by mID) as avgL80, (SELECT avg(stars) as avg2 FROM Rating NATURAL JOIN Movie WHERE year > 1980 GROUP by mID) AS avgM80;



* SQL Movie-Rating Query Exercises Extras

Q1
-- 0 points (ungraded)
-- Find the names of all reviewers who rated Gone with the Wind.
SELECT DISTINCT name FROM Reviewer NATURAL JOIN Rating NATURAL JOIN Movie
WHERE title = 'Gone with the Wind';

Q2
-- 0 points (ungraded)
-- For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
SELECT name , title, stars
FROM Reviewer NATURAL JOIN Rating NATURAL JOIN Movie
WHERE director = name;

Q3
-- 0 points (ungraded)
-- Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
SELECT name FROM Reviewer
UNION
SELECT title FROM Movie 
ORDER by name;

Q4
-- 0 points (ungraded)
-- Find the titles of all movies not reviewed by Chris Jackson.
SELECT title 
FROM Movie 
WHERE mID not in ( SELECT mID FROM Rating, Reviewer WHERE Rating.rID = Reviewer.rID and name = 'Chris Jackson');

Q5
-- 0 points (ungraded)
-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.
SELECT DISTINCT Rev1.name, Rev2.name
from Reviewer as Rev1, Reviewer as Rev2, Rating as R1, Rating as R2
WHERE R1.mID = R2.mID and R1.rID = Rev1.rID and R2.rID = Rev2.rID AND Rev1.name < Rev2.name 
ORDER by Rev1.name , Rev2.name;

Q6
-- 0 points (ungraded)
-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
SELECT name , title , stars FROM Reviewer NATURAL JOIN Rating NATURAL JOIN Movie
WHERE stars <= ( SELECT min(stars) from Rating);

Q7
-- 0 points (ungraded)
-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.
SELECT title, avg(stars) as StarRating
FROM Movie NATURAL JOIN Rating
GROUP BY title
ORDER BY StarRating DESC  , title;

Q8
-- 0 points (ungraded)
-- Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)
SELECT name 
FROM Reviewer NATURAL JOIN Rating
GROUP by rID
HAVING count(rID) >= 3;

Q9
-- 0 points (ungraded)
-- Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)
SELECT  title,  director
FROM Movie M1
WHERE ( SELECT count(*) FROM Movie M2 where M2.director = M1.director) > 1
ORDER by director, title;

Q10
-- 0 points (ungraded)
-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
SELECT title , avg(stars) as AvgStar
FROM Movie NATURAL JOIN Rating
GROUP by mID
HAVING AvgStar = ( SELECT max(StarAvg) FROM (SELECT title , avg(stars) as StarAvg from Movie NATURAL JOIN Rating GROUP by mID ));

Q11
-- 0 points (ungraded)
-- Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
SELECT title , avg(stars) as AvgStar
FROM Movie NATURAL JOIN Rating
GROUP by mID
HAVING AvgStar = ( SELECT min(StarAvg) FROM (SELECT title , avg(stars) as StarAvg from Movie NATURAL JOIN Rating GROUP by mID ));

Q12
-- 0 points (ungraded)
-- For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.
SELECT director , title, max(stars)
from Movie NATURAL JOIN Rating
WHERE director is not NULL
GROUP by director;


* SQL Movie-Rating Modification Exercises

Q1
-- 1/1 point (graded)
-- Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into Reviewer VALUES (209, 'Roger Ebert');

Q2
-- 1/1 point (graded)
-- For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)
UPDATE Movie
set year = year + 25
WHERE mID in ( SELECT mID from Movie NATURAL JOIN Rating GROUP BY mID HAVING avg(stars) >=4);

Q3
-- 1/1 point (graded)
-- Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
DELETE FROM Rating
where mID in ( SELECT mID FROM Rating WHERE mID in ( SELECT mID FROM Movie WHERE year < 1970 or year > 2000)) and stars < 4;
