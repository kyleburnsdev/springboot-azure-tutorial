package com.kyleburnsdev;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping(path="/health")
public class HealthController {
    @GetMapping
    public @ResponseBody String checkHealth() {
        return "Application is running";
    }
}