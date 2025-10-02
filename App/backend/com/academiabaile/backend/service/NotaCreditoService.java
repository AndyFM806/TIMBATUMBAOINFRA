package com.academiabaile.backend.service;

import java.time.LocalDate;

import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.Cliente;
import com.academiabaile.backend.entidades.NotaCredito;

public interface NotaCreditoService {
    NotaCredito generarNotaCredito(Cliente cliente, Double valor, ClaseNivel claseCancelada);
    void marcarComoUsada(NotaCredito notaCredito);
    public NotaCredito validarNota(String codigo);
    public NotaCredito crearNotaCreditoNueva(Cliente cliente, Double valor, LocalDate fechaEmision, LocalDate fechaExpiracion, ClaseNivel claseCancelada);
}
