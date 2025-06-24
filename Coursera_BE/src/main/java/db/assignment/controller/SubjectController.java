package db.assignment.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/subjects")
public class SubjectController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping
    public List<String> getAllSubjects() {
        String sql = "SELECT DISTINCT SName FROM Subject";
        return jdbcTemplate.queryForList(sql, String.class);
    }
}