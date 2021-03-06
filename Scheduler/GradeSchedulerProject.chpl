/*******************************
 * Tests projects for the Scheduler.chpl assignment.
 * 
 * Usage:
 * $ chpl -MteamNameProject2 GradeSchedulerProject.chpl
 * $ ./a.out
 *
 * Inside the folder teamNameProject2 there should be five files: 
 * * semaphore.chpl
 * * BlockingQueue.chpl
 * * Job.chpl (available from http://turing.plymouth.edu/~kgb1013/4310/schedulerProject/Job.chpl)
 * * CPU.chpl (available from http://turing.plymouth.edu/~kgb1013/4310/schedulerProject/CPU.chpl)
 * * Scheduler.chpl
 *
 * Author: Kyle Burke <paithanq@gmail.com>
 */
use Time;
use Random;
use BlockingQueue;
use Job;
use Scheduler;
use CPU;

config const n = 100;
config const c = 3;
config const t = 3;

var numberJobs = n;
var numCPUs = c;
var maxTime = t;


var rng = new NPBRandomStream();

//number of different tests I'm going to run
var numTests = 3;

var trialsDomain = {0..numTests-1};

var modes : [trialsDomain] string;
modes = ("maximum", "average", "hybrid");

var scoresDomain = {0..5};
var scores : [scoresDomain] int;
scores = (30, 25, 20, 15, 10, 5); 

var maxGoals, avgGoals, hybridGoals : [scores.domain] real;
maxGoals = (15, 30, 40, 50, 60, 80);
avgGoals = (5, 10, 15, 20, 25, 35);
hybridGoals = (40, 60, 80, 100, 120, 150);

var things : [0..2, 0..3] real;

//var goals : [scoresDomain] real;
//goals[0] = maxGoals;
//goals[1] = avgGoals;
//goals[2] = hybridGoals;

//var efficiencyGoals : [trialsDomain] real;
//efficiencyGoals = (30.5, 9.5, 50);


var results : TestResult;

for i in trialsDomain {
    var nilResult : TestResult;
    var mode = modes[i];
    writeln("About to run the " + mode + " test.");//  Press Enter to continue.");
    //stdin.readln();
    sleep(2);
    var trialsIndex : int;
    trialsIndex = i;
    //var efficiencyGoal : real;
    //efficiencyGoal = efficiencyGoals[i];
    var xx : int;
    xx = numCPUs;
    var yy : string;
    yy = mode;
    var zz : int;
    zz = numberJobs;
    //runTest(mode, numCPUs, numJobs, efficiencyGoal);
    var newResult = runTest(numCPUs, numberJobs, i);
    
    if (results == nilResult) {
        results = newResult;
    } else {
        results = new TestResult(results, newResult);
    }
    
    // I copied over the code from runTest because I can't figure out what's going on...
}

writeln(results);



proc runTest(numCPUs : int, numberJobs : int, modeIndex : int) : TestResult {
    
    
    var mode = modes[modeIndex];
    
    var goals : [scoresDomain] real = maxGoals;
    if (mode == "average") {
        goals = avgGoals;
    } else if (mode == "hybrid") {
        goals = hybridGoals;
    }
    
    var efficiencyGoals = goals[modeIndex];

    var jobs = new JobGroup();
    var scheduler = new Scheduler(mode);
    
    //ask the scheduler how big of a queue it wants.
    var queueCapacity = scheduler.getOutputQueueCapacity(numCPUs);

    //create the queue between scheduler and CPUs
    var schedulerToCPUs = new BlockingQueue(Job, queueCapacity);
    scheduler.setOutputQueue(schedulerToCPUs);
    
    //create the cpus
    var cpusDomain = {0..numCPUs-1};
    var cpus : [cpusDomain] CPU;
    forall i in cpus.domain {
        cpus[i] = new CPU(schedulerToCPUs, "" + i);
        begin{
            cpus[i].run();
        }
    }
    
    
    //Throw a first round of jobs at the Scheduler!
    var firstRoundSize = max(10, 3 * numCPUs);
    forall i in 1..(firstRoundSize) {
        var job = new Job(rng.getNext() * maxTime);
        jobs.add(job); //add it to the group
        scheduler.addJob(job);
    }
    
    var numRemainingJobs = numberJobs - firstRoundSize;
    
    //Throw the rest of the jobs at the Scheduler
    //for each cpu, create a separate thread to add jobs
    coforall i in cpusDomain {
        for j in 1..(numRemainingJobs / numCPUs) {
            var job = new Job(rng.getNext() * maxTime);
            jobs.add(job);
            begin { scheduler.addJob(job); } //don't wait on this
            sleep(.96 * (rng.getNext() * maxTime));
        }
    }
    
    //get the appropriate score
    var efficiencyMeasure = jobs.reportStats(modeIndex);
    var score = 0;
    var goalMade = "none";
    
    for i in scores.domain {
        var nextScore = scores[i];
        var goal = goals[i];
        if (efficiencyMeasure < goal) {
            score = nextScore;
            goalMade = goal + "s";
            break;
        }
    }
    var description = "Results of " + mode + " test:\nRecorded time: " + efficiencyMeasure + "s.\nBest goal passed: " + goalMade + "\nPoints earned: " + score + "/30\n\n";
    
    writeln(description);
    
    return new TestResult(score, 30, description);
    
    /* Old version
    
    writeln(mode + " test results:\nGoal: " + efficiencyGoal + "\nActual: " + efficiencyMeasure);
    if (efficiencyMeasure <= efficiencyGoal) {
        writeln("Passed the " + mode + " test!  Great Job!");
    } else {
        writeln("Failed the " + mode + " test!  Hmmmmm...");
    }
    */
    
}


