-- First we can start by looking at all the tables.
-- There is a table that give us data on 
-- Ranking, Teams, Players, Games and Game Details


select *
From ranking;
-- Ranking has 13 columns and 201,792 rows

select *
From teams;
-- Teams has 14 columns and 30 rows


select *
From players;
-- Players has 4 columns and 7,228 rows


select *
From games;
-- Games has 21 columns and 25,796 rows



select *
From games_details;
-- Games Details has 29 columns and 645,953  rows


-- First lets look at the teams data base
-- Since there are only 30 rows of data we can easily look at specific aspects
-- and see if theres any cleaning that needs to be done


-- Lets see which team is the oldest in the NBA and which team is the youngest
select MIN(YEARFOUNDED) as Earliest_Team
From teams;
-- Earliest Team started in 1946

select MAX(YEARFOUNDED) as Latest_Team
From teams;
--Lastest Team started in 2002

--So lets look at the City and team name of these teams

select CITY, NICKNAME as Team_Name, YEARFOUNDED
FROM teams
Where YEARFOUNDED = 1946
Order By CITY;


select CITY, NICKNAME as Team_Name, YEARFOUNDED
FROM teams
Where YEARFOUNDED = 2002;


-- Next Tast That I will look at is which team has the highest and lowest Arena Capacity 

select MIN(ARENACAPACITY) as Lowest_Capacity
From teams;
-- looks like we need to do some cleaning to replace the NULL and the 0.
-- I had to Look up the information for each missing stadium capacity.

select ARENACAPACITY, CITY, ARENA
From teams
Where ARENACAPACITY is null;

Update teams
set ARENACAPACITY = 17791
where ARENA = 'Smoothie King Center';

Update teams
set ARENACAPACITY = 17732
where ARENA = 'Barclays Center';

Update teams
set ARENACAPACITY = 19500
where ARENA = 'Wells Fargo Center';

Update teams
set ARENACAPACITY = 18422
where ARENA = 'Talking Stick Resort Arena';

Update teams
set ARENACAPACITY = 20000
where ARENA = 'Amway Center';

-- Okay know what is the lowest and Highest capacity?

select MIN(ARENACAPACITY) as Lowest_Capacity
From teams;

select MAX(ARENACAPACITY) as Highest_Capacity
From teams;


select CITY, NICKNAME as Team_Name, ARENACAPACITY
FROM teams
Where ARENACAPACITY = 17500;
-- Milwaukee Bucks and Sacramento Kings have the lowest Stadium capacity

select CITY, NICKNAME as Team_Name, ARENACAPACITY
FROM teams
Where ARENACAPACITY = 21711;
-- Chicago Bulls Have the highest Capacity

-- Lastly Lets look at all of the Arena Capacity for all teams

select ARENACAPACITY, CITY, NICKNAME as Team_Name, ARENA
From teams
Order by ARENACAPACITY;

-- Now lets look into the players table


select *
From players;

-- As we can see there are will be many players that are playing for multiple seasons.
-- To determine the true number of players that are in the data we need to get look at the data
--  without the duplicated values

select distinct PLAYER_NAME as Name, PLAYER_ID
From players;

-- Turns out there are 1,769 different atheletes in this table
-- We can move on to the next table. However, we can later join other tables
-- to this one so that we can have a better understanding of specific traits 
-- for specefic players.



select * 
From ranking;

-- the RETURNTOPLAY column in ranking is mainly NULL so we can just drop the column
Alter table ranking
Drop column RETURNTOPLAY;


-- Now lets see the highest win percentages that have been in the league since 2003
-- Every NBA season has a total of 82 games. This is why the where clause is G=82

select W_PCT as Winning_Percentage, TEAM, SEASON_ID
From ranking
Where G = 82
group by W_PCT, TEAM,SEASON_ID
Order by Winning_Percentage desc;

-- Next lets look into the games table

select *
From games;

-- lets get rid of the rows that have null for Game_ID.
-- These same rows normally have null in the PTS_home and PTS_away columns
-- So I think its best to just get rid of it.
-- First lets see how many rows will be taken away

select * 
From games
where GAME_ID IS NOT NULL;

-- Only 2096 rows that do not have Game_id as null. 
-- Although it is a large marjority of the table missing.
-- I think it is best to still take away the rows so that we can join
-- This table to the games_detail table. It also makes the datebase a lot cleaner.

Delete from games
Where GAME_ID IS NULL;

-- Also gonna drop HOME_TEAM_ID and VISITOR_TEAM_ID because the columns 
-- TEAM_ID_HOME and TEAM_ID_AWAY exist. Therefore, no need for extra columns.
-- In addition, I will drop the game_status_text because theyre all final and seem
-- pretty useless.

Alter Table games
Drop column HOME_TEAM_ID, VISITOR_TEAM_ID,GAME_STATUS_TEXT;


-- Let see who wins more Home teams or Away teams?

