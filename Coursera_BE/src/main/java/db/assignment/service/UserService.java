package db.assignment.service;

import db.assignment.dto.request.UserDTO;
import db.assignment.exception.AppException;
import db.assignment.exception.ErrorCode;
import db.assignment.model.User;
import db.assignment.repository.UserRepository;
import jakarta.persistence.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @Transactional
    public void insertUserViaSP(UserDTO dto) throws AppException {

        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_InsertUser");

        // Đăng ký parameters
        query.registerStoredProcedureParameter("id", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Email", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("FName", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("LName", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Date_of_birth", Date.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Username", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Password", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Phone_number", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Address1", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Address2", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Address3", String.class, ParameterMode.IN);

        // Thiết lập giá trị parameters
        query.setParameter("id", dto.getId());
        query.setParameter("Email", dto.getEmail());
        query.setParameter("FName", dto.getFName());
        query.setParameter("LName", dto.getLName());
        query.setParameter("Date_of_birth", dto.getDateOfBirth());
        query.setParameter("Username", dto.getUsername());
        query.setParameter("Password", dto.getPassword());
        query.setParameter("Phone_number", dto.getPhoneNumber());
        query.setParameter("Address1", dto.getAddress1());
        query.setParameter("Address2", dto.getAddress2());
        query.setParameter("Address3", dto.getAddress3());

        try {
            query.execute();
        }
        catch (PersistenceException e) {
            String message = e.getMessage();

            // Map thông điệp từ SQL sang ErrorCode cụ thể
            if (message.contains("User ID cannot be null")) {
                throw new AppException(ErrorCode.USER_ID_NULL);
            } else if (message.contains("Email cannot be null")) {
                throw new AppException(ErrorCode.EMAIL_NULL);
            } else if (message.contains("Username cannot be null")) {
                throw new AppException(ErrorCode.USERNAME_NULL);
            } else if (message.contains("Password cannot be null")) {
                throw new AppException(ErrorCode.PASSWORD_NULL);
            } else if (message.contains("User with ID") && message.contains("already exists")) {
                throw new AppException(ErrorCode.USER_ID_EXISTED);
            } else if (message.contains("is already taken")) {
                throw new AppException(ErrorCode.USERNAME_EXISTED);
            } else if (message.contains("Invalid email format")) {
                throw new AppException(ErrorCode.EMAIL_INVALID);
            } else if (message.contains("Password must be at least 8 characters")) {
                throw new AppException(ErrorCode.PASSWORD_TOO_SHORT);
            } else if (message.contains("User must be at least 13 years old")) {
                throw new AppException(ErrorCode.USER_TOO_YOUNG);
            } else {
                throw new AppException(ErrorCode.DATABASE_ERROR); // fallback
            }
        }
    }

    @Transactional
    public void updateUserViaSP(UserDTO dto) throws AppException {
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_UpdateUser");

        // Đăng ký parameter
        query.registerStoredProcedureParameter("id", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Email", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("FName", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("LName", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Date_of_birth", Date.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Username", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Password", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Phone_number", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Address1", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Address2", String.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("Address3", String.class, ParameterMode.IN);

        // Thiết lập giá trị parameters
        query.setParameter("id", dto.getId());
        query.setParameter("Email", dto.getEmail());
        query.setParameter("FName", dto.getFName());
        query.setParameter("LName", dto.getLName());
        query.setParameter("Date_of_birth", dto.getDateOfBirth());
        query.setParameter("Username", dto.getUsername());
        query.setParameter("Password", dto.getPassword());
        query.setParameter("Phone_number", dto.getPhoneNumber());
        query.setParameter("Address1", dto.getAddress1());
        query.setParameter("Address2", dto.getAddress2());
        query.setParameter("Address3", dto.getAddress3());

        try {
            query.execute();
        } catch (PersistenceException e) {
            String message = e.getMessage();

            // Mapping lỗi tương tự insert
            if (message.contains("does not exist")) {
                throw new AppException(ErrorCode.USER_ID_NOT_EXISTED);
            } else if (message.contains("already taken")) {
                throw new AppException(ErrorCode.USERNAME_EXISTED);
            } else if (message.contains("Invalid email format")) {
                throw new AppException(ErrorCode.EMAIL_INVALID);
            } else if (message.contains("Password must be at least 8 characters")) {
                throw new AppException(ErrorCode.PASSWORD_TOO_SHORT);
            } else if (message.contains("User must be at least 13 years old")) {
                throw new AppException(ErrorCode.USER_TOO_YOUNG);
            } else {
                throw new AppException(ErrorCode.DATABASE_ERROR);
            }
        }
    }

    @Transactional
    public void deleteUserViaSP(Integer id, boolean force) throws AppException {
        if(id == null) throw new AppException(ErrorCode.USER_ID_NULL);
        StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_DeleteUser");
        query.registerStoredProcedureParameter("id", Integer.class, ParameterMode.IN);
        query.registerStoredProcedureParameter("ForceDelete", Boolean.class, ParameterMode.IN);

        query.setParameter("id", id);
        query.setParameter("ForceDelete", force);

        try {
            query.execute();
        } catch (PersistenceException e) {
            String message = e.getMessage();

            if (message.contains("does not exist")) {
                throw new AppException(ErrorCode.USER_ID_NOT_EXISTED);
            } else if (message.contains("User has offered courses")) {
                throw new AppException(ErrorCode.USER_HAS_OFFER);
            } else if (message.contains("User has orders")) {
                throw new AppException(ErrorCode.USER_HAS_ORDER);
            } else {
                throw new AppException(ErrorCode.DATABASE_ERROR);
            }
        }
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}
