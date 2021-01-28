package k9b9.ui;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

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
		ResponseEntity<String> resp = this.restTemplate.getForEntity("http://localhost:" + port + "/hello",String.class);
		Assertions.assertThat(resp).isNotNull();
    Assertions.assertThat(resp.getBody()).contains(String.format("Hello from %s", this.serviceName));
    System.out.println(resp.getBody());
	}

}
