/
-------------------Feed2---------------------
This Feed produces a very high rate of instrument feed data. Based in the london region.
This feed produces data in json format. Supported Currency is GBP
\ 


// ---------------------Logic for Starting up Feed and timers--------------------
.z.ts:{jobs: exec jobId from .timer.jobs where <[start; .z.P];
    .timer.run each jobs;
    } 

startFeed2:{[]
    //The startFeed function runs the initial startup for the feed.
    currBatch::([]uniqueId:(); RA:(); R:(); NP:(); P:(); Y:(); executionTime:(); accountRef:(); marketName:(); instrumentType:(); batchId:());
    accountData::(::);
    system "l helperFunctions/myTimers.q"; /loads in timer functions

    //Used for creating a list of timers on this q process.
    .timer.ID: 1000;
    .timer.jobs:([jobId:()] func:(); arguments:(); typ:(); interval:(); start:());
    `.timer.jobs upsert (0N;`;enlist(::);`;0N;0Wp);

    .timer.enable[1000];
 }



// ---------------------Making Instruments and Sending Batches Logic--------------------- 

makeInstrument2:{[]
    // Generate random instrument data and append to currBatch (but not send to Pricer).
    // More info on variables available in README.md. batchId is generated when batch is sent.

    RA:(1 + rand 99)%100;
    R: (1 + rand 99)%100;
    NP: (1000000+rand 999000000); //A random number between 1M and 1B
    P:1 + rand 365; // A random number between 1 day and 365 days w/ leading zeros for fixed width
    Y:360;
    executionTime:.z.P;
    accountRef: rand exec accountRef from accountData where billingCurrency=`GBP;
    marketName: `LSE;
    instrumentType: rand `Stk`Bnd;
    uniqueId:`$"F2_",string[accountRef],string[executionTime];
    batchId: `;

    //upserting instrument into a currBatch
    `currBatch upsert (uniqueId; RA; R; NP; P; Y; executionTime; accountRef; marketName; instrumentType; batchId);
 }

/Adds batchId to end of instruments, makes a json object, and sends to the instrument pricer (Port 5000)
sendBatch2:{[]
    if[count[currBatch]<1; :(::)];
    update batchId:`$("BF2_",string[.z.P]) from `currBatch;
    currBatchFreeze:: currBatch;
    save `$":Data/Feed2/currBatchFreeze.json"; //taking a snapshop of currBatch to avoid changes while makeInstrument runs
    `::[(":localhost:5000";5000);"readFeed2[]"];
    currBatch::currBatch except currBatchFreeze;
    }



//--------------------------Initializing Timers-----------------------------
MakeF2InstrumentTimer:{[] //Called in feed 3, after the account data is sent
    if[count[accountData]=1; :(::)];
    .timer.add[`makeInstrument2;enlist(::);`Repeat;"j"$30000000000;.z.P+"j"$3e+10]; //real time, replace after testing: 1.8e+11
    SendF2BatchTimer[];
    }

SendF2BatchTimer:{[] // Called in MakeF2InstrumentTimer to arm once instruments are bieng made
    .timer.add[`sendBatch2;enlist(::);`Repeat;"j"$1.2e+11;.z.P+"j"$3e+10]; //real time, replace after testing: 9e+11
    }



/----------------run startFeed on start up of q process ---------------------- 
startFeed2[];