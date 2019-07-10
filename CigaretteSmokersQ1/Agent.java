import java.util.concurrent.*;

public class Agent extends Thread {
	Semaphore agentSem;
	Semaphore ingredientOne;
	Semaphore ingredientTwo;
	String agentName;

	public Agent(Semaphore agentSem, Semaphore ingredientOne, Semaphore ingredientTwo, String agentName) {
		super(agentName);
		this.agentSem = agentSem;
		this.ingredientOne = ingredientOne;
		this.ingredientTwo = ingredientTwo;
		this.agentName = agentName;
	}

	@Override
	public void run() {
		try {
			agentSem.acquire();
			ingredientOne.release();
			ingredientTwo.release();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

}
