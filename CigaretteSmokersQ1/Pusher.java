import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicBoolean;

public class Pusher extends Thread {

	Semaphore ingridentHold;
	Semaphore ingridentSemDontHold1;
	Semaphore ingridentSemDontHold2;
	Semaphore mutex;
	AtomicBoolean isFirst;
	AtomicBoolean isSecond;
	AtomicBoolean isThrird;

	String pusherName;

	public Pusher(Semaphore ingridentHold, Semaphore ingridentSemDontHold1, Semaphore ingridentSemDontHold2,
			Semaphore mutex, AtomicBoolean isFirst, AtomicBoolean isSecond, AtomicBoolean isThrird, String pusherName) {
		super(pusherName);
		this.ingridentHold = ingridentHold;
		this.ingridentSemDontHold1 = ingridentSemDontHold1;
		this.ingridentSemDontHold2 = ingridentSemDontHold2;
		this.isFirst = isFirst;
		this.isSecond = isSecond;
		this.isThrird = isThrird;
		this.mutex = mutex;
		this.pusherName = pusherName;
	}

	@Override
	public void run() {
		while (true) {
			try {
				ingridentHold.acquire();
				mutex.acquire();
				if (isFirst.compareAndSet(true, false)) {
					ingridentSemDontHold2.release();
				} else if (isSecond.compareAndSet(true, false)) {

					ingridentSemDontHold1.release();

				} else {
					isThrird.getAndSet(true);

				}

			} catch (InterruptedException e) {

				e.printStackTrace();
			}
			mutex.release();
		}

	}

}