package com.academiabaile.backend.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.repository.ClaseNivelRepository;

@Component
public class EvaluadorAforoScheduler {

    @Autowired
    private ClaseNivelRepository claseNivelRepository;

    @Autowired
    private ClaseNivelService claseNivelService;

    // Se ejecuta todos los días a las 00:00
    @Scheduled(cron = "0 0 0 * * *")
    public void evaluarClasesPorCerrar() {
        LocalDate hoy = LocalDate.now();

        List<ClaseNivel> clasesPorCerrar = claseNivelRepository.findByFechaCierreAndEstado(hoy, "abierta");

        for (ClaseNivel claseNivel : clasesPorCerrar) {
            claseNivelService.cerrarClaseSiNoLlegaAlMinimo(claseNivel);
        }
    }
}
