/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT *
FROM `Facilities`
WHERE `membercost` >0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( * )
FROM `Facilities`
WHERE `membercost` =0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT `facid` , `name` , `membercost` , `monthlymaintenance`
FROM `Facilities`
WHERE `membercost` > 0.0
AND `membercost` < .20 * `monthlymaintenance`;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 );


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, `monthlymaintenance` ,
CASE
WHEN `monthlymaintenance` >=100
THEN 'expensive'
ELSE 'cheap'
END AS cost
FROM `Facilities`;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT `firstname` , `surname`
FROM `Members`
WHERE `joindate` = (
SELECT MAX( `joindate` )
FROM `Members` );


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT firstname, surname, f.name
FROM `Members` AS m
LEFT JOIN `Bookings` AS b ON m.memid = b.memid
LEFT JOIN `Facilities` AS f ON b.facid = f.facid
WHERE f.name LIKE 'Tennis Court%'
ORDER BY firstname, surname;



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT `f`.`name` AS `facility`, CONCAT(`m`.`firstname`,' ',`m`.`surname`) AS `member`,
CASE WHEN `m`.`memid` = 0 THEN `f`.`guestcost`*`b`.`slots` ELSE `f`.`membercost`*`b`.`slots` END AS `cost`
FROM `Facilities` AS `f`
RIGHT JOIN `Bookings`  AS `b` LEFT JOIN `Members` AS `m` 
ON `b`.`memid` = `m`.`memid`
ON `f`.`facid` = `b`.`facid`
WHERE `b`.`starttime` BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59' AND
((`m`.`memid` = 0 AND `f`.`guestcost`*`b`.`slots` > 30.0) OR (`m`.`memid` != 0 AND `f`.`membercost`*`b`.`slots` > 30.0))
ORDER BY `cost` DESC, `b`.`starttime`, `member`;



/* Q9: This time, produce the same result as in Q8, but using a subquery. */


