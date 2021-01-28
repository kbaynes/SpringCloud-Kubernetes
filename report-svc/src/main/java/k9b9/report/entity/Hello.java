package k9b9.report.entity;

import javax.persistence.Entity;

@Entity
public class Hello {

  public String message;

  public Hello() {
  }

  public Hello(String message) {
    this.message = message;
  }

  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }

}
