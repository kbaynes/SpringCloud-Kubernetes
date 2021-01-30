package k9b9.valid;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.function.Supplier;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.web.client.RestTemplate;

import k9b9.valid.type.Hello;
import lombok.extern.slf4j.Slf4j;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ActiveProfiles({ "test", "nojpa" })
@Slf4j
class HelloTest {

	@LocalServerPort
	private int port;

	@Autowired
	RestTemplate restTemplate;

	@Value("${spring.application.name}")
	String appName;

	void discoHelloTest(String serviceName) {
		Hello hello = this.restTemplate.getForObject("http://" + serviceName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", serviceName));
		System.out.println(hello.getMessage());
	}

	void loopedDiscoHelloTest(String serviceName, int loopCount) {
		if (loopCount < 1 || loopCount > 10)
			loopCount = 1;
		for (int i = 0; i < loopCount; i++) {
			discoHelloTest(serviceName);
		}
	}

	@Test
	void helloStress() {
		try {
			// CompletableFuture.delayedExecutor(delay, unit, executor)
			// String s = CompletableFuture.supplyAsync(() -> br.readLine()).get(1,
			// TimeUnit.SECONDS);
			String s = CompletableFuture.supplyAsync(new Supplier<String>() {

				@Override
				public String get() {
					return "hello";
				}

			}).get(1, TimeUnit.SECONDS);
			System.out.println(s);
		} catch (TimeoutException e) {
			System.out.println("Time out has occurred");
		} catch (InterruptedException | ExecutionException e) {
			// Handle
		}
	}

	@Test
	void helloSelfTest() {
		Hello hello = this.restTemplate.getForObject("http://localhost:" + port + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", this.appName));
		System.out.println(hello.getMessage());
	}

	@Test
	void helloSelfDiscoTest() {
		log.info("*** helloSelfDiscoTest ***");
		loopedDiscoHelloTest(this.appName, 3);
	}

	@Test
	void helloReportSvcDiscoTest() {
		log.info("*** helloReportSvcDiscoTest ***");
		String serviceName = "report-svc";
		loopedDiscoHelloTest(serviceName, 3);
	}

	@Test
	void helloValidSvcDiscoTest() {
		log.info("*** helloValidSvcDiscoTest ***");
		String serviceName = "valid-svc";
		loopedDiscoHelloTest(serviceName, 3);
	}

}
