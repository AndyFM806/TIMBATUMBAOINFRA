package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.ModuloAcceso;
import com.academiabaile.backend.repository.ModuloAccesoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ModuloAccesoServiceImpl implements ModuloAccesoService {

    @Autowired
    private ModuloAccesoRepository moduloAccesoRepository;

    @Override
    public List<ModuloAcceso> listarModulos() {
        return moduloAccesoRepository.findAll();
    }
}
