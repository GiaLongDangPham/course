package db.assignment.service;

import db.assignment.dto.response.TrendCourseResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class CourseService {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<TrendCourseResponse> getTrendingCourses(LocalDate date, Integer top, String subjectName) {
        if (subjectName.isEmpty()) {
            subjectName = null;
        }
        String sql = "SELECT * FROM dbo.trendCourseSubject(?, ?, ?)";
        return jdbcTemplate.query(sql, new Object[]{date, top, subjectName}, (rs, rowNum) -> {
            TrendCourseResponse dto = new TrendCourseResponse();
            dto.setCourseId(rs.getInt("c_id"));
            dto.setCname(rs.getString("cname"));
            dto.setNumBuy(rs.getInt("Num_buy"));
            dto.setRating(rs.getFloat("rating"));
            return dto;
        });
    }
}
