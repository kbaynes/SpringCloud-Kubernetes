package k9b9.report;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import k9b9.report.type.Hello;

import org.assertj.core.api.Assertions;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ActiveProfiles("nojpa")
class HelloTest {

	@LocalServerPort
	private int port;

	@Autowired 
	TestRestTemplate restTemplate;

	@Value("${spring.application.name}") 
	String appName;

	@Test
	void helloTest() {
		Hello hello = this.restTemplate.getForObject("http://localhost:" + port + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
    Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", this.appName));
    System.out.println(hello.getMessage());
	}

}
