/
-------------------Feed3---------------------
This Feed gives a snapshot of static account data nce a day at 06:00 GMT. A single batch insert 
as soon as the process is restarted daily. This feed produces data in csv format. 
\


pushAccountData:{[]
        //Sending accountData (created in Start Feed Function) to feeds 2 & 3.
        
        //connecting to Feeds 1 & 2  and the Pricer then sending path to accountsData.csv 
        `::[(":localhost:4001";5000);"accountData: (string[`SSDSS];enlist \",\") 0: `:Data/Feed3/accountData.csv"];
        `::[(":localhost:4002";5000);"accountData: (string[`SSDSS];enlist \",\") 0: `:Data/Feed3/accountData.csv"];
        `::[(":localhost:5000";5000);"accountData: (string[`SSDSS];enlist \",\") 0: `:Data/Feed3/accountData.csv"];
        //system "sleep 5"
        `::[(":localhost:4001";5000);"MakeF1InstrumentTimer[]"];
        `::[(":localhost:4002";5000);"MakeF2InstrumentTimer[]"];
        
    }



startFeed3:{[]
    // The startFeed function runs the initial startup for the feed.

    // Account mapping is detailed in README.md 
    accountMapping:([accountRef:`0000000001`0000000002`0000000003`0000000004`0000000005`0000000006] accountGroup:`grX`grY`grZ`grX`grY`grZ);
    len: count accountMapping; //number of accounts in mapping
    accountData:: accountMapping,'([] modifiedDate:.z.D; 
        billingCurrency:len?`GBP`EUR; clientName:len?()); //appending other content. Client name filled later
    update clientName:(`$?[3+ rand 5; " "]," ",?[3+ rand 7; " "]) by accountRef from `accountData; //Filling in randomized client Name.
    
    accountsCSV:: save `:Data/Feed3/accountData.csv; //saving acounts as a CSV file

    pushAccountData[];
 }



startFeed3[]; //runs startFeed on start up of q