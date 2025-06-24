package db.assignment.dto.response;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class ReviewResponse {

    private String courseName;
    private Float ratingScore;
    private String offerName;
    private Integer numberOfRegisters;
    private Integer fee;
    private Integer reviewCount;
}
