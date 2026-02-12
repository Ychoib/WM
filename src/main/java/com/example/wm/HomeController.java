package com.example.wm;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    @GetMapping({"/", "/index"})
    public String index() {
        return "index";
    }

    @GetMapping("/expiry")
    public String expiry() {
        return "expiry";
    }

    @GetMapping("/add")
    public String add() {
        return "add";
    }

    @GetMapping("/edit")
    public String edit() {
        return "edit";
    }

    @GetMapping("/policy")
    public String policy() {
        return "policy";
    }

    @GetMapping("/files")
    public String files() {
        return "files";
    }

    @GetMapping("/docs")
    public String docs() {
        return "docs";
    }

    @GetMapping("/parts")
    public String parts() {
        return "parts";
    }

    @GetMapping("/org")
    public String org() {
        return "org";
    }
}
