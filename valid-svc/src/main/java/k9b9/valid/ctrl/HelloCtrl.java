package k9b9.valid.ctrl;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import k9b9.valid.entity.Hello;

@RestController
@RequestMapping("/api")
public class HelloCtrl {

  @GetMapping("/hello")
  public Hello Hello(@Value("${service.name}") String serviceName) {
    return new Hello(String.format("Hello from %s", serviceName));
  }
}
