package db.assignment.exception;

public enum ErrorCode {

    UNCATEGORIZED_EXCEPTION(9999, "Uncategorized error"),
    USER_ID_NULL(400, "User ID cannot be null or empty"),
    EMAIL_NULL(400, "Email cannot be null or empty"),
    USERNAME_NULL(400, "Username cannot be null or empty"),
    PASSWORD_NULL(400, "Password cannot be null or empty"),
    USER_ID_EXISTED(400, "User with this ID already exists"),
    USER_ID_NOT_EXISTED(400, "User with this ID does not exists"),
    USERNAME_EXISTED(400, "Username is already taken"),
    EMAIL_INVALID(400, "Invalid email format"),
    PASSWORD_TOO_SHORT(400, "Password must be at least 8 characters long"),
    USER_TOO_YOUNG(400, "User must be at least 13 years old"),

    USER_HAS_OFFER(400, "Cannot delete user. User has offered courses. Use force = 1 to delete anyway."),
    USER_HAS_ORDER(400, "Cannot delete user. User has orders. Use force = 1 to delete anyway."),

    UNAUTHENTICATED(400, "Username or Password is incorrect"),
    DATABASE_ERROR(500, "Unexpected database error"),

    ;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    private int code;
    private String message;

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
