import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;

public class Smoker extends Thread {

	Semaphore ingridenSemtHold;

	Semaphore agentSem;
	String holdItem;
	String smokerName;
	AtomicInteger isTobacco;
	AtomicInteger isPaper;
	AtomicInteger isMatch;

	public Smoker(String holdItem, Semaphore ingridenSemtHold, Semaphore agentSem, AtomicInteger isTobacco,
			AtomicInteger isPaper, AtomicInteger isMatch, String smokerName) {
		super(smokerName);

		this.ingridenSemtHold = ingridenSemtHold;
		this.isMatch = isMatch;
		this.isPaper = isPaper;
		this.isTobacco = isTobacco;
		this.smokerName = smokerName;
		this.agentSem = agentSem;
		this.holdItem = holdItem;
	}

	@Override
	public void run() {
		while (true) {
			try {

				ingridenSemtHold.acquire();
				makeCigarette();
				agentSem.release();
				smoke();

			} catch (InterruptedException e) {

				e.printStackTrace();
			}
		}

	}

	public void makeCigarette() {

		System.out.println("make Cigarette with his " + holdItem);

	};

	public void smoke() {
		System.out.println("Smoke the cigarette");
	}
}
