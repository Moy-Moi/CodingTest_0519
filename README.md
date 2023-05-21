# CodingTest_0519: kdb-dev-programming-test assigned on May 19, 2023

## To use:
1. Start up  ach feed with the following (assuming q is installed as expected) in this exact order:
   1. q Task1_feedGenerators/feed1_generator.q -p 4001
   2. q Task1_feedGenerators/feed2_generator.q -p 4002
   3. q Task1_feedGenerators/feed3_generator.q -p 4003

## Current quetions:
1. market name and instrument type? 

## Overview of Assumptions Made

1. The feeds are q processes. 
2. Assuming that each feed will be sent from different servers (over different ports), different files were created for randomly generating each feed.The tickerplant in on port 5000. Feed 1,2, &3 are on ports 4001,4002, & 4003 respectively.
3. Every Morning feed 3 will create a new mapping of clientName, billing Currency, and accountGroup for every account ref. This mapping will be sent to feed 2 and 3, which will create instrument data for the day, based on these values. Feeds 1 & 2, will then send instrument data to the Instrument Pricer.   
3. Assumptions about variables & additional contents:
   1. Notional prinicpal will between an million and a billion of a curreny.
   2. Becuase Feed 1 deals in EUROs it will run on an ACT/365 (max P=Y=365). While Feed 2 uses the GPB and will run on ACT/360 (max P=365; Y=360).
   3. UniqueId is a combination of the Feed ID (F1 or F2), accountRef, and datetime. 
   4. Market Name is the name of the cities associated Stock Exchange. 
   5. In feed 3, the client name & billing currency associated with each account ref will change daily. 
6. Feed 1 will send updates to the TP every hour.  Feed 2 send updates to the TP every 5 mins. Feed 3 sends updates once a day. Feeds do not save any data after sending to TP.


## File Structure
1. Task1_Feeds: Contains feed start up and generation scripts for feeds 1,2, & 3


## Problem Description

Your team is working for a global business that needs the ability to support a new type of instrument worldwide.
You have been tasked with creating a new Instrument Pricer in order to support this operation.
The new Pricer needs to run in its own Q process and will perform a calculation, and would like to
eventually cross reference this figure in US Dollars (USD).

## Requirement

The formula to calculate this price takes into account five different variables. They are:

RA = the rate of interest
R = the reference rate of interest in Libor, determined at some point within the future
NP = the notional principal in money
P = the period, which is the number of days in the contract period
Y = the number of days in the year based on the correct day-count convention for the contract

The amount is calculated by the following equation:
price = (((R - RA) x NP x P) / (1 x Y)) x (1 / (1 + R x (P / Y)))

For example consider the following data:
RA = 3.5%
R = 4%
NP = $100 million
P = 181 days
Y = 360 days
The price using the above figures once calculated would result to $8348708.487

Messages will be exchanged by three upstream processes and perform insertions into the Ticker Plant.
1. Feed 1 - The first system is legacy, this is very slow at producing instrument feeds and is based in the Frankfurt region.
   The Instrument feed contains the above 5 key variables, in addition to some reference data.
   format = This feed produces data in fixed width string format.
   supported currencies: EUR

2. Feed 2 - The second system produces a very high rate of instrument feed data and is based in the London region.
   The Instrument feed contains the above 5 key variables, in addition to some reference data.
   format = This feed produces data in json format
   supported currencies: GBP

3. Feed 3- The 3rd system will give you a snapshot of static account data.
   Data comes in once a day at 06:00 GMT and performs a single batch insert. For simplicity you can assume that this data is published as soon as the process is restarted daily.
   format = This feed produces data in csv format

contents for Feeds 1 & 2: One instrument at a time plus the following joined reference data as a single message:

- batchId,
- executionTime;
- accountRef;
- uniqueId;
- marketName
- instrumentType

additional content for Feed 3:
- accountRef;
- clientName
- modifiedDate
- billingCurrency
- accountGroup

Data for all feeds uses a fixed set of accounts / groups. here is the fixed mapping of accountGroup to accounts:

accountGroup|accountRef
-----------------------
grX| 0000000001
grY| 0000000002
grZ| 0000000003
grX| 0000000004
grY| 0000000005
grZ| 0000000006

## Task
-
1. Create randomised feed generator for Feeds 1,2,3 to publish to a ticker plant.
   Feeds should be generated in the specified format.
2. Create the Instrument Pricer that will price each instrument in its native currency for each feed that comes in.
    These results should be saved to an im memory table.
3. Supply an extension as a separate realtime Q process to provide:
    1. the realtime average price for instruments per accountGroup in US Dollars.
    2. rolling average price of 5 min intervals for instruments per accountGroup in US Dollars.
4. This average pricing data along with the instrumentType now needs to be made available to a Quants team.
   It will be fed into an algorithmic Q process to perform an intensive compute operation which can
   take up to 10 minutes to execute.
   What proposals to the solution would you recommend ?

## Tips
-
1. Your deliverable needs to be executable.
2. State any assumptions you make.
3. Produce three separate deliverables for each task using separate root folders.
4. Each deliverable should build upon the previous one.
5. supply instructions on how to run your solution. We use Linux.
6. Host your solution on GitHub
