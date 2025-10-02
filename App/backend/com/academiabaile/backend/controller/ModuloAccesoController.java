package com.academiabaile.backend.controller;

import com.academiabaile.backend.entidades.ModuloAcceso;
import com.academiabaile.backend.service.ModuloAccesoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/modulos")
public class ModuloAccesoController {

    @Autowired
    private ModuloAccesoService moduloAccesoService;

    @GetMapping
    public List<ModuloAcceso> listarModulos() {
        return moduloAccesoService.listarModulos();
    }
}

