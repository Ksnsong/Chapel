use BlockingQueue;
use Time;
use Random;

config const s: int = 8; //size
config const m : int = 2; //maxTime
config const n : int = 5; //runTime
var capacity = s;
var maxTime = m;
var runTime = n;

var q = new BlockingQueue(int, s);
var rng = new NPBRandomStream();

		//writeln("items tokens(add): ", q.itemstokens);
		//writeln("free spaces tokens(add): ", q.spacestokens);
		writeln("items tokens:(add semaphore) ", q.items.tokens);
		writeln("free spaces tokens:(add semaphore) ", q.spaces.tokens);

for i in 0..(capacity-1){
	q.add((i+1)*5);
}
q.toString();
		writeln("items tokens:(add semaphore) ", q.items.tokens);
		writeln("free spaces tokens:(add semaphore) ", q.spaces.tokens);

		
cobegin{
	forall i in 0..n {
		var sleepTime = (rng.getNext() * maxTime);
		writeln("adding ", i);
		q.add(i+100);
		//sleep(sleepTime);
		q.toString();
		writeln("items tokens:(add semaphore) ", q.items.tokens);
		writeln("free spaces tokens:(add semaphore) ", q.spaces.tokens);
	}
	forall i in 0..n  {
		var sleepTime = (rng.getNext() * maxTime);
		writeln("removing ", i);
		q.remove();
		//sleep(sleepTime);
		q.toString();
		writeln("items tokens:(remove semaphore) ", q.items.tokens);
		writeln("free spaces tokens:(remove semaphore) ", q.spaces.tokens);
	}
}

q.toString();
writeln("items tokens:(remove semaphore) ", q.items.tokens);
writeln("free spaces tokens:(remove semaphore) ", q.spaces.tokens);
