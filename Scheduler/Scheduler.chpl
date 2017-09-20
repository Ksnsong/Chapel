use Time;
use Random;
use Semaphore;
use BlockingQueue;
use Job;
use CPU;
class Scheduler{
	var debug: bool = false;	//debug

	var queueCapacity: int = 0;
	var outputQueue: BlockingQueue(Job);
	var jobsDomain: domain(1);
	var jobs : [jobsDomain] Job;
	var mode : string;
	var isActive : bool = false;
	
	
	var numCPUs :int = 1;
	var activeRun = new Semaphore(1);
	var exclusiveLock = new Semaphore(1);
	
	//var jobCount : int = 0;
	var queueJobCount : int = 0;
	var sizeOfJobArray: int = 0;
	
	var checkRemove : int = 0;
	var loopCount: int =0;
	var queueRare: int = 0;
	
	proc Scheduler(mode : string) {
    //you'll initialize the fields here
		this.queueCapacity;
		this.outputQueue;
		this.jobs;
		this.jobsDomain = {0..sizeOfJobArray};
		this.mode = mode;
		this.numCPUs;
		begin run(); 
	}
	
	proc run() {
		while(1){
			//They are all FCFS
			if (this.mode == "maximum") then maximum();
			if (this.mode == "average") then average();
			if (this.mode == "hybrid") then hybrid();
		}
	}
	
	proc maximum(){
		//when we have free space in the queue and jobs left 
		if ((queueJobCount != sizeOfJobArray) && outputQueue.getNumElements() != queueCapacity){
			activeRun.p();
			queueRare = outputQueue.rear;
			this.outputQueue.add(this.jobs[this.queueJobCount]);
			if (queueRare != outputQueue.rear){
				queueJobCount += 1;
			} 
			activeRun.v();
		}
		//there's chance that queueJobCount catch up after the first around size
		else if (this.queueJobCount > 0){
			//make sure we won't call run() after blocking queue remove the last job
			if (outputQueue.getNumElements() == 0 && queueJobCount != sizeOfJobArray) then run();
			else sleep(.1);
		}
	}
	
	proc average(){
		//when we have free space in the queue and jobs left 
		if ((queueJobCount != sizeOfJobArray) && outputQueue.getNumElements() != queueCapacity){
			activeRun.p();
			queueRare = outputQueue.rear;
			this.outputQueue.add(this.jobs[this.queueJobCount]);
			if (queueRare != outputQueue.rear){
				queueJobCount += 1;
				if (debug) then writeln("queue count: ", queueJobCount );
				if (debug) then writeln("Job count: ", sizeOfJobArray );
				if (debug) then writeln("We have ", outputQueue.getNumElements(), " things in the queue");
			} 
			if (debug) then writeln( "job list in scheduler: ", sizeOfJobArray,"   ", jobs);
			activeRun.v();
		}
		//there's chance that queueJobCount catch up after the first around size
		else if (this.queueJobCount > 0){
			//make sure we won't call run() after blocking queue remove the last job
			if (outputQueue.getNumElements() == 0 && queueJobCount != sizeOfJobArray) then run();
			else sleep(.1);
		}
	}
	
	proc hybrid(){
		//when we have free space in the queue and jobs left 
		if ((queueJobCount != sizeOfJobArray) && outputQueue.getNumElements() != queueCapacity){
			activeRun.p();
			queueRare = outputQueue.rear;
			this.outputQueue.add(this.jobs[this.queueJobCount]);
			if (queueRare != outputQueue.rear){
				queueJobCount += 1;
			} 
			activeRun.v();
		}
		//there's chance that queueJobCount catch up after the first around size
		else if (this.queueJobCount > 0){
			//make sure it won't call run() after blocking queue remove the last job
			if (outputQueue.getNumElements() == 0 && queueJobCount != sizeOfJobArray) then run();
			else sleep(.1);
		}
	}
	
	
	proc getOutputQueueCapacity(numCPUs : int) : int{
		this.numCPUs = numCPUs;
		if (numCPUs == 1) then this.queueCapacity = 8*numCPUs;
		else this.queueCapacity = 4 + 2*numCPUs;
		writeln("I am set size of the queue! It is ", queueCapacity);
		return this.queueCapacity;
	}
	
	proc setOutputQueue(queue : (new BlockingQueue(Job,queueCapacity))){
		this.outputQueue = queue;
		writeln("I am set output queue!");
	}
	
	proc addJob(job : Job){
		//writeln("top of add");
		exclusiveLock.p();
		this.jobsDomain = {0..sizeOfJobArray};
		//writeln("about add");
		this.jobs[sizeOfJobArray] = job;
		this.sizeOfJobArray += 1; 
		//writeln("I am add");
		exclusiveLock.v();
	}
}