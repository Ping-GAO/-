import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicBoolean;

public class CigaretteSmokers {
	public static void main(String[] args) throws InterruptedException {
		//System.out.println("Start");
		Semaphore agentSem = new Semaphore(1);
		Semaphore tobacco = new Semaphore(0);
		Semaphore paper = new Semaphore(0);
		Semaphore match = new Semaphore(0);

		Semaphore tobaccoSem = new Semaphore(0);
		Semaphore paperSem = new Semaphore(0);
		Semaphore matchSem = new Semaphore(0);

		final AtomicBoolean isTobacco = new AtomicBoolean(false);
		final AtomicBoolean isPaper = new AtomicBoolean(false);
		final AtomicBoolean isMatch = new AtomicBoolean(false);
		
		Semaphore mutex = new Semaphore(1);

		
		List<Agent>myagentSquard= new ArrayList<>();
		
		for(int i=0;i<2;i++) {
			myagentSquard.add(new Agent(agentSem, tobacco, paper, "A"));
			myagentSquard.add(new Agent(agentSem, paper, match, "B"));
			myagentSquard.add(new Agent(agentSem, tobacco, match, "C"));
			
		}
		Collections.shuffle(myagentSquard);
		
		for(Agent a : myagentSquard) {
			a.start();
		}
		

		Smoker A1 = new Smoker("tobacco",tobaccoSem, agentSem, isTobacco, isPaper, isMatch, "A1");
		Smoker B1 = new Smoker("paper",paperSem, agentSem,isTobacco, isPaper, isMatch, "B1");
		Smoker C1 = new Smoker("match",matchSem, agentSem, isTobacco, isPaper, isMatch,"C1");

		Pusher A2 = new Pusher(tobacco, paperSem, matchSem, mutex, isPaper, isMatch, isTobacco,"A2");
		Pusher B2 = new Pusher(paper, matchSem, tobaccoSem, mutex, isMatch, isTobacco, isPaper,"B2");
		Pusher C2 = new Pusher(match, tobaccoSem, paperSem, mutex,isTobacco, isPaper, isMatch, "C2");

		A1.start();
		B1.start();
		C1.start();
		
		A2.start();
		B2.start();
		C2.start();

		
		//System.out.println("The End.");
	}

}
