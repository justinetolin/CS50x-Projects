-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Explore the database
-- .schema

-- Check description of crime scene
SELECT description FROM crime_scene_reports WHERE month = 7 AND day = 28 AND street = 'Humphrey Street';
-- 10:15AM; 3 interviews with bakery mentions

-- Check interviews
SELECT name, transcript FROM interviews WHERE month = 7 AND day = 28 AND transcript LIKE '%bakery%';

-- Ruth    | Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.
-- Eugene  | I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
-- Raymond | As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket.


-- 1. Confrim Ruth's story (car in bakery)
SELECT hour, minute, activity, license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28;
-- Exits within time of crime: 5P2B195 94KL13X 6P58WS2 4328GD8 G412CB7 L93JTIZ 322W7JE 0NTHK55 1106N58

-- Get names of people associated with the license plates in bakery logs during 10hr period; returns the name
SELECT name FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28);

-- Same thing as above but uses JOIN to access the time
SELECT name, hour, minute, people.license_plate FROM people JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate WHERE month = 7 AND day = 28;

-- 2. Confirm Eugene's story (ATM withdraw on Leggett Street early morning)
SELECT account_number, amount FROM atm_transactions WHERE month = 7 AND day = 28 AND transaction_type = 'withdraw' AND atm_location = 'Leggett Street';
-- accnt numbs: 28500762 28296815 76054385 49610011 16153065 25506511 81061156 26013199

-- Get the names of people who withdraw
SELECT name, passport_number FROM people WHERE id IN (SELECT person_id FROM bank_accounts WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND atm_location = 'Leggett Street'));

-- Get call for the crime day
SELECT caller, receiver FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60;

-- Get names of the caller that matches the names from the bakery security logs (people who called someone and exit the bakery)
SELECT name FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28 AND hour = 10 AND activity = 'exit') AND phone_number IN (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60);

-- Get the names who also withdraw from above query [FINAL 3 suspects]
SELECT name, phone_number, passport_number FROM people WHERE id IN (SELECT person_id FROM bank_accounts WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND atm_location = 'Leggett Street')) AND license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28) AND phone_number IN (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60);

/*
+--------+----------------+-----------------+
|  name  |  phone_number  | passport_number |
+--------+----------------+-----------------+
| Taylor | (286) 555-6063 | 1988161715      |
| Diana  | (770) 555-1861 | 3592750733      |
| Bruce  | (367) 555-5533 | 5773159633      |
+--------+----------------+-----------------+
*/

-- Get the receiver of the thief's call from the names above
SELECT name, passport_number FROM people WHERE phone_number IN (SELECT receiver FROM phone_calls WHERE caller IN (SELECT phone_number FROM people WHERE id IN (SELECT person_id FROM bank_accounts WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND atm_location = 'Leggett Street')) AND license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28 AND hour = 10 AND activity = 'exit') AND phone_number IN (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60)))




-- FLight things
-- 3. Confirm Raymond's story (Flight out Fiftyville)
SELECT * FROM airports JOIN flights ON airports.id = flights.origin_airport_id WHERE month = 7 AND day = 29 AND city = 'Fiftyville';

-- Get the seats
SELECT seat FROM passengers WHERE flight_id IN (SELECT flights.id FROM airports JOIN flights ON airports.id = flights.origin_airport_id WHERE month = 7 AND day
= 29 AND city = 'Fiftyville');

-- Get the passenger details of the 3 suspects
SELECT * FROM passengers WHERE passport_number IN (SELECT passport_number FROM people WHERE id IN (SELECT person_id FROM bank_accounts WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND atm_location = 'Leggett Street')) AND license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28 AND hour = 10 AND activity = 'exit') AND phone_number IN (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60));

-- Get flight details for a passport num
SELECT * FROM flights WHERE id IN (SELECT flight_id FROM passengers WHERE passport_number = 1988161715);

SELECT * FROM flights WHERE id IN (SELECT flight_id FROM passengers WHERE passport_number = 5773159633);

SELECT * FROM flights WHERE id IN (SELECT flight_id FROM passengers WHERE passport_number = 3592750733);

-- FINDINGS: TWO OF THEM HAVE THE SAME FLIGHT OUT FIFTYVILLE

-- Get the destination airport of two accomplices
 SELECT * FROM airports WHERE id = (SELECT destination_airport_id FROM flights WHERE id IN (SELECT flight_id FROM passengers WHERE passport_number = 1988161715 OR passport_number = 5773159633));


-- Confirm the thief from the two based on the phone number as caller
 SELECT * FROM phone_calls WHERE caller = '(286) 555-6063'; --taylor
-- has a receiver (676) 555-6554 same day

 SELECT * FROM phone_calls WHERE caller = '(770) 555-1861' --diana
-- hhas a receiver (725) 555-3243 same day

 SELECT * FROM phone_calls WHERE caller = '(367) 555-5533'; --bruce







