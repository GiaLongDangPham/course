package db.assignment.controller;

import db.assignment.dto.request.SignInDTO;
import db.assignment.dto.response.ResponseData;
import db.assignment.dto.response.SignInResponse;
import db.assignment.service.AuthenticationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthenticationController {
    private final AuthenticationService authenticationService;

    @PostMapping("/login")
    public ResponseData<SignInResponse> login(@RequestBody SignInDTO request) {
        authenticationService.authenticate(request);

        SignInResponse response = new SignInResponse();
        response.setToken("DUMMY TOKEN");
        return ResponseData.<SignInResponse>builder()
                .result(response)
                .build();
    }
}
