/**
 * Models a Job for a CPU.
 *
 * @author Kyle Burke <paithanq@gmail.com>
 */
use Time;


class Job {

    var timer: Timer;
    
    var length : real;
    
    var waitTime : real;
    
    var latency : real;
    
    var isFinished : bool;
    
    proc Job(jobLength : real) {
        this.timer = new Timer();
        this.timer.start();
        this.length = jobLength;
        this.isFinished = false;
        //writeln("Just created job with length: " + this.length + " seconds!");
    }
    
    proc getLength() {
        return length;
    }
    
    //the process stops waiting and starts running!
    proc startRunning() {
        waitTime = this.timer.elapsed();
    }
    
    //the process stops running.
    proc stopRunning() {
        latency = this.timer.elapsed();
        this.isFinished = true;
        /*  Took this out because it was causing problems!
        sleep(.1);
        try {
            this.timer.stop();
        } catch {
            writeln("Timer couldn't stop!  elapsed time: " + timer.elapsed + "!!!!!!!!!!!");
        }*/
    }
    
    proc isDone() : bool {
        return this.isFinished;
    }
    
    proc getWaitTime() : real {
        return waitTime;
    }
    
    proc getLatency() : real {
        return latency;
    }
    
    proc writeThis(writer) {
        writer.writef("Job: " + this.getLength());
    }  
    
    proc isSentinel() : bool {
        return false;
    } 
}

/**
 * TODO: Learn to do subclasses, then finish this class.
class SentinelJob {
    proc isSentinel() : bool {
        return true;
    }
}
*/