-- -- -- /* RESTART */ -- -- --
-- People in bakery between 15 to 25 mins
SELECT * FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28 AND minute BETWEEN 15 AND 25);
/*
+--------+---------+----------------+-----------------+---------------+
|   id   |  name   |  phone_number  | passport_number | license_plate |
+--------+---------+----------------+-----------------+---------------+
| 210245 | Jordan  | (328) 555-9658 | 7951366683      | HW0488P       |
| 221103 | Vanessa | (725) 555-4692 | 2963008352      | 5P2BI95       |
| 243696 | Barry   | (301) 555-4174 | 7526138472      | 6P58WS2       |
| 325548 | Brandon | (771) 555-6667 | 7874488539      | R3G7486       |
| 396669 | Iman    | (829) 555-5269 | 7049073643      | L93JTIZ       |
| 398010 | Sofia   | (130) 555-0289 | 1695452385      | G412CB7       |
| 467400 | Luca    | (389) 555-5198 | 8496433585      | 4328GD8       |
| 486361 | Wayne   | (056) 555-0309 | NULL            | D965M59       |
| 514354 | Diana   | (770) 555-1861 | 3592750733      | 322W7JE       |
| 542503 | Michael | (529) 555-7276 | 6117294637      | HOD8639       |
| 560886 | Kelsey  | (499) 555-9472 | 8294398571      | 0NTHK55       |
| 565511 | Vincent | NULL           | 3011089587      | 94MV71O       |
| 682850 | Ethan   | (594) 555-6254 | 2996517496      | NAW9653       |
| 686048 | Bruce   | (367) 555-5533 | 5773159633      | 94KL13X       |
| 745650 | Sophia  | (027) 555-1068 | 3642612721      | 13FNH73       |
| 748674 | Jeremy  | (194) 555-5027 | 1207566299      | V47T75I       |
| 750165 | Daniel  | (971) 555-6468 | 7597790505      | FLFN3W0       |
| 768248 | George  | NULL           | 4977790793      | L68E5I0       |
+--------+---------+----------------+-----------------+---------------+
*/

-- People who withdraw in Leggett
 SELECT * FROM people WHERE id IN (SELECT person_id FROM bank_accounts WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND transaction_type = 'withdraw' AND atm_location = 'Leggett Street'));
/*
+--------+---------+----------------+-----------------+---------------+
|   id   |  name   |  phone_number  | passport_number | license_plate |
+--------+---------+----------------+-----------------+---------------+
| 395717 | Kenny   | (826) 555-1652 | 9878712108      | 30G67EN       |
| 396669 | Iman    | (829) 555-5269 | 7049073643      | L93JTIZ       |
| 438727 | Benista | (338) 555-6650 | 9586786673      | 8X428L0       |
| 449774 | Taylor  | (286) 555-6063 | 1988161715      | 1106N58       |
| 458378 | Brooke  | (122) 555-4581 | 4408372428      | QX4YZN3       |
| 467400 | Luca    | (389) 555-5198 | 8496433585      | 4328GD8       |
| 514354 | Diana   | (770) 555-1861 | 3592750733      | 322W7JE       |
| 686048 | Bruce   | (367) 555-5533 | 5773159633      | 94KL13X       |
+--------+---------+----------------+-----------------+---------------+
*/

-- People who called
SELECT * FROM people WHERE phone_number IN (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60);
/*
+--------+---------+----------------+-----------------+---------------+
|   id   |  name   |  phone_number  | passport_number | license_plate |
+--------+---------+----------------+-----------------+---------------+
| 395717 | Kenny   | (826) 555-1652 | 9878712108      | 30G67EN       |
| 398010 | Sofia   | (130) 555-0289 | 1695452385      | G412CB7       |
| 438727 | Benista | (338) 555-6650 | 9586786673      | 8X428L0       |
| 449774 | Taylor  | (286) 555-6063 | 1988161715      | 1106N58       |
| 514354 | Diana   | (770) 555-1861 | 3592750733      | 322W7JE       |
| 560886 | Kelsey  | (499) 555-9472 | 8294398571      | 0NTHK55       |
| 686048 | Bruce   | (367) 555-5533 | 5773159633      | 94KL13X       |
| 907148 | Carina  | (031) 555-6622 | 9628244268      | Q12B3Z3       |
+--------+---------+----------------+-----------------+---------------+
*/


-- Ealiest Flight out from Fiftyvill tomorrow of theft (July 29)
SELECT * FROM airports JOIN flights ON airports.id = flights.origin_airport_id WHERE month = 7 AND day = 29 AND city = 'Fiftyville';
/*
+----+--------------+-----------------------------+------------+----+-------------------+------------------------+------+-------+-----+------+--------+
| id | abbreviation |          full_name          |    city    | id | origin_airport_id | destination_airport_id | year | month | day | hour | minute |
+----+--------------+-----------------------------+------------+----+-------------------+------------------------+------+-------+-----+------+--------+
| 8  | CSF          | Fiftyville Regional Airport | Fiftyville | 18 | 8                 | 6                      | 2024 | 7     | 29  | 16   | 0      |
| 8  | CSF          | Fiftyville Regional Airport | Fiftyville | 23 | 8                 | 11                     | 2024 | 7     | 29  | 12   | 15     |
| 8  | CSF          | Fiftyville Regional Airport | Fiftyville | 36 | 8                 | 4                      | 2024 | 7     | 29  | 8    | 20     |
| 8  | CSF          | Fiftyville Regional Airport | Fiftyville | 43 | 8                 | 1                      | 2024 | 7     | 29  | 9    | 30     |
| 8  | CSF          | Fiftyville Regional Airport | Fiftyville | 53 | 8                 | 9                      | 2024 | 7     | 29  | 15   | 20     |
+----+--------------+-----------------------------+------------+----+-------------------+------------------------+------+-------+-----+------+--------+
*/

