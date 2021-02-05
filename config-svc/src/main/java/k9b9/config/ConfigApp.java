package k9b9.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
@EnableConfigServer
public class ConfigApp {

	@Autowired
	private Environment environment;
	
	public static void main(String[] args) {
		SpringApplication.run(ConfigApp.class, args);
	}

	@RequestMapping("/")
	public String query(@RequestParam("q") String q) {
		return this.environment.getProperty(q);
	}

}
