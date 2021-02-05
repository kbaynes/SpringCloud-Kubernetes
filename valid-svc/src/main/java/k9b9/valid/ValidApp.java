package k9b9.valid;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ValidApp {

	public static void main(String[] args) {
		SpringApplication.run(ValidApp.class, args);
	}

}
