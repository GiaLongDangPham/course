package db.assignment.dto.request;

import lombok.Getter;
import lombok.Setter;
import org.springframework.web.bind.annotation.RequestParam;

@Getter
@Setter
public class SignInDTO {
    private String username;
    private String password;
}
