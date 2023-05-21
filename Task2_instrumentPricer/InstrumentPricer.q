
startPricer:{[]
    currBatch::([]uniqueID:(); RA:(); R:(); NP:(); P:(); Y:(); executionTime:(); accountRef:(); marketName:(); instrumentType:(); batchId:());
    }

//Reading in and formatting data from feed 1
readFeed1:{[feedData]
    //Data should be a long string, combining a list of fixed width strings.
    //In each instrument, each variable has an exact number of charachters and is deliminated by a "|".
    numInstruments::"j"$(count[feedData]%156);
    feedData: #[numInstruments, 156; feedData]; //seperates by instrument
    feedData: {$[(`;"F";"F";"F";"F";"F";"P";`;`;`;`);vs["|";x]]} each feedData; /seperating by deliminator and changing type
    `currBatch upsert feedData;
    }

//Reading in and formatting data from feed 2
readFeed2:{[data]
    feedData:: .j.k each read0 `$":Data/Feed2/currBatch.json"; //reading in JSON object
    update "S"$uniqueID, "P"$executionTime, "S"$accountRef, "S"$marketName, "S"$instrumentType, "S"$batchId from `feedData; 
    `currBatch upsert feedData;
    }

//runs startFeed on start up of q
startPricer() 