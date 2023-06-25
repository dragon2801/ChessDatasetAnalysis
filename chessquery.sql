/* One thing I really love about data analysis is that I can almost take any dataset and perform my analysis to find patterns and insights.

As a chess player (an amateur one), when I found this dataset, I definitely wanted to run some analysis on it. This project was definitely fun, and I gained a lot of insights. Hopefully, it will help me improve my game.*/

/*First I created a table called chess.*/



CREATE TABLE chess(
id text, rated text, created_at text, last_move_at text,turns text,victory_status text,winner text,increment_code text,	white_id text,white_rating text,black_id text,	black_rating text,moves text,opening_eco text,opening_name text,opening_ply text)

COPY chess
FROM 'C:\Program Files\PostgreSQL\11\data\games.csv'
delimiter ',' header csv;

/*Dropped some columns not required for analysis*/

ALTER TABLE chess
drop column turns,drop column last_move_at,drop column opening_eco

--Cleaning the dataset.


SELECT *
FROM chess
WHERE id IS NULL
   AND rated IS NULL
   AND victory_status IS NULL
   AND result IS NULL
   AND increment_code IS NULL
   AND white_id IS NULL
   AND white_rating IS NULL
   AND black_id IS NULL
   AND black_rating IS NULL
   AND moves IS NULL
   AND opening_name IS NULL
   AND opening_ply IS NULL
   ;
--There were no null values.


--Removed duplicate ids
SELECT id, COUNT(*)
FROM chess
GROUP BY id
HAVING COUNT(*)>1

DELETE FROM chess
WHERE id in(
      SELECT max(id)
	  FROM chess
	  GROUP BY id
	  HAVING COUNT(*)>1)


--Changed the datatype of certain columns for smooth analysis

ALTER TABLE chess
ALTER COLUMN rated TYPE interval USING rated::boolean,
ALTER COLUMN white_rating TYPE interval USING white_rating::numeric,
ALTER COLUMN black_rating TYPE interval USING black_rating::numeric,
ALTER COLUMN opening_ply TYPE interval USING opening_ply::numeric;

--Some Data Manipulation
UPDATE chess
SET victory_status = REPLACE(victory_status, 'outoftime', 'out of time')
WHERE victory_status = 'outoftime';


ALTER TABLE chess
RENAME COLUMN winner TO result;

--Analyzing the Dataset

SELECT white_rating
FROM chess
ORDER BY white_rating Desc

/*The player with a rating of 2700 had the highest rating observed in the dataset, while the player with a rating of 784 had the lowest rating.*/

SELECT black_rating
FROM chess
ORDER BY black_rating desc

/*The player with a rating of 2723 had the highest rating observed in the dataset, while the player with a rating of 789 had the lowest rating.*/

/*I wanted to know what popluar openings were played to better prepare this openings myself.*/

SELECT opening_name, COUNT(*)
FROM chess
GROUP BY opening_name
HAVING COUNT(*)>1
ORDER BY 2 desc

/*"Sicilian Defense"
"Van't Kruijs Opening"
"Sicilian Defense: Bowdler Attack"
"French Defense: Knight Variation"
"Scotch Game"
"Scandinavian Defense: Mieses-Kotroc Variation"
"Queen's Pawn Game: Mason Attack"
"Scandinavian Defense"
"Horwitz Defense" 
"Queen's Pawn Game: Chigorin Variation"
these were top 10 openings played*/

/*I figured why not know lowest 10 openings played. Even if these are lowest plyed that doesn't always mean they are less popular but could be rare variation played that may not be known by people much which could give winning advantage to person playing such opening.*/

SELECT opening_name, COUNT(*)
FROM chess
GROUP BY opening_name
HAVING COUNT(*)>1
ORDER BY 2 

/*"Blackmar-Diemer Gambit: Vienna Variation"
"Nimzo-Indian Defense: Three Knights Variation |  Duchamp Variation"
"Gruenfeld Defense: Exchange Variation |  Spassky Variation"
"Nimzowitsch Defense: Kennedy Variation |  Keres Attack"
"Ruy Lopez: Closed |  8.c3"
"Semi-Slav Defense: Anti-Moscow Gambit"
"Grob Opening: Grob Gambit |  Fritz Gambit"
"French Defense: Tarrasch Variation |  Chistyakov Defense"
"Ruy Lopez: Open Variations |  Howell Attack #2"
"Queen's Gambit Declined: Modern |  Knight Defense" 
lowest ten opening*/

/*There is a very popular question always asked to chess player, Do you play e4 or d4 or somthing else? it sets the tone for what type of chess player they are. If you play e4 they assume you are an attacking player. So to know top 4 first moves played I ran this query. */


WITH subquery AS (
  SELECT SUBSTRING(moves FROM 1 FOR 3) AS first_move
  FROM chess
)
SELECT first_move, COUNT(*) 
FROM subquery
GROUP BY first_move
HAVING COUNT(*) > 1
ORDER BY 2 desc;

