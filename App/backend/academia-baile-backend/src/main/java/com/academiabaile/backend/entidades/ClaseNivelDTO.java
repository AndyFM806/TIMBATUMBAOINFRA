package com.academiabaile.backend.entidades;

import java.time.LocalDate;

public class ClaseNivelDTO {
    private String nivel;
    private String dias;
    private String hora;
    private Double precio;
    private int aforo;
    private String estado;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;

    // Constructor con estado
    public ClaseNivelDTO(String nivel, String dias, String hora, Double precio, int aforo, String estado, LocalDate fechaInicio, LocalDate fechaFin) {
        this.nivel = nivel;
        this.dias = dias;
        this.hora = hora;
        this.precio = precio;
        this.aforo = aforo;
        this.estado = estado;
        this.fechaInicio = fechaInicio;
        this.fechaFin = fechaFin;
    }

    // Constructor sin estado (opcional, si aún se necesita por compatibilidad)
    public ClaseNivelDTO(String nivel, String dias, String hora, Double precio, int aforo, LocalDate fechaInicio, LocalDate fechaFin) {
        this(nivel, dias, hora, precio, aforo, null, fechaInicio, fechaFin);
    }



    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }

    public String getDias() {
        return dias;
    }

    public void setDias(String dias) {
        this.dias = dias;
    }

    public String getHora() {
        return hora;
    }

    public void setHora(String hora) {
        this.hora = hora;
    }

    public Double getPrecio() {
        return precio;
    }

    public void setPrecio(Double precio) {
        this.precio = precio;
    }

    public int getAforo() {
        return aforo;
    }

    public void setAforo(int aforo) {
        this.aforo = aforo;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
    public LocalDate getFechaInicio() {
        return fechaInicio;
    }

    public void setFechaInicio(LocalDate fechaInicio) {
        this.fechaInicio = fechaInicio;
    }

    public LocalDate getFechaFin() {
        return fechaFin;
    }

    public void setFechaFin(LocalDate fechaFin) {
        this.fechaFin = fechaFin;
    }
}
