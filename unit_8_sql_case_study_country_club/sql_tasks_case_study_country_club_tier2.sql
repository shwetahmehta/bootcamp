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

<< -- 2/3/2025
Above URL/ Login Credentials did not work. As per Frank Fletcher's recommendation used the following: 
URL: https://frankfletcher.co/springboard_phpmyadmin/index.php
Username: admin_springboard
Password: springboardbackup
-- >>

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

SELECT 
    name AS name_of_facilities_w_memberfees
FROM 
    country_club.Facilities
WHERE 
    membercost > 0
ORDER BY 
    name ASC;


/* Q2: How many facilities do not charge a fee to members? */

SELECT 
    COUNT(*) AS cnt_of_free_facilities
FROM 
    country_club.Facilities
WHERE 
    membercost = 0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
    facid as facility_id, 
    name as facility_name, 
    membercost as member_cost,
    monthlymaintenance as monthly_maintenance
FROM 
    country_club.Facilities
WHERE 
    membercost > 0                                      -- Facilities which charge member fees
    AND (membercost/ monthlymaintenance * 1.0) < 0.2    -- Facilities where member fees are less than 205 of monthly maintenance
;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT 
    *
FROM 
    country_club.Facilities
WHERE 
    facid IN (1, 5)
;


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT 
    name AS facility_name, 
    monthlymaintenance AS monthly_maintenance,
    CASE
        WHEN monthlymaintenance > 100 THEN 'expensive'
        ELSE 'cheap'
    END AS monthly_maintenance_category
FROM 
    country_club.Facilities
ORDER BY 
    monthly_maintenance DESC, 
    facility_name ASC
;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT 
	firstname AS first_name, 
    surname AS last_name
FROM country_club.Members
WHERE 
    -- Get the row with the latest joindate
	joindate = (SELECT 
                	MAX(joindate) 
                FROM country_club.Members)
;


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT
    CONCAT_WS( ' ', Members.firstname, Members.surname) AS member_name
    Facilities.name	AS facility_name
    
FROM country_club.Bookings
	INNER JOIN country_club.Facilities ON Facilities.facid = Bookings.facid
    INNER JOIN country_club.Members ON Members.memid = Bookings.memid
    
WHERE 
	Facilities.name LIKE 'Tennis Court%'
    
ORDER BY
	1, 2
;

Note: Tried to use CONCAT(Members.firstname, ' ', Members.surname) which should have worked but 
kept getting an error.

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT
	Facilities.name AS facility_name,
    CASE
    	WHEN Members.memid = 0 THEN Members.firstname
        ELSE CONCAT_WS(' ', Members.firstname, Members.surname)
    END AS member_name,
    (CASE Members.memid
    	 WHEN 0 THEN Facilities.guestcost
         ELSE Facilities.membercost
    END) * Bookings.slots	AS total_cost
   
FROM country_club.Bookings
	INNER JOIN country_club.Facilities ON Facilities.facid = Bookings.facid
    INNER JOIN country_club.Members ON Members.memid = Bookings.memid
    
WHERE
	-- List of bookings on 2012-09-14
	(Bookings.starttime BETWEEN '2012-09-14' AND '2012-09-15')
    
    -- Cost of booking * slots is more than $30 for either the member or guest
    AND
        (CASE Members.memid
            WHEN 0 THEN Facilities.guestcost
            ELSE Facilities.membercost
        END) * Bookings.slots	> 30
        
ORDER BY 3 DESC
;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
	subquery_total_cost.facility_name,
    subquery_total_cost.member_name,
    subquery_total_cost.total_cost

FROM 
	(
        SELECT
            Facilities.name AS facility_name,
            CASE
                WHEN Members.memid = 0 THEN Members.firstname
                ELSE CONCAT_WS(' ', Members.firstname, Members.surname)
            END AS member_name,
            (CASE Members.memid
                 WHEN 0 THEN Facilities.guestcost
                 ELSE Facilities.membercost
            END) * Bookings.slots	AS total_cost

        FROM Bookings
            INNER JOIN Facilities ON Facilities.facid = Bookings.facid
            INNER JOIN Members ON Members.memid = Bookings.memid

        WHERE
            -- List of bookings on 2012-09-14
            (Bookings.starttime BETWEEN '2012-09-14' AND '2012-09-15')
	) AS subquery_total_cost
    
WHERE 
    -- Cost of booking * slots is more than $30 for either the member or guest
    subquery_total_cost.total_cost > 30
        
ORDER BY 
    3 DESC
;


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

First I had to create a user defined function, before I could answer questions.

# Create a function to run user specified queries on the database
def _execute_query(query, DB_NAME=SQLITE_DB_NAME):
    
    # Connect to the database
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    # Execute the query and load the results into a Pandas DataFrame
    df = pd.read_sql_query(query, conn)
    
    # Print the DataFrame
    # print(df)
    
    conn.close()

    return df

QUESTIONS:

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

query_10_solution_i = """
  SELECT
      f.name AS facility_name,
      SUM((CASE 
          WHEN m.firstname = 'GUEST' THEN f.guestcost
          ELSE f.membercost
          END) * b.slots) AS facility_revenue

  FROM Bookings b
      INNER JOIN Facilities f
          ON b.facid = f.facid
      INNER JOIN Members m
          ON m.memid = b.memid

  GROUP BY 
      f.name

  HAVING 
      facility_revenue < 1000

  ORDER BY
      2 DESC,
      1 ASC
  ;
  """
_execute_query(query_10_solution_i)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

query_11 = """
  SELECT
    m1.surname || ' ' || m1.firstname AS member_name,
    m2.surname || ' ' || m2.firstname AS recommender_name
  
  FROM Members m1
    LEFT JOIN Members m2 ON m1.recommendedby = m2.memid
    
  WHERE
    m1.firstname <> 'GUEST'
  
  ORDER BY 1, 2
  ; """

_execute_query(query_11)



/* Q12: Find the facilities with their usage by member, but not guests */

query_12 = """
  SELECT
      f.name AS facility_name,
      SUM(b.slots) AS facility_usage_in_slots,
      SUM(b.slots) * 0.5 AS facility_usage_in_hours

  FROM Bookings b
      INNER JOIN Facilities f
          ON b.facid = f.facid

  WHERE
    b.memid <> (SELECT memid FROM Members WHERE firstname = 'GUEST')

  GROUP BY 
      f.name

  ORDER BY
      2 DESC,
      1 ASC
  ;
  """

_execute_query(query_12)



/* Q13: Find the facilities usage by month, but not guests */

query_13 = """
  SELECT
    strftime('%Y-%m', b.starttime) AS year_month,
    SUM(b.slots) AS facility_usage_in_slots,
    SUM(b.slots) * 0.5 AS facility_usage_in_hours

  FROM Bookings b

  WHERE
    b.memid <> (SELECT memid FROM Members WHERE firstname = 'GUEST')

  GROUP BY 
      1

  ORDER BY
      1 ASC
  ;
"""

_execute_query(query_13)