-- Flight filter to earliest and return 1
SELECT * FROM airports JOIN flights ON airports.id = flights.origin_airport_id WHERE month = 7 AND day = 29 AND city = 'Fiftyville' ORDER BY HOUR LIMIT 1;
/*
+----+--------------+-----------------------------+------------+----+-------------------+------------------------+------+-------+-----+------+--------+
| id | abbreviation |          full_name          |    city    | id | origin_airport_id | destination_airport_id | year | month | day | hour | minute |
+----+--------------+-----------------------------+------------+----+-------------------+------------------------+------+-------+-----+------+--------+
| 8  | CSF          | Fiftyville Regional Airport | Fiftyville | 36 | 8                 | 4                      | 2024 | 7     | 29  | 8    | 20     |
+----+--------------+-----------------------------+------------+----+-------------------+------------------------+------+-------+-----+------+--------+
*/


-- INTERSECT THE 3 ALIBIS
SELECT * FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28 AND minute BETWEEN 15 AND 25)
   INTERSECT SELECT * FROM people WHERE id IN (SELECT person_id FROM bank_accounts WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND transaction_type = 'withdraw' AND atm_location = 'Leggett Street'))
   INTERSECT SELECT * FROM people WHERE phone_number IN (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60);
/*
+--------+-------+----------------+-----------------+---------------+
|   id   | name  |  phone_number  | passport_number | license_plate |
+--------+-------+----------------+-----------------+---------------+
| 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
| 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
+--------+-------+----------------+-----------------+---------------+
*/

-- People who has flight earliest july 29
SELECT name FROM people WHERE passport_number IN (SELECT passport_number FROM passengers WHERE flight_id IN (SELECT flights.id FROM airports JOIN flights ON airports.id = flights.origin_airport_id WHERE month = 7 AND day = 29 AND city = 'Fiftyville' ORDER BY HOUR LIMIT 1));
/*
+--------+
|  name  |
+--------+
| Kenny  |
| Sofia  |
| Taylor |
| Luca   |
| Kelsey |
| Edward |
| Bruce  |
| Doris  |
+--------+
*/


-- INTERSECT people with flight TO people intersection fo 3 alibis
SELECT * FROM people WHERE passport_number IN (SELECT passport_number FROM passengers WHERE flight_id IN (SELECT flights.id FROM airports JOIN flights ON airports.id = flights.origin_airport_id WHERE month = 7 AND day = 29 AND city = 'Fiftyville' ORDER BY HOUR LIMIT 1))
    INTERSECT
        SELECT * FROM people WHERE license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE month = 7 AND day = 28 AND minute BETWEEN 15 AND 25)
            INTERSECT
                SELECT * FROM people WHERE id IN (SELECT person_id FROM bank_accounts WHERE account_number IN (SELECT account_number FROM atm_transactions WHERE month = 7 AND day = 28 AND transaction_type = 'withdraw' AND atm_location = 'Leggett Street'))
            INTERSECT
                SELECT * FROM people WHERE phone_number IN (SELECT caller FROM phone_calls WHERE month = 7 AND day = 28 AND duration < 60);
/*
+--------+-------+----------------+-----------------+---------------+
|   id   | name  |  phone_number  | passport_number | license_plate |
+--------+-------+----------------+-----------------+---------------+
| 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
+--------+-------+----------------+-----------------+---------------+
*/


-- Identify the receiver of caller
SELECT * FROM people WHERE phone_number IN (SELECT receiver FROM phone_calls WHERE caller = '(367) 555-5533' AND month = 7 AND day = 28 AND duration < 60);
/*
+--------+-------+----------------+-----------------+---------------+
|   id   | name  |  phone_number  | passport_number | license_plate |
+--------+-------+----------------+-----------------+---------------+
| 864400 | Robin | (375) 555-8161 | NULL            | 4V16VO0       |
+--------+-------+----------------+-----------------+---------------+
*/

-- Identify destination of flight
SELECT * FROM airports WHERE id = (SELECT destination_airport_id FROM airports JOIN flights ON airports.id = flights.origin_airport_id WHERE month = 7 AND day
= 29 AND city = 'Fiftyville' ORDER BY HOUR LIMIT 1);
/*
+----+--------------+-------------------+---------------+
| id | abbreviation |     full_name     |     city      |
+----+--------------+-------------------+---------------+
| 4  | LGA          | LaGuardia Airport | New York City |
+----+--------------+-------------------+---------------+
*/
