package com.kyleburnsdev;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping(path="/hello")
public class HelloController {
    @GetMapping
    public @ResponseBody String greeting() {
        return "Hello from Spring Boot";
    }
}