// This Feed gives a snapshot of static account data nce a day at 06:00 GMT
// A single batch insert as soon as the process is restarted daily.
// This feed produces data in csv format
// Based in the US region. Supported Currency is USD


// The startFeed function runs the initial startup for the feed.
// Account mapping is detailed in README.md 
startFeed:{[]
    currBatch::([]RA:(); R:(); NP:(); P:(); Y:(); clientName:(); modifiedDate:(); billingCurrency:(); accountRef:(); accountGroup:());
    accountMapping::([accountRef:`0000000001`0000000002`0000000003`0000000004`0000000005`0000000006] accountGroup:`grX`grY`grZ`grX`grY`grZ)
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
    clientName:`$?[3+ rand 5; " "]," ", ?[3+ rand 7; " "];
    modifiedDate: .z.D;
    billingCurrency: rand `USD`GBP`EUR;
    accountRef: rand `0000000001`0000000002`0000000003`0000000004`0000000005`0000000006;
    accountGroup: first exec accountGroup from accountMapping where accountRef=accountRef;
    
    //upserting instrument into a currBatch
    `currBatch upsert (RA; R; NP; P; Y; clientName; modifiedDate; billingCurrency; accountRef; accountGroup);
 }