/*"e4 "	11462
"d4 "	4212
"c4 "	669
"Nf3"	597  e4 is played mostly. Lot of people likes to play attacking that means.*/

/*what were the popular responses given to the first move or what was the popular sequence of first two moves?*/


WITH subquery AS (
  SELECT SUBSTRING(moves FROM 1 FOR 6) AS first_sequence
  FROM chess
)
SELECT first_sequence, COUNT(*) 
FROM subquery
GROUP BY first_sequence
HAVING COUNT(*) > 1
ORDER BY 2 desc;

/*
"e4 e5 "	5429
"e4 c5 "	2376
"d4 d5 "	1980
"e4 e6 "	1254 these are some of the common sequence that are mostly played by players*/


/*
How many moves were played be people by thoery before they decided they wanted to play by their wish?*/

SELECT opening_ply, COUNT(*)
FROM chess
GROUP BY opening_ply
HAVING COUNT(*)>1
ORDER BY 2 desc

/*
3	3206
4	3019
2	2695
5	2487
6	1841
7	1229
8	1007
1	978
9	627
11	394
10	389
12	130
13	111
14	49
15	39
17	33
16	29
18	12
19	11
20	8
28	4

Only 3 moves of opening theroy were plyed. Mostly at least 10 moves should be played but only 389 out of 18300 people played upto 10 moves. It depends on opponent as well as how much moves they want to play by theory*/

--What was the victory_status?

SELECT victory_status, COUNT(*)
FROM chess
GROUP BY victory_status
HAVING COUNT(*)>1
ORDER BY 2 desc

/*
"resign"	10293
"mate"	5683
"out of time"	1526
"draw"	798*/
/*Lot of People resigned rather than holding the game it reaches till out of time which shows good sportmanship*/

--Which time controls were played mostly?
SELECT increment_code, COUNT(*)
FROM chess
GROUP BY increment_code
HAVING COUNT(*)>1
ORDER BY 2 desc

/*10+0 which is rapid time control was played mostly, followed by 15+0, 15+15. There could be time pressure in much shorter time control, So it is understable why these time controls are mostly played */


SELECT increment_code, COUNT(*)
FROM chess
WHERE increment_code = '3+2' or increment_code='3+0'
GROUP BY increment_code
HAVING COUNT(*)>1

/* To my suprise there were no data of playing 3+2 , 3+0 which is popular option people play but this dataset may not have that data but 5+5, 5+8 which are popular blitz option were present, at 4th and 5th rank*/

--Which colour won the most games?

SELECT result, COUNT(*)
FROM chess
GROUP BY result
HAVING COUNT(*)>1

--White HAVING advantage to play first won tons of games.

/*
"draw"	838
"black"	8314
"white"	9148*/

--Which top 5 ids were to win with white pieces?

SELECT white_id, result, COUNT(*)
FROM chess
WHERE result ='white' 
GROUP BY white_id,result
HAVING COUNT(*)>1
ORDER BY 3 desc

/*"ssf7"	"white"	29
"hassan1365416"	"white"	28
"1240100948"	"white"	22
"traced"	"white"	21
"ozguragarr"	"white"	21,  Top 5 ids to win with white*/

--Which top 5 ids were to win with black pieces?

SELECT black_id, result, COUNT(*)
FROM chess
WHERE result ='black'
GROUP BY black_id,result
HAVING COUNT(*)>1
ORDER BY 3 desc

/*
"chesscarl"	"black"	27
"docboss"	"black"	25
"smilsydov"	"black"	21
"doraemon61"	"black"	20
"cape217"	"black"	18, Top 5 black_id to win with black */

/*I searched for same id that were top 5 for white to see how they did with black pieces.*/

SELECT black_id, result, COUNT(*)
FROM chess
WHERE black_id in ('ssf7', 'hassan1365416', '1240100948', 'traced', 'ozguragarr')   and result = 'black'
GROUP BY black_id,result
HAVING COUNT(*)>1

--These are the result 
/*"1240100948"	"black"	 4
"traced"	"black"	 6    
other three ids didnt played with black pieces */


/*Also I searched for same id that were top 5 for black to see how they did with white pieces.*/

SELECT white_id, result, COUNT(*)
FROM chess
WHERE white_id in ('chesscarl', 'docboss', 'smilsydov', 'doraemon61', 'cape217')   and result = 'white'
GROUP BY white_id,result
HAVING COUNT(*)>1

--These are the result
/* "cape217"	"white"	2
"chesscarl"	"white"	18
"doraemon61"	"white"	18
"smilsydov"	"white"	15 
docboss didnt play with white pieces. The ids that did good by white doesnt necessarily mean that they did good by black. It goes same for black_id*/


