//Functions to add, remove, and run functions in .timer.jobs, and enable/diasable timer
.timer.ID: 1000;
.timer.jobs:([jobId:()] func:(); arguments:(); typ:(); interval:(); start:());
`.timer.jobs upsert (0N;`;enlist(::);`;0N;0Wp);

.timer.add:{[func; arguments; typ; interval; start]
    .timer.ID: .timer.ID + 1;
    ID: .timer.ID;
    .timer.jobs:: .timer.jobs upsert (ID;func;arguments;typ;interval;start);
    }

.timer.delete:{[id] .timer.jobs: delete from .timer.jobs where jobId = id;
    }  // Will not be used but included for future functionality

.timer.run:{[id]
    dict: exec from .timer.jobs where jobId = id;
    start: dict[`start]; //Range of time where function works
    func: dict[`func]; //Get function from table
    typ: dict[`typ];
    arguments: dict[`arguments];
    Newtime: start + dict[`interval]; //offest start time. Current start + interval
    if[typ=`Once; .timer.jobs: delete from .timer.jobs where jobId = id; :`$".timer.jobs"]; //no one time timers but added for later functionality
    .timer.jobs:: update start: Newtime from .timer.jobs where jobId = id; //update table
    func . arguments //run function
    }

.timer.enable:{[x] system"t ", string[x];
    }

.timer.disable:{system"t 0";
    }

