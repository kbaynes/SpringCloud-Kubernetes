package k9b9.valid.ctrl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import k9b9.valid.type.Hello;

@RestController
// servlet context is /valid
@RequestMapping("/api")
@RefreshScope
public class CtrlHello {

  @Autowired
  RestTemplate restTemplate;

  @GetMapping("/hello")
  public Hello Hello(@Value("${spring.application.name}") String appName, @Value("${local.server.port}") String serverPort, @Value("${test.docker.bootstrap.value:ValueMissing}") String value) {
    return new Hello(String.format("Hello from %s on port %s '%s'", appName, serverPort, value));
  }

  /**
   * Calls the given service using it's name, as found by discovery service
   * @param serviceName
   * @return
   */
  @GetMapping("/hello-disco/{service-name}")
  public Hello helloDisco(@PathVariable("service-name") String serviceName) {
    Hello hello = this.restTemplate.getForObject(String.format("http://%s/api/hello",serviceName), Hello.class);
    System.out.println(hello.getMessage());
    return hello;
  }
}