/*which ids played the games most as white and is there a corealation between the no of games played and wins?


SELECT white_id, COUNT(*)
FROM chess 
GROUP BY white_id
HAVING COUNT(*)>1
ORDER BY 2 desc

/*"ssf7"	48
"bleda"	48
"hassan1365416"	44
"khelil"	41
"1240100948"	38
"ozguragarr"	38

The players who played the most were also the ones who won the most with ssf7 being the one to play the most also won the most.*/

--For ids as black 

SELECT black_id, COUNT(*)
FROM chess 
GROUP BY black_id
HAVING COUNT(*)>1
ORDER BY 2 desc

/*"docboss"	44
"cape217"	38
"amanan"	33
"erikweisz"	31
"jdbarger"	30
"pat222"	29
same here except docboss was the one who played most*/

--We know the top players by white and black, so of course being curious about what type of opening they play the most is there. Lot of chess players like to know about the details of the top players or their opponent and what they check first, what opening they play the most.

SELECT black_id, result,opening_name, COUNT(*)
FROM chess
WHERE black_id in ('chesscarl', 'docboss', 'smilsydov', 'doraemon61', 'cape217')   and result = 'black'
GROUP BY black_id,result,opening_name
HAVING COUNT(*)>1

/*
"cape217"	"black"	"Hungarian Opening"	2
"cape217"	"black"	"Sicilian Defense"	4
"cape217"	"black"	"Sicilian Defense: Canal-Sokolsky Attack"	2
"chesscarl"	"black"	"Sicilian Defense: Alapin Variation |  Smith-Morra Declined" 2
"chesscarl"	"black"	"Sicilian Defense: Kan Variation |  Wing Attack"	3
"chesscarl"	"black"	"Sicilian Defense: Lasker-Pelikan Variation |  Exchange Variation"	2
"docboss"	"black"	"King's Pawn Game: McConnell Defense"	10
"docboss"	"black"	"Queen's Pawn"	4
"doraemon61"	"black"	"Scandinavian Defense: Panov Transfer"	2
"smilsydov"	"black"	"Sicilian Defense: Bowdler Attack"	3
The opening choices are quite the popular openings played worldwide*/

--For Black ids

SELECT white_id, result,opening_name, COUNT(*)
FROM chess
WHERE white_id in ('ssf7', 'hassan1365416', '1240100948', 'traced', 'ozguragarr')   and result = 'white'
GROUP BY white_id,result,opening_name
HAVING COUNT(*)>1

/*
"1240100948"	"white"	"Dutch Defense"	2
"1240100948"	"white"	"Englund Gambit"	2
"1240100948"	"white"	"Horwitz Defense"	4
"1240100948"	"white"	"Indian Game"	3
"1240100948"	"white"	"Modern Defense"	3
"1240100948"	"white"	"Queen's Pawn"	2
"1240100948"	"white"	"Queen's Pawn Game: Mason Attack"	5
"hassan1365416"	"white"	"Four Knights Game: Italian Variation"	2
"hassan1365416"	"white"	"Giuoco Piano"	2
"hassan1365416"	"white"	"Italian Game: Anti-Fried Liver Defense"	2
"hassan1365416"	"white"	"Italian Game: Giuoco Pianissimo |  Italian Four Knights Variation"	2
"hassan1365416"	"white"	"Philidor Defense #3"	2
"hassan1365416"	"white"	"Russian Game: Three Knights Game"	2
"hassan1365416"	"white"	"Sicilian Defense: Nyezhmetdinov-Rossolimo Attack"	2
"ozguragarr"	"white"	"Center Game #2"	6
"ozguragarr"	"white"	"Danish Gambit"	2
"ozguragarr"	"white"	"Danish Gambit Accepted"	4
"ozguragarr"	"white"	"Danish Gambit Accepted |  Copenhagen Defense"	2
"ozguragarr"	"white"	"King's Pawn Game: Beyer Gambit"	2
"ssf7"	"white"	"Horwitz Defense"	3
"ssf7"	"white"	"Modern Defense"	3
"ssf7"	"white"	"Queen's Pawn"	4
"ssf7"	"white"	"Queen's Pawn Game: Chigorin Variation"	4
"ssf7"	"white"	"Queen's Pawn Game: Colle System"	2
"ssf7"	"white"	"Queen's Pawn Game: Symmetrical Variation"	3
"ssf7"	"white"	"Queen's Pawn Game: Zukertort Variation" 5*/

/*which time control had the most wins?*/

SELECT result, increment_code, COUNT(*)
FROM chess
GROUP BY increment_code,result
HAVING COUNT(*)>1
ORDER BY 3 desc

/*"white"	"10+0"	3521
"black"	"10+0"	3239
"white"	"15+0"	595
"black"	"15+0"	568*/


/*With this my project have came to end. Analyzing this dataset really answered some of my question and helped me find certain patterns. I know which openings were played, whch rare varaions players opt for. Which time control is good for practise. which common moves were played and which ones I should prepare against.
Overall It was really fun as I got to practice my sql but also be better prepared as a chess player.















