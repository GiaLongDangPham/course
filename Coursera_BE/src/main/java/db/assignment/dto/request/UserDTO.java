package db.assignment.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.Date;

@Getter
@Setter
public class UserDTO {
    private Integer id;

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

    private String address1;

    private String address2;

    private String address3;
}
