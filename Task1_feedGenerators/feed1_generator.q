/
-------------------Feed1---------------------
This Feed is a legacy system.Very slow at producing instrument feeds and is based in the Frankfurt region.
This feed produces data in fixed width string format. Supported Currency is EUR
\


// ---------------------Logic for Starting up Feed and timers--------------------
.z.ts:{jobs: exec jobId from .timer.jobs where <[start; .z.P];
    .timer.run each jobs;
    } 

startFeed1:{[]
    //The startFeed function runs the initial startup for the feed.
    currBatch::(); //A list that will be filled as instuments come in and emptied out when sent to TP.
    accountData::(::);
    system "l helperFunctions/myTimers.q"; /loads in timer functions

    //Used for creating a list of timers on this q process.
    .timer.ID: 1000;
    .timer.jobs:([jobId:()] func:(); arguments:(); typ:(); interval:(); start:());
    `.timer.jobs upsert (0N;`;enlist(::);`;0N;0Wp);

    .timer.enable[1000];
 }



// ---------------------Making Instruments and Sending Batches Logic--------------------- 

makeInstrument:{[]
    // Generate random instrument data and append to currBatch (but not send to Pricer).
    // More info on variables available in README.md. BatchID is generated when batch is sent.
    
    RA:4#string[(1 + rand 99)%100],"00";
    R: 4#string[(1 + rand 99)%100],"00"; //First 4 digits from a decimal w/ extra zeors appended (for fixed width).
    NP: -10#"000",string[1000000+rand 999000000]; //A random number between 1M and 1B  in sci-notation w/ leading zeros for fixed width
    P:1_string (1 + rand 365) + 10 xexp 3; // A random number between 1 day and 365 days w/ leading zeros for fixed width
    Y:"365";
    executionTime:string .z.P;
    accountRef: string rand exec accountRef from accountData where billingCurrency=`EUR;
    marketName:"FSE";
    instrumentType: string rand `Stk`Bnd; //A _ is placed after bond to keep a fixed legnth.
    uniqueId::"F1_",accountRef,executionTime;

    //formatting generated instument into a fixed width string deliminated by "|"
    formattedInstrument:: "|" sv (uniqueId;RA;R;NP;P;Y;executionTime;accountRef;marketName;instrumentType);

    //Appending to the currBatch List
    currBatch::currBatch, enlist formattedInstrument;
 }

/Adds batchID to end of instruments and sends to the instrument pricer (Port 5000)
sendBatch:{[]
    if[count[currBatch]<1; :(::)];
    batchId: "|BF1_",string .z.P; // "|" included for delimination
    currBatchFreeze::,[;batchId] each currBatch; //taking a snapshop of currBatch to avoid changes while makeInstrument runs
    `::[(":localhost:5000";5000);"readFeed1(\"",raze currBatchFreeze,"\")"];
    currBatch::currBatch except currBatchFreeze;
    }



//--------------------------Initializing Timers-----------------------------
MakeF1InstrumentTimer:{[] //Called in feed 3, after the account data is sent.
    if[count[accountData]=1; :(::)];
    .timer.add[`makeInstrument;enlist(::);`Repeat;"j"$9e+11;.z.P+"j"$3e+10]; 
    SendF1BatchTimer[];
    }

SendF1BatchTimer:{[] // Called in MakeF1InstrumentTimer to arm once instruments are bieng made
    .timer.add[`sendBatch;enlist(::);`Repeat;"j"$3.6e+12;.z.P+"j"$3e+10]; 
    }



//----------------run startFeed on start up of q process ---------------------- 
startFeed1[]; 
