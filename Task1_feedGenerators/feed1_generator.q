// This Feed is a legacy system. 
// Very slow at producing instrument feeds and is based in the Frankfurt region.
// This feed produces data in fixed width string format.
// Supported Currency is EUR


// The startFeed function runs the initial startup for the feed.
startFeed1:{[]
    currBatch::(); //A list that will be filled as instuments come in and emptied out when sent to TP.
    accountData::(::);
 }

// The makeInstrument function will randomly generate an instrument when called 
// The function will add the new Instrument values to currBatch but will not send to TP.
// Variables for Feed 1. More informations about these variables in available in the README.md.
// BatchID is generated when batch is sent.
makeInstrument:{[]
    RA:4#string[(1 + rand 99)%100],"00";
    R: 4#string[(1 + rand 99)%100],"00"; //First 4 digits from a decimal w/ extra zeors appended (for fixed width).
    NP: -10#"000",string[1000000+rand 999000000]; //A random number between 1M and 1B  in sci-notation w/ leading zeros for fixed width
    P:1_string (1 + rand 365) + 10 xexp 3; // A random number between 1 day and 365 days w/ leading zeros for fixed width
    Y:"365";
    executionTime:string .z.P;
    accountRef: string rand exec accountRef from accountData where billingCurrency=`EUR;
    marketName:"FSE";
    instrumentType: string rand `Stock`Bond_; //A _ is placed after bond to keep a fixed legnth.
    uniqueID:"F1_",accountRef,executionTime;

    //formatting generated instument into a fixed width string
    formattedInstrument: RA,R,NP,P,Y,executionTime,accountRef,marketName,instrumentType,uniqueID;

    //Appending to the currBatch List
    currBatch::currBatch, enlist formattedInstrument;
 }

//timer
setFeed1Timer:{[]
    if[null accountData; :(::)];
    
    }

startFeed1() //runs startFeed on start up of q
