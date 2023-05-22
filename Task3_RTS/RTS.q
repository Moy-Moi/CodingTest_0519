/
------------------- Real Time Subscriber ---------------------
The realtime average price for instruments per accountGroup in US Dollars.
Rolling average price of 5 min intervals for instruments per accountGroup in US Dollars.
\

startRTS:{[]
    instrumentTable::([uniqueId:()]; executionTime:(); accountRef:(); marketName:(); instrumentType:(); batchId:(); price:(); accountGroup:(); priceUSD:());
    exchRate:: `LSE`FSE!1.24 1.08;
    avgPrice::();
    rollingAvgPrice::();
    }

updateInstruments:{[]
    `instrumentTable upsert (select uniqueId,executionTime,accountRef,marketName,instrumentType,batchId,accountGroup,price from newInstrument),'([]priceUSD:count[newInstrument]#0Nf);
    update priceUSD:"f"$(price*exchRate[marketName]) from `instrumentTable;

    //Calculating the Avg price per accountGroup
    avgPrice:: select avgGroupPrice:(avg price) by accountGroup from instrumentTable;
    rollingAvgPrice:: select avgGroupPrice:(avg price) 
                        by accountGroup, executionTime:19h$(300 xbar executionTime.second)
                        from instrumentTable;
                        
    }
    

//runs startRTS on start up of q
startRTS[];
