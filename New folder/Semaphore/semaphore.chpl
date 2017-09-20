use Time;
class Semaphore{
        var gateOne$: sync bool;
        var gate$: sync bool;
        var tokens: int = 6;
        var tokensMax = tokens;
        proc p(){
			gate$ = true;
			if (tokensMax == 0){
				var sub = gate$;
				gateOne$ = true;
				p();
			}
			else if (tokens == 1){
				tokens = tokens -1;
				var sub = gate$;
				gateOne$ = true;
			}
			else if ( tokens > 0 ) {	
				tokens = tokens -1;					
				if ( tokens == 0 ){	
					var sub = gate$;
					gateOne$ = true;
				}
				else if (tokens > 0){
					var sub = gate$;
				}
				
			}
			else if ( tokens == 0 ){
					var sub = gate$;
					gateOne$ = true;
			}
        }
        proc v(){
			if ( tokens == 0 ) {
				var sub1 = gateOne$;
				tokens = tokens +1;
			}
			else if ( tokens == tokensMax ) {
				var sub = gateOne$;
			}
			else if ( tokens < tokensMax ) {
				tokens = tokens +1;
			}
        }
}