package k9b9.report;

import java.util.UUID;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication
@EnableDiscoveryClient
public class ReportApp {

	public static void main(String[] args) {
		ConfigurableApplicationContext context = SpringApplication.run(ReportApp.class, args);
		context.getEnvironment().getSystemProperties().put("app.instance.id", UUID.randomUUID().toString().substring(0, 5));
	}

}
