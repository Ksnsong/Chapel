use Time;
use Random;
use semaphore;
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
	var mutex = new Semaphore(tokens = 1);	 			//exclusive access to the queue
	var items = new Semaphore(tokens = itemstokens);	//number of items in the queue
	var spaces = new Semaphore(tokens = spacestokens);	// number of empty spaces in the queue
	var tokensLock = new Semaphore(tokens = 1);	 		//for getting the tokens' values

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
		for i in 0..capacity-1 { 		//iterate through all the elements
			writeln( " This is No.", i, " element: ", elements[i] );
		}

	}
		
	proc add(newElement: eltType){
															if (debug) then writeln( "line 1 (add) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		//getTokens();
															if (debug) then writeln( "line 2 (add) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		spaces.p();											
															if (debug) then writeln( "line 2.5 (add)spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
											
															if (debug) then writeln( "line 3 (add) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		mutex.p(); 
															if (debug) then writeln( "line 4 (add) spaces tocken:", spaces.tokens, " item tokens: ", items.tokens);
		elements[rear] = newElement;
		rear = (rear+1)%capacity;
															if (debug) then writeln( "line 5 (add) spaces tocken:", spaces.tokens, " item tokens: ", items.tokens);
		mutex.v();
		//getTokens();													
															if (debug) then writeln( "line 6 (add) spaces tocken: ", spaces.tokens, " item tokens: ");
		items.v();
		//getTokens();
															if (debug) then writeln( "line 7 (add) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
	}	
		
	proc remove(){
															if (debug) then writeln( "line 1 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		//getTokens();
															if (debug) then writeln( "line 2 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		items.p();										    
															if (debug) then writeln( "line 2.5 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
											
															if (debug) then writeln( "line 3 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		mutex.p();
															if (debug) then writeln( "line 4 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		elements[front] = NULL;
		front = (front+1)%capacity;
															if (debug) then writeln( "line 5 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		mutex.v();
		//getTokens();													
															if (debug) then writeln( "line 6 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
		spaces.v();
		//getTokens();
															if (debug) then writeln( "line 7 (remove) spaces tocken: ", spaces.tokens, " item tokens: ", items.tokens);
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
