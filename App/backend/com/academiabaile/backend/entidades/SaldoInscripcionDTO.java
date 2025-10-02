package com.academiabaile.backend.entidades;

public class SaldoInscripcionDTO {
    private Integer inscripcionId;
    private Double total;
    private Double notaCreditoAplicada;
    private Double saldoPendiente;

    public SaldoInscripcionDTO(Integer inscripcionId, Double total, Double notaCreditoAplicada) {
        this.inscripcionId = inscripcionId;
        this.total = total;
        this.notaCreditoAplicada = notaCreditoAplicada != null ? notaCreditoAplicada : 0.0;
        this.saldoPendiente = total - this.notaCreditoAplicada;
    }

    public Integer getInscripcionId() {
        return inscripcionId;
    }

    public Double getTotal() {
        return total;
    }

    public Double getNotaCreditoAplicada() {
        return notaCreditoAplicada;
    }

    public Double getSaldoPendiente() {
        return saldoPendiente;
    }
}