package k9b9.ui.ctrl;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HelloCtrl {
  
  @GetMapping(value="/hello", produces = MediaType.TEXT_PLAIN_VALUE)
  public ResponseEntity<String> Hello(@Value("${service.name}") String serviceName) {
    return new ResponseEntity<String>(String.format("Hello from %s", serviceName), HttpStatus.OK);
  }
}
