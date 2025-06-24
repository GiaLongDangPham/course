package db.assignment.controller;

import db.assignment.dto.response.TrendCourseResponse;
import db.assignment.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/courses")
@RequiredArgsConstructor
public class CourseController {
    private final CourseService courseService;

    @GetMapping("/trending")
    public ResponseEntity<List<TrendCourseResponse>> getTrendingCourses(
            @RequestParam(required = false) LocalDate date,
            @RequestParam(defaultValue = "100") int top,
            @RequestParam(defaultValue = "") String subjectName) {
        List<TrendCourseResponse> result = courseService.getTrendingCourses(date, top, subjectName);
        return ResponseEntity.ok(result);
    }
}
