package db.assignment.controller;

import db.assignment.dto.request.UserDTO;
import db.assignment.dto.response.ResponseData;
import db.assignment.dto.response.UserResponse;
import db.assignment.exception.AppException;
import db.assignment.model.User;
import db.assignment.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class UserController {
    private final UserService userService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping
    public ResponseData<List<UserResponse>> getAllUsers() {
        List<User> users = userService.getAllUsers();

        List<UserResponse> userResponses = users.stream().map(user -> {
            UserResponse response = new UserResponse();
            response.setId(user.getId());
            response.setEmail(user.getEmail());
            response.setFName(user.getFName());
            response.setLName(user.getLName());
            response.setDateOfBirth(user.getDateOfBirth());
            response.setUsername(user.getUsername());
            response.setPassword(user.getPassword());
            response.setPhoneNumber(user.getPhoneNumber());

            // Truy vấn danh sách địa chỉ từ bảng user_address
            List<String> addresses = jdbcTemplate.queryForList(
                    "SELECT User_addr FROM user_address WHERE User_id = ?",
                    String.class,
                    user.getId()
            );
            response.setAddresses(addresses);

            return response;
        }).toList();

        return ResponseData.<List<UserResponse>>builder()
                .code(HttpStatus.OK.value())
                .message("Fetched users successfully")
                .result(userResponses)
                .build();
    }

    @PostMapping
    public ResponseData<?> insertUser(@RequestBody UserDTO dto) throws AppException {
        userService.insertUserViaSP(dto);
        return ResponseData.builder()
                .code(HttpStatus.CREATED.value())
                .message("Insert user successfully")
                .build();
    }

    @PutMapping
    public ResponseData<?> updateUser(@RequestBody UserDTO dto) throws AppException {
        userService.updateUserViaSP(dto);
        return ResponseData.builder()
                .code(HttpStatus.ACCEPTED.value())
                .message("Update user successfully")
                .build();
    }

    @DeleteMapping("/{id}")
    public ResponseData<?> deleteUser(@PathVariable Integer id,
                                      @RequestParam(defaultValue = "false") boolean force) {
        userService.deleteUserViaSP(id, force);
        return ResponseData.builder()
                .code(HttpStatus.ACCEPTED.value())
                .message("Delete user successfully")
                .build();
    }

    @GetMapping("/{userId}/addresses")
    public List<String> getUserAddresses(@PathVariable("userId") int userId) {
        String sql = "SELECT User_addr FROM user_address WHERE User_id = ?";
        return jdbcTemplate.queryForList(sql, String.class, userId);
    }
}
