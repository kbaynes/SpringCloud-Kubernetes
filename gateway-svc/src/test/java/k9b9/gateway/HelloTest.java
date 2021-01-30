package k9b9.gateway;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.web.client.RestTemplate;

import k9b9.gateway.type.Hello;
import lombok.extern.slf4j.Slf4j;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ActiveProfiles({ "test" })
@Slf4j
class HelloTest {

	@LocalServerPort
	private int port;

	@Autowired
	RestTemplate restTemplate;

	@Value("${spring.application.name}")
	String appName;

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
		Hello hello = this.restTemplate.getForObject("http://" + this.appName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", this.appName));
		System.out.println(hello.getMessage());
		hello = this.restTemplate.getForObject("http://" + this.appName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", this.appName));
		System.out.println(hello.getMessage());
		hello = this.restTemplate.getForObject("http://" + this.appName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", this.appName));
		System.out.println(hello.getMessage());
	}

	@Test
	void helloReportSvcDiscoTest() {
		log.info("*** helloReportSvcDiscoTest ***");
		String serviceName = "report-svc";
		Hello hello = this.restTemplate.getForObject("http://" + serviceName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", serviceName));
		System.out.println(hello.getMessage());
		hello = this.restTemplate.getForObject("http://" + serviceName+ "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", serviceName));
		System.out.println(hello.getMessage());
		hello = this.restTemplate.getForObject("http://" + serviceName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", serviceName));
		System.out.println(hello.getMessage());
	}

	@Test
	void helloValidSvcDiscoTest() {
		log.info("*** helloValidSvcDiscoTest ***");
		String serviceName = "valid-svc";
		Hello hello = this.restTemplate.getForObject("http://" + serviceName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", serviceName));
		System.out.println(hello.getMessage());
		hello = this.restTemplate.getForObject("http://" + serviceName+ "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", serviceName));
		System.out.println(hello.getMessage());
		hello = this.restTemplate.getForObject("http://" + serviceName + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
		Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", serviceName));
		System.out.println(hello.getMessage());
	}

}
