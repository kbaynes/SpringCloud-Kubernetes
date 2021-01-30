package k9b9.gateway.ctrl;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CtrlFallback {

  String fbTemplate = "%s has exceeded the response timeout. Try again later.";
  
  @GetMapping("/validFallback")
  public String validFallback() {
    return String.format(fbTemplate, "Validation Service");
  }

  @GetMapping("/reportFallback")
  public String reportFallback() {
    return String.format(fbTemplate, "Report Service");
  }

  @GetMapping("/uiFallback")
  public String uiFallback() {
    return String.format(fbTemplate, "UI Service");
  }

  @GetMapping("/discoFallback")
  public String discoFallback() {
    return String.format(fbTemplate, "Discovery Service");
  }
}
