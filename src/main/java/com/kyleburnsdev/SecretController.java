package com.kyleburnsdev;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping(path="/secret")
public class SecretController {
    @Value("${MY_SECRET_VALUE}")
    private String mySecret;

    @GetMapping
    public @ResponseBody String tellSecret() {
        return String.format("The secret value is %s", mySecret);
    }
}