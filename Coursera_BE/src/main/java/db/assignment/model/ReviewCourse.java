//package db.assignment.model;
//
//import jakarta.persistence.*;
//import lombok.Getter;
//import lombok.Setter;
//
//import java.math.BigDecimal;
//import java.time.LocalDateTime;
//
//@Entity
//@Table(name = "review_course")
//@Getter
//@Setter
//public class ReviewCourse {
//
//    @EmbeddedId
//    private ReviewCourseId id;
//
//    @Column(name = "Comment")
//    private String comment;
//
//    @Column(name = "Date")
//    private LocalDateTime date;
//
//    @Column(name = "Rating_score")
//    private BigDecimal ratingScore;
//
//    @ManyToOne
//    @MapsId("userId")
//    @JoinColumn(name = "User_id")
//    private User user;
//
////    @ManyToOne
////    @MapsId("courseId")
////    @JoinColumn(name = "Course_id")
////    private Course course;
////
////    // getters and setters
//}