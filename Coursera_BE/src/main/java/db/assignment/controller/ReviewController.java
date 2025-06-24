package db.assignment.controller;

import db.assignment.dto.response.ReviewResponse;
import db.assignment.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/reviews")
@RequiredArgsConstructor
public class ReviewController {


    private final ReviewService reviewService;

    @GetMapping
    public ResponseEntity<List<ReviewResponse>> getTopRatedReviews(
            @RequestParam(defaultValue = "") String subjectKeyword,
            @RequestParam(defaultValue = "") String courseKeyword,
            @RequestParam(defaultValue = "0.0") Float minRating,
            @RequestParam(defaultValue = "0") Integer minFee,
            @RequestParam(defaultValue = "0") Integer maxFee)
    {
        return ResponseEntity.ok(reviewService.getTopRatedReviews(subjectKeyword, courseKeyword, minRating, minFee, maxFee));
    }
}