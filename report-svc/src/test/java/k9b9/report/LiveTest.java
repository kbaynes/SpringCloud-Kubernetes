package k9b9.report;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestTemplate;

import k9b9.report.type.Hello;

/**
 * Tests locally running servers on the default ports. Is not connected to
 * Discovery Service, does not run the Spring app.
 * RestTemplate is not Discovery aware.
 */
class LiveTest {

	int gatewaySvcPort = 8080;
	int uiSvcPort = 8082;
	int reportSvcPort = 8084;
	int validSvcPort = 8086;
	int htxdbdSvc = 8088;
	int configSvc = 8090;
	int discoSvcPort = 8761;

	RestTemplate restTemplate = new RestTemplate();

	@Test
	void helloSelfTest() {
		Hello hello = this.restTemplate.getForObject("http://localhost:" + reportSvcPort + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		System.out.println(hello.getMessage());
	}

	/**
	 * Depends on the valid-svc to be running locally
	 */
	@Test
	void helloValidSvcTest() {
		Hello hello = this.restTemplate.getForObject("http://localhost:" + validSvcPort + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		System.out.println(hello.getMessage());
	}

	/**
	 * Depends on the valid-svc to be running locally Call valid-svc (via
	 * localhost:8082) to call the valid-svc using discovery name.
	 */
	@Test
	void helloDiscoValidSvcTest() {
		Hello hello = this.restTemplate.getForObject("http://localhost:" + validSvcPort + "/api/hello-disco/valid-svc",
				Hello.class);
		Assertions.assertThat(hello).isNotNull();
		System.out.println(hello.getMessage());
	}

}
