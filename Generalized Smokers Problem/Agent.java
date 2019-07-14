import java.util.concurrent.*;

public class Agent extends Thread {
	Semaphore agentSem;
	Semaphore ingredientOne;
	Semaphore ingredientTwo;
	int seedForIngredient1;
	int seedforIngredient2;
	String agentName;

	public Agent(Semaphore agentSem, Semaphore ingredientOne, Semaphore ingredientTwo, int seedForIngredient1,
			int seedforIngredient2, String agentName) {
		super(agentName);
		this.agentSem = agentSem;
		this.ingredientOne = ingredientOne;
		this.ingredientTwo = ingredientTwo;
		this.seedForIngredient1 = seedForIngredient1;
		this.seedForIngredient1 = seedforIngredient2;
		this.agentName = agentName;
	}

	@Override
	public void run() {
		try {
			agentSem.acquire();
			ingredientOne.release();
			// release multiple of each resources
			for (int i = 0; i < seedForIngredient1; i++) {
				ingredientOne.release();
			}
			for (int i = 0; i < seedForIngredient1; i++) {
				ingredientTwo.release();
			}

			ingredientTwo.release();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

}
