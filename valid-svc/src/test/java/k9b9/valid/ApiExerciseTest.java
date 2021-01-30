package k9b9.valid;

import java.io.IOException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import org.assertj.core.api.Assertions;
import org.springframework.web.client.RestTemplate;

/**
 * Run via the VS Code Runner (run button on main method)
 */
class ApiExerciseTest {

	static RestTemplate restTemplate;

	ApiExerciseTest() {
		ApiExerciseTest.restTemplate = new RestTemplate();
	}

	public static void main(String[] args) throws IOException {
		ApiExerciseTest test = new ApiExerciseTest();
		test.run();
	}

	Runnable buildRunnable(String hostName, String hostPort, String apiPath) {
		return new Runnable() {
			public void run() {
				String s = ApiExerciseTest.restTemplate.getForObject(String.format("http://%s:%s/%s", hostName, hostPort, apiPath),
						String.class);
				Assertions.assertThat(s).isNotNull();
				System.out.println(s);
			}
		};
	}

	/**
	 * Build and execute runnable which call api endpoints on intervals. Exercises the simple API endpoints.
	 * @throws IOException
	 */
	void run() throws IOException {

		String hostName = "localhost";
		String hostPort = "8080";
		ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

		ScheduledFuture<?> a = scheduler.scheduleAtFixedRate(
			buildRunnable(hostName, hostPort, "valid/api/hello"), 100, 1000, TimeUnit.MILLISECONDS);

		ScheduledFuture<?> aa = scheduler.scheduleAtFixedRate(
			buildRunnable(hostName, hostPort, "valid/actuator/health"), 150, 1000, TimeUnit.MILLISECONDS);

		ScheduledFuture<?> b = scheduler.scheduleAtFixedRate(
			buildRunnable(hostName, hostPort, "report/api/hello"), 200, 1000, TimeUnit.MILLISECONDS);

		ScheduledFuture<?> bb = scheduler.scheduleAtFixedRate(
			buildRunnable(hostName, hostPort, "report/actuator/health"), 250, 1000, TimeUnit.MILLISECONDS);

		ScheduledFuture<?> c = scheduler.scheduleAtFixedRate(
			buildRunnable(hostName, hostPort, "ui/hello"), 300, 1000, TimeUnit.MILLISECONDS);

		ScheduledFuture<?> cc = scheduler.scheduleAtFixedRate(
			buildRunnable(hostName, hostPort, "ui/actuator/health"), 350, 1000, TimeUnit.MILLISECONDS);

		ScheduledFuture<?> d = scheduler.scheduleAtFixedRate(
			buildRunnable(hostName, hostPort, "actuator/health"), 400, 1000, TimeUnit.MILLISECONDS);

		// valid, report and ui all have hello and health
		// config: no hello, health direct only not via gateway
		// disco: no hello, health direct only not via gateway
		// gateway: no hello, health is /actuator/health
		// hystrix: no hello, no actuator

		scheduler.schedule(new Runnable() {
			public void run() {
				a.cancel(true);
				aa.cancel(true);
				b.cancel(true);
				bb.cancel(true);
				c.cancel(true);
				cc.cancel(true);
				d.cancel(true);
			}
		}, 2, TimeUnit.MINUTES);
	}

}
