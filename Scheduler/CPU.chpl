/**
 * Implements a CPU that runs processes.
 *
 * Author: Kyle Burke <paithanq@gmail.com>
 */
use Time;
use Random;
use Job;
use BlockingQueue;


//CPU
class CPU {
	
	var debug : bool = false;
	
    var incoming : BlockingQueue(Job);
    
    var indexDomain = {0..1};
    
    var waitTimes : [indexDomain] real;
    
    var latencies : [indexDomain] real;
    
    var name : string;
    
    var active : bool;
    
    var jobsCompleted : int;
    
    proc CPU(queue: BlockingQueue(Job), name : string) {
        incoming = queue;
        this.name = name;
        this.active = true;
        this.jobsCompleted = 0;
    }
    
    proc run() {
        while (this.active) {
			if (debug) then writeln("CPUs: top of run of #",this.name);
            var job = incoming.remove();
			
            /*
            if (job.getLength() > 1000) {
                //this job is a sentinel: the test has ended.
                writeln("The end has come for CPU #" + this.name);
                this.active = false;
                break;
            }
            */
            //otherwise, run the job
            if (this.jobsCompleted > indexDomain.high) {
                //the indexDomain is too small, so double the size.
                indexDomain = {0..(2*this.jobsCompleted)};
            }
            job.startRunning();
            //run the job
            sleep(job.getLength());
            //stop the job and record the stats.
            job.stopRunning();
            waitTimes[this.jobsCompleted] = job.getWaitTime();
            latencies[this.jobsCompleted] = job.getLatency();
            writeln("CPU " + this.name + " completed job #", this.jobsCompleted, ":\n  Wait Time: ", waitTimes[this.jobsCompleted], "s\n  Length: ", job.getLength() + "s\n  Latency: ", latencies[this.jobsCompleted], "s");
            this.jobsCompleted +=1;
			//if (debug) then 
			//writeln("CPUs: We have ",incoming.getNumElements(), " things in the queue");
        }
        writeln(this.toString());
        writeln(this.incoming.toString());
    }
    
    proc stop() {
        this.active = false;
    }
    
    proc getName() : string {
        return this.name;
    }
    
    proc isActive() : bool {
        return this.active;
    }
    
    proc totalWaitTime() : real {
        return + reduce waitTimes;
    }
    
    proc maxWaitTime() : real {
        return max reduce waitTimes;
    }
    
    proc totalLatency() : real {
        return + reduce latencies;
    }
    
    proc maxLatency() : real {
        return max reduce latencies;
    }
    
    proc averageWaitTime() : real {
        return totalWaitTime() / (indexDomain.high + 1);
    }
    
    proc averageLatency() : real {
        return totalLatency() / (indexDomain.high + 1);
    }
    
    proc toString() : string {
        var s = "";
        s += "+----- CPU " + this.name + " --------------------------+\n";
        s += "| Jobs Completed: " + this.jobsCompleted + "\n";
        s += "| Total Wait Time: " + totalWaitTime() + "\n";
        s += "| Total Latency: " + totalLatency() + "\n";
        s += "| Average Wait Time: " + averageWaitTime() + "\n";
        s += "| Average Latency: " + averageLatency() + "\n";
        s += "| Max Wait Time: " + maxWaitTime() + "\n";
        s += "| Max Latency: " + maxLatency() + "\n";
        s += "+--------------------------------------+\n";
        return s;
    }
}

/*
config const n = 10;

var numJobs = n;

var queue = new BlockingQueue(Job, min(n/2, 10));

var cpu = new CPU(queue, numJobs);
begin {
    sleep(2);
    cpu.run();
}
var rng = new NPBRandomStream();

var maxTime = 2;

forall i in 0..numJobs-1 {
    var job = new Job(rng.getNext() * maxTime);
    writeln("New job created, length: " + job.getLength());
    queue.add(job);
}
*/






