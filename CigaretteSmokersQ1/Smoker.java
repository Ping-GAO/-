import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicBoolean;

public class Smoker extends Thread {

	Semaphore ingridenSemtHold;

	Semaphore agentSem;
	String holdItem;
	String smokerName;
	AtomicBoolean isTobacco;
	AtomicBoolean isPaper;
	AtomicBoolean isMatch;

	public Smoker(String holdItem, Semaphore ingridenSemtHold, Semaphore agentSem, AtomicBoolean isTobacco,
			AtomicBoolean isPaper, AtomicBoolean isMatch, String smokerName) {
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
		// the triple false is legit because if this is the smoker with tobacco he will
		// awaken by the other two pushers, look into the pusher code
		// he set the ingredients to false before signal the thread.
		// so it justify the two false, and the boolean only represent the ingredients
		// one the table given by the agent
		// the smoker with tobacco will always get a false, because he don't need that
		// he has his own tobacco
		System.out.println("three varible is " + isTobacco.get() + isPaper.get() + isMatch.get());

	};

	public void smoke() {
		System.out.println("Smoke the cigarette");
	}
}
