package k9b9.ui;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class UiApp {

	public static void main(String[] args) {
		SpringApplication.run(UiApp.class, args);
	}

}