//This represents the result of a test.
class TestResult {
    var score : int;
    var maxScore : int;
    var description : string;
    
    proc TestResult(score: int, maxScore : int, description : string) {
        this.score = score;
        this.maxScore = maxScore;
        this.description = description;
    }
    
    proc TestResult(resultA : TestResult, resultB : TestResult) {
        this.score = resultA.getScore() + resultB.getScore();
        this.maxScore = resultA.getMaxScore() + resultB.getMaxScore();
        this.description = resultA.getDescription() + "\n\n" + resultB.getDescription();
    }
    
    proc getScore() : int {
        return this.score;
    }
    
    proc getMaxScore() : int {
        return this.maxScore;
    }
    
    proc getDescription() : string {
        return this.description;
    }
    
    proc writeThis(writer) {
        writer.writeln("Total score: " + this.getScore() + "/" + this.maxScore);
        writer.write(this.getDescription());
    }
    
}



//This represents a set of Jobs.  It is used to report stats about those jobs.
class JobGroup {
    
    var jobsDomain = {0..1};
    
    var jobs : [jobsDomain] Job;
    
    var numJobs : int;
    
    var synchronizer : Semaphore;
    
    proc JobGroup() {
        this.numJobs = 0;
        this.synchronizer = new Semaphore(1);
    }
    
    proc add(job : Job) {
        this.synchronizer.p();
        if (this.numJobs == this.jobsDomain.numIndices) {
            this.jobsDomain = {0..(this.jobsDomain.high * 2)};
        }
        this.jobs[this.numJobs] = job;
        this.numJobs += 1;
        this.synchronizer.v();
    }
    
    proc allCompleted() : bool {
        for jobIndex in 0..(this.numJobs-1) {
            if (!this.jobs[jobIndex].isDone()) {
                return false;
            }
        }
        return true;
    }
    
    proc reportStats(statIndex : int) : real {
        //wait for the jobs to complete
        while (!this.allCompleted()) {
            writeln("Jobs are still running.");
            sleep(1);
        }
        
        var totalWaitTime = 0.0;
        var maxWaitTime = 0.0;
        
        for jobIndex in 0..(this.numJobs-1) {
            var job = this.jobs[jobIndex];
            totalWaitTime += job.getWaitTime();
            maxWaitTime = max(maxWaitTime, job.getWaitTime());
        }
        
        var avgWaitTime = totalWaitTime / this.numJobs;
        var hybridWaitTime = 2 * avgWaitTime + maxWaitTime;
        
        writeln("~~~~~~~~~~~~~~~~~~~~~~");
        writeln("Job stats calculated!");
        writeln(this.numJobs, " jobs completed!");
        writeln("Maximum wait time: ", maxWaitTime);
        writeln("Average wait time: ", avgWaitTime);
        writeln("Hybrid wait time (max + 2 x avg): ", hybridWaitTime);
        writeln("~~~~~~~~~~~~~~~~~~~~~~~");
        
        var stats : [0..2] real;
        stats = (maxWaitTime, avgWaitTime, hybridWaitTime);
        
        return stats[statIndex];
    }
    
} //end of JobGroup class

