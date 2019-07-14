import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.Random;

public class GeneralizedSmokers {
	public static void main(String[] args) throws InterruptedException {
		
		Semaphore agentSem = new Semaphore(1);
		Random rand = new Random();
		
		// restrict the range to 1 to 5
		// which means max case the agent hand out 5 of each ingredients to 3 smokers
		int tobaccoSeed = rand.nextInt(5)+1;
		int paperSeed = rand.nextInt(5)+1;
		int matchSeed = rand.nextInt(5)+1;
		
		// semaphore for ingredient on the table 
		Semaphore tobacco = new Semaphore(tobaccoSeed);
		Semaphore paper = new Semaphore(paperSeed);
		Semaphore match = new Semaphore(matchSeed);

		// semaphore for the pusher
		Semaphore tobaccoSem = new Semaphore(0);
		Semaphore paperSem = new Semaphore(0);
		Semaphore matchSem = new Semaphore(0);

		final AtomicInteger numTobacco = new AtomicInteger(0);
		final AtomicInteger numPaper = new AtomicInteger(0);
		final AtomicInteger numMatch = new AtomicInteger(0);

		Semaphore mutex = new Semaphore(1);

		//-------------------------------
		// try to simulate random
		List<Agent> myagentSquard = new ArrayList<>();

		for (int i = 0; i < 2; i++) {
			myagentSquard.add(new Agent(agentSem, tobacco, paper,tobaccoSeed,paperSeed, "A"));
			myagentSquard.add(new Agent(agentSem, paper, match,paperSeed,matchSeed ,"B"));
			myagentSquard.add(new Agent(agentSem, tobacco, match,tobaccoSeed,matchSeed, "C"));

		}
		Collections.shuffle(myagentSquard);

		for (Agent a : myagentSquard) {
			a.start();
		}
		// ---------------------------------

		Smoker A1 = new Smoker("tobacco", tobaccoSem, agentSem, numTobacco, numPaper, numMatch, "A1");
		Smoker B1 = new Smoker("paper", paperSem, agentSem, numTobacco, numPaper, numMatch, "B1");
		Smoker C1 = new Smoker("match", matchSem, agentSem, numTobacco, numPaper, numMatch, "C1");

		Pusher A2 = new Pusher(tobacco, paperSem, matchSem, mutex, numPaper, numMatch, numTobacco, "A2");
		Pusher B2 = new Pusher(paper, matchSem, tobaccoSem, mutex, numMatch, numTobacco, numPaper, "B2");
		Pusher C2 = new Pusher(match, tobaccoSem, paperSem, mutex, numTobacco, numPaper, numMatch, "C2");

		A1.start();
		B1.start();
		C1.start();

		A2.start();
		B2.start();
		C2.start();

	}

}
