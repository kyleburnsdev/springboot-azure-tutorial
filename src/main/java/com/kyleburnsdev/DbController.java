package com.kyleburnsdev;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.jdbc.core.JdbcTemplate;

@Controller
@RequestMapping(path="/db")
public class DbController {
    @Autowired JdbcTemplate jdbcTemplate;

    @GetMapping
    public @ResponseBody String dbVersion() {
        String sqlCommand = "SELECT version()";
        String result = jdbcTemplate.queryForObject(sqlCommand, String.class);
        return String.format("The detected database version is: %s", result);
    }
}