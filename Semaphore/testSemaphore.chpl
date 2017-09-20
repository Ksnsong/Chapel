/*************************************
 * You can use this to test the Semaphore class you wrote in semaphore.chpl.
 *
 * Author: Kyle Burke <paithanq@gmail.com>
 * Usage: (for testing a semaphore with 7 tokens, being queried by 15 threads, each of which uses it for a max of 12 seconds.
 * $ ./a.out --k=7 --t=15 --m=12
 */

//you need to supply semaphore.chpl (in the same folder)
use semaphore;
use Time;
use Random;

//test the Semaphore!
config const t: int = 15; //numThreads
config const k : int = 3; //numTokens
config const m : int = 5; //maxTime

//rename these for clearer code below
var threads = t;
var numTokens = k;
var maxTime = m;

var rng = new NPBRandomStream();

var s = new Semaphore(tokens = numTokens);
//s.start();

//s.print();

forall i in 0..(threads-1) {
    writeln("Iteration ", i, " is ready for the semaphore.");
	s.p();
	var sleepTime = (rng.getNext() * maxTime);
	writeln("Iteration ", i, " is using the semaphore for ", sleepTime, " seconds...");
	//s.print();
	writeln("There are ", s.tokens, " tokens available. (after p)");
	sleep(sleepTime);
	writeln("Iteration ", i, " is done with the semaphore!");
	s.v();
	writeln("There are ", s.tokens, " tokens available. (after v)");
	sleep(2);
}
//s.waiting = 0;