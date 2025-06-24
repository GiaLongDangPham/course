package db.assignment.service;

import db.assignment.dto.response.ReviewResponse;
import db.assignment.repository.ReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    public List<ReviewResponse> getTopRatedReviews(String subjectKeyword, String courseKeyword, Float minRating,
                                                   Integer minFee, Integer maxFee) {
        return reviewRepository.getTopRatedReviews(subjectKeyword, courseKeyword, minRating, minFee, maxFee);
    }
}