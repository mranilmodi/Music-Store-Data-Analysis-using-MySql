
#                              Music Store Analysis
 use music;
 
select * from album2;
 
select * from artist;
  
select * from customer;
   
select * from employee;

select * from genre;
 
select * from invoice;

select * from invoice_line;

select * from media_type;

select * from playlist;

select * from playlist_track;

select * from track;

                                # Easy Explain -
                                
# Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name , levels
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS count, billing_country 
FROM invoice
GROUP BY 2
ORDER BY 1 DESC
limit 5;


/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by 1 desc
limit 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
        Write a query that returns one city that has the highest sum of invoice totals. 
        Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
   Write a query that returns the person who has spent the most money.*/


SELECT  first_name, last_name, round(SUM(total),2) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;

                             # Median explain-

/* Q1 * Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
       Return your list ordered alphabetically by email starting with A. ? */
       
select first_name, last_name, email, genre.name from 
customer
join invoice on  customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like '%Rock'
order by 3;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
       Write a query that returns the Artist name and total track count of the top 10 rock bands. ?*/ 

select   artist.name, count(track.track_id) as number_od_song ,genre.name
from artist 
join album2 on artist.artist_id = album2.artist_id
join track on track.album_id = album2.album_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock%'
group by 1,3
order by  2 desc;


/* Q3: Return all the track names that have a song length longer than the average song length. 
   Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.? */
   
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by 2;


                                 # Fully explain / Advance  Question
                                 
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name,
 artist name and total spent ?*/
 
select customer.first_name, customer.last_name, artist.name as artist_name,
sum(invoice_line.unit_price* invoice_line.quantity)  as total_spent
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album2 on track.album_id = album2.album_id
join artist on album2.artist_id = artist.artist_id
group by 1,2,3
order by 4 desc
limit 10;

 

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

with temp as (
select customer.country as country, genre.name as genres,  count(invoice_line.quantity) as  purchase,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
from genre
join track on genre.genre_id = track.genre_id
join invoice_line on  track.track_id = invoice_line.track_id
join invoice on invoice_line.invoice_id = invoice.invoice_id
join customer on invoice.customer_id = customer.customer_id
group by 1,2
order by 1 asc, 3 desc) 
select * from temp where RowNo =1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

with temp as (
select customer.first_name, customer.last_name, invoice.billing_country,
sum(invoice.total) as total_spent,
row_number() over(partition by invoice.billing_country order by sum(invoice.total)) as rowno
from customer
join invoice on customer.customer_id = invoice.customer_id
group by 1,2,3)
select * from temp 
where rowno =1
order by 4 desc;












    