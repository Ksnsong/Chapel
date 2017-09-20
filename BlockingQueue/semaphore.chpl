use Time;
class Semaphore{
        var gateOne$: sync bool;
        var gate$: sync bool;
        var tokens: int = 6;
		var count: int = 0;
        proc p(){
			gate$ = true;
			if (tokens == 1){
				tokens = tokens -1;
				count += 1;
				gateOne$ = true;
				var sub = gate$;
			}
			else if ( tokens > 0 ) {	
				tokens = tokens -1;					
				var sub = gate$;
			}
			else if (tokens <= 0){	
				var sub = gate$;
				gateOne$ = true;
				var sub1 = gateOne$;
				p();
			}
        }
        proc v(){
			gate$ = true;
			if (tokens == 0){
				tokens += 1;
				if (count > 0) then var sub1 = gateOne$;
			}
			else{
				tokens += 1;
			}
			var sub = gate$;
        }
}
