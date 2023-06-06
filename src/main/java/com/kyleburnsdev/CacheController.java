package com.kyleburnsdev;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import org.springframework.data.redis.core.RedisTemplate;

@Controller
@RequestMapping("/cache")
public class CacheController {
    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @GetMapping()
    public @ResponseBody String getVersion() {
        return redisTemplate.getConnectionFactory()
                            .getConnection()
                            .commands()
                            .info("server")
                            .getProperty("redis_version");
    }       
}
