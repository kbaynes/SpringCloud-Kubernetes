package k9b9.valid;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import k9b9.valid.entity.Hello;

import org.assertj.core.api.Assertions;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ActiveProfiles("NO_JPA")
class HelloTest {

	@LocalServerPort
	private int port;

	@Autowired 
	TestRestTemplate restTemplate;

	@Value("${service.name}") 
	String serviceName;

	@Test
	void helloTest() {
		Hello hello = this.restTemplate.getForObject("http://localhost:" + port + "/api/hello", Hello.class);
		Assertions.assertThat(hello).isNotNull();
    Assertions.assertThat(hello.getMessage()).contains(String.format("Hello from %s", this.serviceName));
    System.out.println(hello.getMessage());
	}

}