Select COUNT(HOME_TEAM_WINS) as Home_Winner
From games
group by HOME_TEAM_WINS;

-- As we can see the away team won 900 times 
-- The home team won 1196 times. Thus, the home team must have an advantage

-- Next I want to make the percentages to be cleaner by chaning the data type 
-- and multiplying it by 100 so that the numbers arent in decimanl form anymore.


Update games
set FG_PCT_home=(FG_PCT_home)*100;

Update games
set FG_PCT_away=(FG_PCT_away)*100;

Update games
set FT_PCT_home=(FT_PCT_home)*100;

Update games
set FT_PCT_away=(FT_PCT_away)*100;

Update games
set FG3_PCT_home=(FG3_PCT_home)*100;

Update games
set FG3_PCT_away=(FG3_PCT_away)*100;

Alter Table games
Alter column FG_PCT_home int;

Alter Table games
Alter column FT_PCT_home int;

Alter Table games
Alter column FG3_PCT_home int;

Alter Table games
Alter column FG_PCT_away int;

Alter Table games
Alter column FT_PCT_away int;

Alter Table games
Alter column FG3_PCT_away int;

-- lastly lets fix up the games_details 
-- There are a total of 645953 rows in this table
-- So lets try to clean the data.

select * 
From games_details

-- We can first get rid of any row that Has DNP
-- Or DND because these rows will not have any 
-- Meaningful data.



-- First we want to look at the comments specificlly to see
-- Which comments are saying the players didnt play
select distinct COMMENT
From games_details

Delete from games_details
Where COMMENT LIKE 'D%';


Delete from games_details
Where COMMENT LIKE 'N%';

Delete from games_details
Where COMMENT LIKE 'I%';

Delete from games_details
Where COMMENT LIKE 'O%';

Delete from games_details
Where COMMENT LIKE 'M%';

Delete from games_details
Where COMMENT LIKE 'W%';

-- now that we have removed the rows that have people who have not played
-- We can drop the entire Comments columns since the only value in there is null

Alter table games_details
Drop Column COMMENT;

--Next we can change the percentages into whole numbers just so it looks cleaner

Update games_details
Set FG_PCT = FG_PCT*100

Update games_details
Set FG3_PCT = FG3_PCT*100

Update games_details
Set FT_PCT = FT_PCT*100

Alter Table games_details
Alter column FG_PCT int;

Alter Table games_details
Alter column FG3_PCT int;

Alter Table games_details
Alter column FT_PCT int;

-- Lets take a look at some of the star players in the data set
-- We can look at multiple different Stats to determine this.
-- Lets see players/games where someone scored more than 20 pts in 2021

select GAME_ID, PLAYER_ID as ID, PLAYER_NAME as Name, FG_PCT, FG3_PCT, FT_PCT, PTS
From games_details
Where PTS >= 20 AND GAME_ID IS NOT NULL ;

select games_details.PLAYER_ID as ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season, TEAM_ID
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 20 and SEASON =2021
Order by games.season;


-- To see top teir players lets look at who scored 35 points in 2021

select games_details.PLAYER_ID as ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 35 and SEASON =2021
Order by games.season;

-- Meh the season is long and there are 238 times that a player scored 35 or more
-- So lets get to the Elite players with 45 and up for 2021

select games_details.PLAYER_ID as ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 45 and SEASON =2021
Order by games.season;

-- Finally in our Query Id like to look at specific teams and how their athletes performed.
-- Lets look at the Detroit Pistons and see whos scored 30+ points in the 2021 season

select games_details.PLAYER_ID as Player_ID,TEAM_ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season as Season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 30 and SEASON =2021
group by games_details.PLAYER_ID , games_details.PLAYER_NAME,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season, TEAM_ID
Having TEAM_ID = 1610612765
Order by games.season;

-- Now lets do the same with the Los Angeles Lakers, Boston Celtics, Brooklyn Nets, Milwauke Bucks and the Miami Heat

-- Lakers
select games_details.PLAYER_ID as Player_ID,TEAM_ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season as Season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 30 and SEASON =2021
group by games_details.PLAYER_ID , games_details.PLAYER_NAME,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season, TEAM_ID
Having TEAM_ID = 1610612747
Order by games_details.PTS desc;


-- Celtics
select games_details.PLAYER_ID as Player_ID,TEAM_ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season as Season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 30 and SEASON =2021
group by games_details.PLAYER_ID , games_details.PLAYER_NAME,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season, TEAM_ID
Having TEAM_ID = 1610612738
Order by games_details.PTS desc;


-- Nets
select games_details.PLAYER_ID as Player_ID,TEAM_ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season as Season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 30 and SEASON =2021
group by games_details.PLAYER_ID , games_details.PLAYER_NAME,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season, TEAM_ID
Having TEAM_ID = 1610612751
Order by games_details.PTS desc;


