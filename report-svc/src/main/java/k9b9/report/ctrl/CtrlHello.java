package k9b9.report.ctrl;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import k9b9.report.type.Hello;

@RestController
// servlet context is /report
@RequestMapping("/api")
public class CtrlHello {

  // String helloInstanceId = UUID.randomUUID().toString().substring(0, 5);

  @GetMapping("/hello")
  public Hello Hello(@Value("${spring.application.name}") String appName, @Value("${local.server.port}") String serverPort) {
    return new Hello(String.format("Hello from %s on port %s", appName, serverPort));
  }
}
