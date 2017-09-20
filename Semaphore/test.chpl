use Time;
var lock: sync bool = true; //the sync variable
forall i in 1..10 {
    writeln("Iteration ", i, " requesting the semaphore...");
    var unlock = lock;
    writeln("Iteration ", i, " has the semaphore...");
    sleep(2);
    writeln("Iteration ", i, " is done with the semaphore!");
    
	lock = true; 
}
writeln("All iterations finished!");