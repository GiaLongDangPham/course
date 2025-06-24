package db.assignment.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.Column;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
public class UserResponse {

    private Integer id;

    @JsonProperty("email")
    private String email;

    @JsonProperty("fname")
    private String fName;

    @JsonProperty("lname")
    private String lName;

    @JsonProperty("dob")
    private Date dateOfBirth;

    private String username;

    private String password;

    @JsonProperty("phone")
    private String phoneNumber;

    private List<String> addresses;
}
