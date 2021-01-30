package k9b9.htxdbd;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.hystrix.dashboard.EnableHystrixDashboard;

@SpringBootApplication
@EnableHystrixDashboard
public class HtxdbdApp {

	public static void main(String[] args) {
		SpringApplication.run(HtxdbdApp.class, args);
	}

}