-- Bucks
select games_details.PLAYER_ID as Player_ID,TEAM_ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season as Season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 30 and SEASON =2021
group by games_details.PLAYER_ID , games_details.PLAYER_NAME,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season, TEAM_ID
Having TEAM_ID = 1610612749
Order by games_details.PTS desc;


-- Heat
select games_details.PLAYER_ID as Player_ID,TEAM_ID, games_details.PLAYER_NAME as Name,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season as Season
From games_details
left join games on games_details.GAME_ID=games.GAME_ID
Where PTS>= 30 and SEASON =2021
group by games_details.PLAYER_ID , games_details.PLAYER_NAME,games_details.FG_PCT, games_details.FG3_PCT, games_details.FT_PCT, games_details.PTS, games.season, TEAM_ID
Having TEAM_ID = 1610612748
Order by games_details.PTS desc;


-- The last thing I want to do is input the salaries of the star player of these teams and compare them
-- To each other to see if some players need to be cut based on their Salary and if some players

Alter Table players
Add Salary VarChar(255);

select * 
from players
Where Salary is not null;

-- Lets insert the players and their Salaries to the Players table

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('James Harden', 1610612745, 201935, 2021, 41254920)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Jerami Grant', 1610612743, 203924, 2021, 20002500)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Saddiq Bey', 1610612765, 1630180, 2021, 2824320)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Cade Cunningham', 1610612765, 1630595, 2021, 10050120)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('LeBron James', 1610612747, 2544, 2021, 41180544)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Russell Westbrook', 1610612747, 201566, 2021, 44211146)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Anthony Davis', 1610612747, 203076, 2021, 35361360)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Jaylen Brown', 1610612738, 1627759, 2021, 26758928)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Jayson Tatum', 1610612738, 1628369, 2021, 28103500)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Kevin Durant', 1610612751, 201142, 2021, 42018900)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Kyrie Irving', 1610612751, 202681, 2021, 35328700)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Jrue Holiday', 1610612749, 201950, 2021, 32431333)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Giannis Antetokounmpo', 1610612749, 203507, 2021, 39344900)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Khris Middleton', 1610612749, 203114, 2021, 35500000)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Jimmy Butler', 1610612748, 202710, 2021, 36016200)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Bam Adebayo', 1610612748, 1628389, 2021, 28103500)

Insert into players(PLAYER_NAME, TEAM_ID, PLAYER_ID, SEASON, Salary)
Values('Tyler Herro', 1610612748, 1629639, 2021, 4004280)

-- Who has the highest salary in order

select PLAYER_NAME, Salary
From players
where Salary is not null
order by Salary desc

-- Lets take a look at all the players Who scored 30+ points over their career with a salary.
-- This way we can count the amount of times a player has scored over 30 and compare the salary

select COUNT(gd.PLAYER_ID) as Times_Score_30, gd.PLAYER_NAME as Name, p.Salary as SALARY
From games_details as gd
left join players as p on gd.PLAYER_ID=p.PLAYER_ID
Where PTS>= 30 and SEASON = 2021
group by gd.PLAYER_ID , gd.PLAYER_NAME, p.Salary
Order by Times_Score_30 desc;


-- Obviously some players have played far longer than others. Therefore, the amount of times they 
-- score 30+ will be much larger than a player who has just joined the league. So lets see
-- The same results but only for the year 2021.


select COUNT(PLAYER_NAME),gd.PLAYER_NAME, g.SEASON
From games_details as gd
inner Join games as g on gd.GAME_ID=g.GAME_ID
Where PTS>= 30 and SEASON =2021 
group by gd.PLAYER_NAME, g.SEASON;

-- The counts are as following Anthony Davis(10), Bam Adebayo(5), Cade Cunningham(1), Giannis Antetokounmpo(28),
-- James Harden(9), Jaylen Brown(12), Jayson Tatum(23), Jerami Grant(4), Jimmy Butler(7), Jrue Holiday(1)
-- Kevin Durant(17), Khris Middleton(3), Kyrie Irving(6), LeBron James(28), Russell Westbrook(5), Saddiq Bey(4),Tyler Herro(7)

-- Conclussion!

-- From this I would say that Jason Tatum deserves a raise in pay. He is Keeping up with the highest scoring players in the league
-- However, his pay hardly over 50 percent of the other top players. Although Tyler Herro is newer to the NBA he has more 30+ games 
-- Than ppl like Kyrie, Khris, Russell and Bam. So he also needs a Pay raise. Russel is the highest paid and is one of the lowest performing
-- He needs a decrease in Pay or a trade. All other players that I choose from seem to be in a good pay range for the talents that they bring to
-- their teams. As time goes on I think that I will add more salary information to the data that I have. For example, Stephen Curry is one of the 
-- Highet paid players however, I do not have has salary nor his teams salary included(yet). I would like to add every players salary but more than 
-- likely I would just need to import another dataset from somebody that has already gotten that information in a dataset.