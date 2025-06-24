package db.assignment.dto.request;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class ReviewDTO {

    private Integer courseId;
    private String courseName;
    private Integer userId;
    private String username;
    private Float ratingScore;
    private String comment;
    private Date date;
}
