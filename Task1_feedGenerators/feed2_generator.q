// This Feed produces a very high rate of instrument feed data.
// This feed produces data in json format.
// Based in the Frankfurt region. Supported Currency is GBP


// The startFeed function runs the initial startup for the feed.
startFeed2:{[]
    currBatch::([uniqueID:()] RA:(); R:(); NP:(); P:(); Y:(); executionTime:(); accountRef:(); marketName:(); instrumentType:());
    accountData::(::);
 }

// The makeInstrument function will randomly generate an instrument when called 
// The function will add the new Instrument values to currBatch but will not send to TP.
// Variables for Feed 2. More informations about these variables in available in the README.md.
// BatchID is generated when batch is sent.
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

//timer
setFeed2Timer:{[]
    if[null accountData; :(::)];
    
    }

startFeed2() //runs startFeed on start up of q