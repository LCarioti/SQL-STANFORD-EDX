* SQL Social-Network Query Exercises

Q1
-- 1/1 point (graded)
-- Find the names of all students who are friends with someone named Gabriel.
SELECT H1.name
FROM (Highschooler H1 INNER JOIN Friend on H1.ID = Friend.ID1) INNER JOIN Highschooler H2 on H2.ID = Friend.ID2
WHERE H2.name = 'Gabriel';

Q2
-- 1/1 point (graded)
-- For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM ( Highschooler H1 INNER JOIN Likes on H1.ID = Likes.ID1 ) INNER JOIN Highschooler H2 on H2.ID = Likes.ID2
WHERE ( H1.grade - H2.grade ) >= 2;

Q3
-- 1/1 point (graded)
-- For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Highschooler H2, Likes L1, Likes L2
where ( H1.ID = L1.ID1 and H2.ID = L1.ID2) and ( H1.ID = L2.ID2 and H2.ID = L2.ID1) and H1.name < H2.name
ORDER by H1.name, H2.name;

Q4
-- 1/1 point (graded)
-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
SELECT name , grade 
FROM Highschooler 
WHERE ID not in ( SELECT DISTINCT ID1 FROM  Likes UNION SELECT DISTINCT ID2 FROM Likes)
ORDER by  grade, name ;

Q5
-- 1/1 point (graded)
-- For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
SELECT H1.name,H1.grade, H2.name, H2.grade
FROM ( Highschooler H1 INNER JOIN Likes on H1.ID = Likes.ID1)  INNER JOIN Highschooler H2 on H2.ID = Likes.ID2
WHERE (H1.ID = Likes.ID1 and H2.ID = Likes.ID2) and H2.ID not in ( SELECT DISTINCT ID1 FROM Likes);

Q6
-- 1/1 point (graded)
-- Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.
SELECT DISTINCT H1.name , H1.grade
from Highschooler H1, Friend
WHERE ID NOT IN ( SELECT ID1 FROM Friend ,  Highschooler H2 where H1.ID = Friend.ID1 and H2.ID = Friend.ID2 AND H1.grade <> H2.grade)
ORDER BY H1.grade, H1.name;

Q7
-- 1/1 point (graded)
-- For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.
SELECT DISTINCT H1.name, H1.grade , H2.name , H2.grade , H3.name , H3.grade
from Highschooler H1 , Highschooler H2 , Highschooler H3 , Likes , Friend F1 , Friend F2
where ( H1.ID = Likes.ID1 and H2.ID = likes.ID2) and  H1.ID not in ( SELECT ID1 FROM Friend WHERE  H2.ID = Friend.ID2)
AND (H1.ID = F1.ID1 AND H3.ID = F1.ID2) AND (H2.ID = F2.ID1 and H3.ID = F2.ID2);

Q8
-- 1/1 point (graded)
-- Find the difference between the number of students in the school and the number of different first names.
SELECT count(*) - count(DISTINCT name)
from Highschooler ;

Q9
-- 1/1 point (graded)
-- Find the name and grade of all students who are liked by more than one other student.
SELECT name, grade
from Highschooler inner JOIN likes on ID = ID2
GROUP BY ID2
HAVING count(ID2) >1
order by name;


* SQL Social-Network Query Exercises Extras

Q1
-- 0 points (ungraded)
-- For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.
SELECT DISTINCT H1.name, H1.grade , H2.name , H2.grade , H3.name , H3.grade
from Highschooler H1 , Highschooler H2 , Highschooler H3 , Likes L1 , Likes L2
where ( H1.ID = L1.ID1 and H2.ID = L1.ID2) and ( H2.ID = L2.ID1 and H3.ID = L2.ID2 and H3.ID  <> H1.ID);

Q2
-- 0 points (ungraded)
-- Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.
SELECT H1.name, H1.grade
from Highschooler H1
WHERE grade not in ( SELECT H2.grade FROM Highschooler H2 , Friend where H1.ID = Friend.ID1 and H2.ID = Friend.ID2);

Q3
-- 0 points (ungraded)
-- What is the average number of friends per student? (Your result should be just one number.)
SELECT avg(countFriend)
FROM ( SELECT count(*) as countFriend FROM Friend GROUP BY ID1);

Q4
-- 0 points (ungraded)
-- Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.
SELECT count(*)
FROM Friend
where ID1 in (
SELECT ID2 FROM Friend WHERE ID1 IN (
SELECT ID FROM Highschooler WHERE name = 'Cassandra'));

Q5
-- 0 points (ungraded)
-- Find the name and grade of the student(s) with the greatest number of friends.
SELECT name, grade
FROM Highschooler INNER JOIN Friend on ID = ID1
GROUP BY ID1
HAVING count(*) = (
SELECT max(countF) FROM ( SELECT count(*) as countF  FROM Friend  GROUP BY ID1));
  

* SQL Social-Network Modification Exercises

Q1
-- 1/1 point (graded)
-- It's time for the seniors to graduate. Remove all 12th graders from Highschooler.
DELETE FROM Highschooler
WHERE grade in (
SELECT ID FROM Highschooler WHERE grade = 12);

Q2
-- 1/1 point (graded)
-- If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
DELETE FROM Likes where ID1 in ( SELECT Likes.ID1 FROM Likes INNER JOIN Friend using(ID1) WHERE Likes.ID2 = Friend.ID2 ) and ID2 not in ( SELECT Likes.ID1 FROM Likes INNER JOIN Friend using(ID1) WHERE Likes.ID2 = Friend.ID2);

Q3
-- 1/1 point (graded)
-- For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)
SELECT DISTINCT F1.ID1 , F2.ID2
FROM Friend F1, Friend F2
WHERE F1.ID1 <> F2.ID2 and F2.ID1 = F1.ID2 and F1.ID1 NOT IN ( SELECT F3.ID1 FROM Friend F3 where F3.ID2 = F2.ID2);


