/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

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

SELECT name FROM Facilities 
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

4
SELECT count(*) FROM Facilities 
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance FROM Facilities 
WHERE membercost > 0 AND membercost < (0.2 * monthlymaintenance);

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities 
WHERE facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance FROM Facilities 
WHERE expense_label = 'Expensive';

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname FROM Members 
WHERE joindate = (SELECT MAX(joindate) FROM Members);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT fac.name AS facilityname, mem.memid, CONCAT(mem.firstname, " ", mem.surname) membername FROM `Members` AS mem
INNER JOIN Bookings AS bkg ON bkg.memid = mem.memid
INNER JOIN Facilities AS fac ON bkg.facid - fac.facid
WHERE fac.facid IN (0, 1)
ORDER BY membername ASC;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT fac.name AS facilityname, CONCAT(mem.firstname, " ", mem.surname) membername, SUM(fac.membercost) totalcost 
FROM Members AS mem 
INNER JOIN Bookings AS bkg ON bkg.memid = mem.memid 
INNER JOIN Facilities AS fac ON bkg.facid = fac.facid 
WHERE bkg.starttime > '2012-09-14' AND bkg.starttime < '2012-09-15' AND mem.memid != 0 
GROUP BY mem.memid, mem.firstname, mem.surname, fac.facid, fac.name 
HAVING totalcost > 30
UNION
SELECT fac.name AS facilityname, CONCAT(mem.firstname, " ", mem.surname) membername, SUM(fac.guestcost) totalcost 
FROM Members AS mem 
INNER JOIN Bookings AS bkg ON bkg.memid = mem.memid 
INNER JOIN Facilities AS fac ON bkg.facid = fac.facid 
WHERE bkg.starttime > '2012-09-14' AND bkg.starttime < '2012-09-15' AND mem.memid = 0 
GROUP BY mem.memid, mem.firstname, mem.surname, fac.facid, fac.name 
HAVING totalcost > 30
ORDER BY totalcost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select bkgfac.name AS facilityname, CONCAT(mem.firstname, " ", mem.surname) membername, SUM(bkgfac.faccost) totalcost
from Members AS mem
INNER JOIN (
    select bkg.memid, fac.facid, fac.name, 
        case when bkg.memid = 0 then fac.guestcost else fac.membercost end faccost
    from Bookings as bkg
    inner join Facilities as fac on fac.facid = bkg.facid
    WHERE bkg.starttime > '2012-09-14' AND bkg.starttime < '2012-09-15'
) AS bkgfac ON bkgfac.memid = mem.memid
GROUP BY mem.memid, mem.firstname, mem.surname, bkgfac.facid, bkgfac.name 
HAVING totalcost > 30
ORDER BY totalcost DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

Jupyter Notebook Link - https://github.com/nileshsuresh/SQLFiles-Tier-2/blob/main/SQLLite_CaseStudy.ipynb

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select bkgfac.name AS facility_name, SUM(bkgfac.faccost) total_revenue
    from Members AS mem
    INNER JOIN (
    select bkg.memid, fac.facid, fac.name, 
        case when bkg.memid = 0 then fac.guestcost else fac.membercost end faccost
    from Bookings as bkg
    inner join Facilities as fac on fac.facid = bkg.facid
    ) AS bkgfac ON bkgfac.memid = mem.memid
    GROUP BY bkgfac.facid, bkgfac.name 
    HAVING total_revenue < 1000
    ORDER BY total_revenue

     facility_name  total_revenue
0     Table Tennis           90.0
1    Snooker Table          115.0
2       Pool Table          265.0
3  Badminton Court          604.5

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

select CONCAT(mem.firstname, ' ', mem.surname) member_name, CONCAT(rec.firstname, ' ', rec.surname) recommended_by 
from Members mem
INNER JOIN Members rec ON rec.memid = mem.recommendedby
where mem.recommendedby is not null and mem.recommendedby != ''
order by mem.surname, mem.firstname    

                member_name     recommended_by
0            Florence Bader    Ponder Stibbons
1                Anne Baker    Ponder Stibbons
2             Timothy Baker     Jemima Farrell
3                Tim Boothe         Tim Rownam
4            Gerald Butters       Darren Smith
5               Joan Coplin      Timothy Baker
6             Erica Crumpet        Tracy Smith
7                Nancy Dare    Janice Joplette
8           Matthew Genting     Gerald Butters
9                 John Hunt  Millicent Purview
10              David Jones    Janice Joplette
11            Douglas Jones        David Jones
12          Janice Joplette       Darren Smith
13           Anna Mackenzie       Darren Smith
14             Charles Owen       Darren Smith
15             David Pinker     Jemima Farrell
16        Millicent Purview        Tracy Smith
17         Henrietta Rumney    Matthew Genting
18         Ramnaresh Sarwin     Florence Bader
19               Jack Smith       Darren Smith
20          Ponder Stibbons       Burton Tracy
21  Henry Worthington-Smyth        Tracy Smith

/* Q12: Find the facilities with their usage by member, but not guests */

select fac.name as facitlity_name, count(*) as usage_count from Bookings bkg
inner join Facilities fac ON fac.facid = bkg.facid
where bkg.memid != 0
group by fac.name 
order by usage_count desc 

    facitlity_name  usage_count
0       Pool Table          783
1    Snooker Table          421
2   Massage Room 1          421
3     Table Tennis          385
4  Badminton Court          344
5   Tennis Court 1          308
6   Tennis Court 2          276
7     Squash Court          195
8   Massage Room 2           27

/* Q13: Find the facilities usage by month, but not guests */

select fac.name as facitlity_name, strftime("%m", bkg.starttime) month, count(*) usage_count from Bookings bkg
inner join Facilities fac ON fac.facid = bkg.facid
where bkg.memid != 0
group by fac.name,  strftime("%m", bkg.starttime)
order by facitlity_name, bkg.starttime 

     facitlity_name month  usage_count
0   Badminton Court    07           51
1   Badminton Court    08          132
2   Badminton Court    09          161
3    Massage Room 1    07           77
4    Massage Room 1    08          153
5    Massage Room 1    09          191
6    Massage Room 2    07            4
7    Massage Room 2    08            9
8    Massage Room 2    09           14
9        Pool Table    07          103
10       Pool Table    08          272
11       Pool Table    09          408
12    Snooker Table    07           68
13    Snooker Table    08          154
14    Snooker Table    09          199
15     Squash Court    07           23
16     Squash Court    08           85
17     Squash Court    09           87
18     Table Tennis    07           48
19     Table Tennis    08          143
20     Table Tennis    09          194
21   Tennis Court 1    07           65
22   Tennis Court 1    08          111
23   Tennis Court 1    09          132
24   Tennis Court 2    07           41
25   Tennis Court 2    08          109
26   Tennis Court 2    09          126