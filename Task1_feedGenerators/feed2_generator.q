// This Feed produces a very high rate of instrument feed data.
// This feed produces data in json format.
// Based in the Frankfurt region. Supported Currency is GBP


// The startFeed function runs the initial startup for the feed.
startFeed2:{[]
    currBatch::([]uniqueID:(); RA:(); R:(); NP:(); P:(); Y:(); executionTime:(); accountRef:(); marketName:(); instrumentType:());
    accountData::(::);
 }

// Generate random instrument data and append to currBatch (but not send to Pricer).
// More info on variables available in README.md. BatchID is generated when batch is sent.
makeInstrument:{[]
    RA:(1 + rand 99)%100;
    R: (1 + rand 99)%100;
    NP: (1000000+rand 999000000); //A random number between 1M and 1B
    P:1 + rand 365; // A random number between 1 day and 365 days w/ leading zeros for fixed width
    Y:360;
    executionTime:.z.P;
    accountRef: rand exec accountRef from accountData where billingCurrency=`GBP;
    marketName: `LSE;
    instrumentType: rand `Stock`Bond;
    uniqueID:`$"F2_",string[accountRef],string[executionTime];

    //upserting instrument into a currBatch
    `currBatch upsert (uniqueID; RA; R; NP; P; Y; executionTime; accountRef; marketName; instrumentType);
 }

/Adds batchID to end of instruments, makes a json object, and sends to the instrument pricer (Porst 5000)
sendBatch:{[]
    update batchId:`$("BF2_",string[.z.P]) from `currBatch;
    save `$":Data/Feed2/currBatch.json";
    `::[(":localhost:5000";5000);"readFeed2()"];
    currBatch::([]uniqueID:(); RA:(); R:(); NP:(); P:(); Y:(); executionTime:(); accountRef:(); marketName:(); instrumentType:());
    }

//---------timers---------
MakeF2InstrumentTimer:{[]
    if[null accountData; :(::)];
    
    }

SendF2BatchTimer:{[]
    
    }

startFeed2() //runs startFeed on start up of q