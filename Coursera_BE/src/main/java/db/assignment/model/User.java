package db.assignment.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Entity
@Table(name = "[user]")
@Getter
@Setter
public class User {

    @Id
    private Integer id;

    @Column(name = "Email",nullable = false)
    @JsonProperty("email")
    private String email;

    @Column(name = "FName")
    @JsonProperty("fname")
    private String fName;

    @Column(name = "Lname")
    @JsonProperty("lname")
    private String lName;

    @Temporal(TemporalType.DATE)
    @Column(name = "Date_of_birth")
    @JsonProperty("dob")
    private Date dateOfBirth;

    @Column(name = "Username",nullable = false, unique = true)
    private String username;

    @Column(name = "Password",nullable = false)
    private String password;

    @Column(name = "Phone_number")
    @JsonProperty("phone")
    private String phoneNumber;
}
