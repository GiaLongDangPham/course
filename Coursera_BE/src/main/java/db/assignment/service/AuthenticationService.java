package db.assignment.service;

import db.assignment.dto.request.SignInDTO;
import db.assignment.exception.AppException;
import db.assignment.exception.ErrorCode;
import db.assignment.model.User;
import db.assignment.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthenticationService {
    private final UserRepository userRepository;

    public void authenticate(SignInDTO request) {
        User user = userRepository.findByUsername(request.getUsername());
        if (user == null || !user.getPassword().equals(request.getPassword())) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
    }
}
