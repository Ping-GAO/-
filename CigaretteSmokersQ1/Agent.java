
/*
  Finally, you might want to think about what the value of the semaphore
 means. If the value is positive, then it represents the number of threads that
 can decrement without blocking. If it is negative, then it represents the number
 of threads that have blocked and are waiting. If the value is zero, it means there
 are no threads waiting, but if a thread tries to decrement, it will block.
*/

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
			// System.out.println("Agent code");

		} catch (InterruptedException e) {

			e.printStackTrace();
		}

		
		//System.out.println("end of agent code");
	}

}
