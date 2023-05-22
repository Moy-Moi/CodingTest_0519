/
------------------- Real Time Subscriber ---------------------
Instrument Pricer that will price each instrument in its native currency for each feed that comes in.
These results should be saved to an im memory table.
\

//Timet Setup; and startup logic
if[system"t";
 .z.ts:{pub[]};
    ];

if[not system"t";system"t 1000";
 .z.ts:{pub[]};
    ];


startPricer:{[]
    instrumentTable::([]uniqueId:(); RA:(); R:(); NP:(); P:(); Y:(); executionTime:(); accountRef:(); marketName:(); instrumentType:(); batchId:(); accountGroup:(); price: ());
    h::hopen `::5001;
    h"setTable:{newInstrument::x; updateInstruments[]}"; //setting setTabfunction to collect and assign table in RTS
    }

//Calculating the price & adding to instrumentTable table; 
calcPrice:{[currBatchId]
    //updating price
    update price:"f"$(((R-RA)*NP*P)%(1*Y))*(1%(1+R*(P%Y))) from `instrumentTable where batchId=currBatchId;

    //updating accountGroup
    instrumentTable:: select uniqueId,RA,R,NP,P,Y,executionTime,accountRef,marketName,instrumentType,batchId,accountGroup,price from ej[`accountRef;instrumentTable;accountData];
    }

//Reading in and formatting data from feed 1, then appending to instrumentTable Table and calling calcPrice
readFeed1:{[feedData1]
    //Data should be a long string, combining a list of fixed width strings.
    //In each instrument, each variable has an exact number of charachters and is deliminated by a "|".
    numInstruments:"j"$(count[feedData1]%154);
    feedData1: #[numInstruments, 154; feedData1]; //seperates by instrument
    feedData1:{$[(`;"F";"F";"F";"F";"F";"P";`;`;`;`);vs["|";x]]} each feedData1; /seperating by deliminator and changing type
    `instrumentTable upsert feedData1,' numInstruments#(enlist (`;0Nf)); //Appending empty accountData and price to be filled later.
    calcPrice(feedData1[0;10]); //only focusing on current batch to reduce processing time
    }


//Reading in and formatting data from feed 2, then appending to instrumentTable Table and calling calcPrice
readFeed2:{[]
    feedData2:: .j.k each read0 `$":Data/Feed2/currBatchFreeze.json"; //reading in JSON object
    update "S"$uniqueId, "P"$executionTime, "S"$accountRef, "S"$marketName, "S"$instrumentType, "S"$batchId from `feedData2;
    `instrumentTable upsert feedData2,'([]accountGroup:count[feedData2]#`;price:count[feedData2]#0Nf);
    calcPrice(exec first batchId from feedData2);
    }


pub:{[]
    instrumentTableFreeze:: select from instrumentTable where not null price;
    neg[h] (`setTable;instrumentTableFreeze);
    }

//runs startPricer on start up of q
startPricer[]; 