SELECT `f`.`name` AS `facility`, CONCAT(`m`.`firstname`,' ',`m`.`surname`) AS `member`,
CASE WHEN `m`.`memid` = 0 THEN `f`.`guestcost`*`q`.`slots` ELSE `f`.`membercost`*`q`.`slots` END AS `cost`
FROM `Facilities` AS `f`
RIGHT JOIN
(SELECT * FROM `Bookings` WHERE `starttime` BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59') AS `q`
LEFT JOIN `Members` AS `m` ON `q`.`memid` = `m`.`memid`
ON `f`.`facid` = `q`.`facid`
WHERE ((`m`.`memid` = 0 AND `f`.`guestcost`*`q`.`slots` > 30.0) OR (`m`.`memid` != 0 AND `f`.`membercost`*`q`.`slots` > 30.0))
ORDER BY `cost` DESC, `q`.`starttime`, `member`;



/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
q10 = pd.read_sql_query('''
SELECT
sub.paid,
sub.facility_name
FROM
(SELECT 
SUM(CASE WHEN b.memid=0 THEN (f.guestcost*b.slots)
WHEN b.memid>0 THEN (f.membercost*b.slots)
ELSE 0
END ) AS paid,
name AS facility_name
FROM facilities as f
LEFT JOIN bookings as b
ON f.facid=b.facid
GROUP BY f.name
ORDER BY facility_name) AS sub
WHERE sub.paid<1000
ORDER BY sub.paid;''' ,  conn)

   paid       facility
0   180   Table Tennis
1   240  Snooker Table
2   270     Pool Table



/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

q11 = pd.read_sql_query('''
SELECT m.surname AS member_surname,m.firstname AS member_firstname,
q.surname AS referred, q.firstname AS by
FROM Members AS m
LEFT JOIN (SELECT memid,firstname,surname FROM Members) AS q
ON m.recommendedby = q.memid
WHERE q.memid != 0''' , conn)
print(q11)

       member_surname member_firstname  referred         by
0            Joplette           Janice     Smith     Darren
1             Butters           Gerald     Smith     Darren
2                Dare            Nancy  Joplette     Janice
3              Boothe              Tim    Rownam        Tim
4            Stibbons           Ponder     Tracy     Burton
5                Owen          Charles     Smith     Darren
6               Jones            David  Joplette     Janice
7               Baker             Anne  Stibbons     Ponder
8               Smith             Jack     Smith     Darren
9               Bader         Florence  Stibbons     Ponder
10              Baker          Timothy   Farrell     Jemima
11             Pinker            David   Farrell     Jemima
12            Genting          Matthew   Butters     Gerald
13          Mackenzie             Anna     Smith     Darren
14             Coplin             Joan     Baker    Timothy
15             Sarwin        Ramnaresh     Bader   Florence
16              Jones          Douglas     Jones      David
17             Rumney        Henrietta   Genting    Matthew
18  Worthington-Smyth            Henry     Smith      Tracy
19            Purview        Millicent     Smith      Tracy
20               Hunt             John   Purview  Millicent
21            Crumpet            Erica     Smith      Tracy


/* Q12: Find the facilities with their usage by member, but not guests */

q12 = pd.read_sql_query('''
SELECT facility, firstname, surname, usage FROM
(SELECT f.name AS facility, m.memid, m.firstname, m.surname,
SUM(b.slots) AS usage
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON f.facid = b.facid
LEFT JOIN Members AS m
ON b.memid = m.memid
GROUP BY m.memid
ORDER BY usage)
WHERE memid != 0''',  conn)
print(q12)

          facility  firstname            surname  usage
0      Table Tennis     Darren              Smith    685
1    Massage Room 1        Tim             Rownam    660
2    Tennis Court 2        Tim             Boothe    440
3    Tennis Court 1      Tracy              Smith    435
4    Tennis Court 1     Gerald            Butters    409
5    Tennis Court 2     Burton              Tracy    366
6    Tennis Court 1    Charles               Owen    345
7    Massage Room 1     Janice           Joplette    326
8    Tennis Court 2      David              Jones    305
9    Tennis Court 1       Anne              Baker    296
10   Tennis Court 2    Timothy              Baker    290
11  Badminton Court      Nancy               Dare    267
12   Tennis Court 2     Ponder           Stibbons    249
13  Badminton Court   Florence              Bader    237
14  Badminton Court       Anna          Mackenzie    231
15   Massage Room 1       Jack              Smith    219
16     Table Tennis     Jemima            Farrell    180
17    Snooker Table      David             Pinker    159
18   Tennis Court 2  Ramnaresh             Sarwin    153
19   Massage Room 2    Matthew            Genting    131
20    Snooker Table       Joan             Coplin    106
21  Badminton Court      Henry  Worthington-Smyth     60
22   Tennis Court 1      David            Farrell     50
23   Tennis Court 1       John               Hunt     40
24    Snooker Table  Henrietta             Rumney     38
25  Badminton Court    Douglas              Jones     37
26  Badminton Court  Millicent            Purview     32
27    Snooker Table   Hyacinth         Tupperware     28
28  Badminton Court      Erica            Crumpet     17


/* Q13: Find the facilities usage by month, but not guests */
q13 = pd.read_sql_query('''
SELECT f.name AS facility,
SUBSTR(b.starttime,1,7) AS month,
SUM(CASE WHEN b.memid > 0 THEN b.slots ELSE 0 END) AS usage
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON f.facid = b.facid
LEFT JOIN Members as m
ON b.memid = m.memid
GROUP BY f.facid, month
ORDER BY usage DESC''', conn)
print(q13)

           facility    month  usage
0   Badminton Court  2012-09    507
1        Pool Table  2012-09    443
2    Tennis Court 1  2012-09    417
3    Tennis Court 2  2012-09    414
4   Badminton Court  2012-08    414
5     Snooker Table  2012-09    404
6    Massage Room 1  2012-09    402
7      Table Tennis  2012-09    400
8    Tennis Court 2  2012-08    345
9    Tennis Court 1  2012-08    339
10   Massage Room 1  2012-08    316
11    Snooker Table  2012-08    316
12       Pool Table  2012-08    303
13     Table Tennis  2012-08    296
14   Tennis Court 1  2012-07    201
15     Squash Court  2012-08    184
16     Squash Court  2012-09    184
17   Massage Room 1  2012-07    166
18  Badminton Court  2012-07    165
19    Snooker Table  2012-07    140
20   Tennis Court 2  2012-07    123
21       Pool Table  2012-07    110
22     Table Tennis  2012-07     98
23     Squash Court  2012-07     50
24   Massage Room 2  2012-09     28
25   Massage Room 2  2012-08     18
26   Massage Room 2  2012-07      8




