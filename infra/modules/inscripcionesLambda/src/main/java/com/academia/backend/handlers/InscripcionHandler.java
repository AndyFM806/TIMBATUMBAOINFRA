package com.academiabaile.backend.handlers;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import infra.modules.inscripcionesLambda.java.InscripcionService;

import java.util.Map;

public class InscripcionHandler implements RequestHandler<Map<String, String>, String> {

    private final InscripcionService service = new InscripcionService();

    @Override
    public String handleRequest(Map<String, String> event, Context context) {
        String nombre = event.get("nombreCliente");
        String correo = event.get("correoCliente");
        String clase = event.get("claseBaile");
        String fecha = event.get("fecha");

        InscripcionService.ResultadoInscripcion resultado = service.inscribirCliente(nombre, correo, clase, fecha);

        return resultado.mensaje;
    }
}