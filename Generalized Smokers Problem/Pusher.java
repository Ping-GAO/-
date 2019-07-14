import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;

public class Pusher extends Thread {

	Semaphore ingridentHold;
	Semaphore ingridentSemDontHold1;
	Semaphore ingridentSemDontHold2;

	Semaphore mutex;
	AtomicInteger First;
	AtomicInteger Second;
	AtomicInteger Third;

	String pusherName;

	public Pusher(Semaphore ingridentHold, Semaphore ingridentSemDontHold1, Semaphore ingridentSemDontHold2,
			Semaphore mutex, AtomicInteger First, AtomicInteger Second, AtomicInteger Third, String pusherName) {
		super(pusherName);
		this.ingridentHold = ingridentHold;
		this.ingridentSemDontHold1 = ingridentSemDontHold1;
		this.ingridentSemDontHold2 = ingridentSemDontHold2;

		this.First = First;
		this.Second = Second;
		this.Third = Third;
		this.mutex = mutex;
		this.pusherName = pusherName;
	}

	@Override
	public void run() {
		while (true) {
			try {

				ingridentHold.acquire();
				mutex.acquire();
				if (First.get() != 0) {
					First.getAndDecrement();
					ingridentSemDontHold2.release();
				} else if (Second.get() != 0) {
					Second.getAndDecrement();
					ingridentSemDontHold1.release();
				} else {

					Third.getAndIncrement();
				}
			} catch (InterruptedException e) {

				e.printStackTrace();
			}
			mutex.release();
		}

	}

}
