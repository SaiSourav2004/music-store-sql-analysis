-- create a database
create database Music_Store;

-- use this database
use Music_Store;

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);
-- view of table genre
select * from genre;

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);
-- view of table MediaType
select * from MediaType;

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);
-- view of table Employee
select * from employee;

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);
-- view of table customer
select * from customer;

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);
-- view of table Artist
select * from Artist;

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);
-- view of table Album
select * from Album;


-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);
-- view of table Track
select * from Track;

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
-- view of table invoice 
select * from invoice;

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);
-- view of table invoiceline
select * from invoiceline;

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);
-- view of table playlist
select * from playlist;

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);
select * from playlistTrack;




-- 1. Who is the senior most employee based on job title? 
select first_name,last_name,title,hire_date
from employee
order by hire_date
limit 1;

-- 2. Which countries have the most Invoices?
select billing_country,count(billing_country) as total_bill 
from invoice
group by billing_country
order by total_bill desc 
limit 5;


-- 3. What are the top 3 values of total invoice?
select invoice_id,
       billing_country,
       total
from invoice
order by total desc
limit 3;

-- 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. 
	-- Write a query that returns one city that has the highest sum of invoice totals.
	-- Return both the city name & sum of all invoice totals
    
select billing_city,sum(total) as total_sum
from invoice
group by billing_city
order by total_sum desc limit 1
;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer. 
	-- Write a query that returns the person who has spent the most money
select first_name,last_name,sum(total) as total_spent
from customer as c
join invoice as inv
on c.customer_id = inv.customer_id
group by first_name,last_name
order by total_spent desc 
limit 1;

-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

select distinct email,first_name,last_name ,g.name
from customer c
join invoice i 
on c.customer_id = i.customer_id
join invoiceline inL
on i.invoice_id = inL.invoice_id
join track as t
on t.track_id = inL.track_id
join genre as g
on g.genre_id = t.genre_id
where g.name = "Rock" 
order by c.email ;


-- 7. Let's invite the artists who have written the most rock music in our dataset. 
	-- Write a query that returns the Artist name and total track count of the top 10 rock bands 
    
select art.name,count(track_id) as total_track
from artist as art
join album as al
on art.artist_id = al.artist_id
join track as t
on al.album_id = t.album_id
join genre as g
on g.genre_id = t.genre_id
where g.name = "Rock"
group by art.name
order by total_track desc
limit 10 ;

-- 8. Return all the track names that have a song length longer than the average song length.- Return the Name and Milliseconds for each track.
	-- Order by the song length, with the longest songs listed first
    
select name,milliseconds 
from track
where milliseconds > (
		select avg(milliseconds) 
		from track
        )
order by milliseconds desc
;

-- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 

select c.first_name , c.last_name , a.name,
	sum(ino.unit_price * ino.quantity) as total_spent
from customer c join invoice i on c.customer_id=i.customer_id 
join invoiceline ino on i.invoice_id=ino.invoice_id 
join track t on ino.track_id=t.track_id
join album al on al.album_id = t.album_id
join artist a on al.artist_id=a.artist_id
group by   c.customer_id, c.first_name, 
		   c.last_name, a.artist_id, a.name 
order by total_spent desc ;

	-- 10. We want to find out the most popular music Genre for each country. 
		-- We determine the most popular genre as the genre with the highest amount of purchases.
		-- Write a query that returns each country along with the top Genre. 
		-- For countries where the maximum number of purchases is shared, return all Genres
        
WITH genre_purchases AS (
SELECT 
	c.country, g.name AS genre,
	SUM(il.quantity) AS total_purchases,
	RANK() OVER (
		PARTITION BY c.country 
		ORDER BY SUM(il.quantity) DESC
	) AS rank_genre
FROM customer as c
JOIN invoice as i 
	ON c.customer_id = i.customer_id
JOIN invoiceline as il 
	ON i.invoice_id = il.invoice_id
JOIN track as t 
	ON il.track_id = t.track_id
JOIN genre as g 
	ON t.genre_id = g.genre_id
GROUP BY c.country, g.name
)
SELECT 
    country,genre,total_purchases
FROM genre_purchases
WHERE rank_genre = 1
ORDER BY country ;
        

    
-- 11. Write a query that determines the customer that has spent the most on music for each country. 
	-- Write a query that returns the country along with the top customer and how much they spent. 
	-- For countries where the top amount spent is shared, provide all customers who spent this amount
    
with customer_spending as (
select 
	i.billing_country as country,
	c.first_name,
	c.last_name,
	sum(i.total) as total_spent,
	rank() over(
		partition by i.billing_country
		order by sum(i.total) desc
	) as rnk
from customer c
join invoice i
	on c.customer_id = i.customer_id
group by i.billing_country, c.customer_id,
             c.first_name, c.last_name
)
select country, first_name,
       last_name, total_spent
from customer_spending
where rnk = 1
order by country;
   
   
   
   
   
   
   
   
   
   
   
    
