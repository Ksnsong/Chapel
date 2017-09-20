use Time;
use Random;
use Semaphore;
class BlockingQueue{
	//debug
	var debug: bool = false;

	//create type
	type eltType;
	var capacity: int;
	var numElements: int;
	var elementsDomain: domain(1);
	var elements: [elementsDomain] eltType;

	//circular queue
	var front: int = 0;
	var rear: int  = 0;

	var NULL: eltType; //Null

	//tokens for producers and consumers
	var itemstokens:  int = 1;
	var spacestokens: int = 1;
	// semaphores
	var mutex = new Semaphore(1);	 			//exclusive access to the queue
	var items = new Semaphore(itemstokens);		//number of items in the queue
	var spaces = new Semaphore(spacestokens);	// number of empty spaces in the queue
	var tokensLock = new Semaphore(1);	 		//for getting the tokens' values

	proc BlockingQueue(type eltType, size: int){
		capacity = size;
		elementsDomain = {0..capacity-1};
		spacestokens = size;
		getTokens();
	}

	proc getNumElements(){				// how many things in the queue
		var number: int = 0;
		for i in 0..capacity-1 {
			if (elements[i] != NULL){
				number += 1;
			}
		}
		return number;
	}
		
	proc toString(){
		var s: string = "";
		for i in 0..capacity-1 { 		//iterate through all the elements
			if (elements[i] != NULL){
				var E = elements[i];
				//writeln(i,": ",E);
				s += "%s".format(E: string)+ "\n";
			}
			else s += "";
		}
		return s;
	}
	
	proc getElement(num : int){
        return elements[num];
    }
	
	proc add(newElement: eltType){
		spaces.p();
		mutex.p(); 
		elements[rear] = newElement;
		rear = (rear+1)%capacity;
		mutex.v();
		items.v();
	}	
		
	proc remove(){
			
															if (debug) then writeln("BlockingQueue: top of remove");
												
		items.p();	
															if (debug) then writeln("BlockingQueue: inside the items p()");
		mutex.p();
															if (debug) then writeln("BlockingQueue: inside the mutex");
		var item : eltType;
		item = elements[front]; 
		elements[front] = NULL;
		front = (front+1)%capacity;
		mutex.v();
		spaces.v();
															if (debug) then writeln("BlockingQueue: return item", item);
																
		return item;
	}
	proc getTokens(){
		tokensLock.p();
		itemstokens = getNumElements();
		spacestokens = capacity - getNumElements();
		items.tokens = itemstokens;
		spaces.tokens = spacestokens;
		tokensLock.v();
	}
}
