
startPricer:{[]
    instrumentPrice::([]uniqueId:(); RA:(); R:(); NP:(); P:(); Y:(); executionTime:(); accountRef:(); marketName:(); instrumentType:(); batchId:(); price: ());
    }

//Calculating the price & adding to instrumentPrice table; 
calcPrice:{[currBatchId]
    update price:"f"$(((R-RA)*NP*P)%(1*Y))*(1%(1+R*(P%Y))) from `instrumentPrice where batchId=currBatchId;
    }

//Reading in and formatting data from feed 1, then appending to instrumentPrice Table and calling calcPrice
readFeed1:{[feedData1]
    //Data should be a long string, combining a list of fixed width strings.
    //In each instrument, each variable has an exact number of charachters and is deliminated by a "|".
    numInstruments:"j"$(count[feedData1]%156);
    feedData1: #[numInstruments, 154; feedData1]; //seperates by instrument
    feedData1:{$[(`;"F";"F";"F";"F";"F";"P";`;`;`;`);vs["|";x]]} each feedData1; /seperating by deliminator and changing type
    `instrumentPrice upsert feedData1,' numInstruments#0Nf;
    calcPrice(feedData1[0;10]); //only focusing on current batch to reduce processing time
    }

//Reading in and formatting data from feed 2, then appending to instrumentPrice Table and calling calcPrice
readFeed2:{[]
    feedData2:: .j.k each read0 `$":Data/Feed2/currBatchFreeze.json"; //reading in JSON object
    update "S"$uniqueId, "P"$executionTime, "S"$accountRef, "S"$marketName, "S"$instrumentType, "S"$batchId from `feedData2;
    `instrumentPrice upsert feedData2,'([]price:count[feedData2]#0Nf);
    calcPrice(exec first batchId from feedData2);
    }

//runs startFeed on start up of q
startPricer[]; 