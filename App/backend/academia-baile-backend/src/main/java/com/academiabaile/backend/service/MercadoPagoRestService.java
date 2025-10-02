package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.Inscripcion;
import com.academiabaile.backend.repository.InscripcionRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.*;

@Service
public class MercadoPagoRestService {

    @Value("${mercadopago.access.token}")
    private String accessToken;

    private final InscripcionRepository inscripcionRepository;

    public MercadoPagoRestService(InscripcionRepository inscripcionRepository) {
        this.inscripcionRepository = inscripcionRepository;
    }

    public String crearPreferencia(Double precio, String nombreClase, Integer inscripcionId) {
        RestTemplate restTemplate = new RestTemplate();

        // Obtener inscripción y datos relacionados
        Inscripcion insc = inscripcionRepository.findById(inscripcionId)
                .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));
        ClaseNivel claseNivel = insc.getClaseNivel();
        Integer claseNivelId = claseNivel.getId();
        String nombreNivel = claseNivel.getNivel().getNombre();
        Double precioClase = claseNivel.getPrecio();

        // URL base de redirección (frontend)
        String baseUrl = "https://timbatumbao-front.onrender.com/html/registro.html";

        // Construir URLs con parámetros
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(baseUrl)
                .queryParam("id", claseNivelId)
                .queryParam("nivel", nombreNivel)
                .queryParam("precio", precioClase);

        String successUrl = builder.cloneBuilder().queryParam("estado", "exito").build().toUriString();
        String failureUrl = builder.cloneBuilder().queryParam("estado", "fallo").build().toUriString();
        String pendingUrl = builder.cloneBuilder().queryParam("estado", "pendiente").build().toUriString();

        // Headers con autorización
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Detalle del producto a pagar
        Map<String, Object> item = Map.of(
                "title", "Inscripción: " + nombreClase,
                "quantity", 1,
                "currency_id", "PEN",
                "unit_price", precio
        );

        // Cuerpo de la preferencia
        Map<String, Object> body = new HashMap<>();
        body.put("items", List.of(item));
        body.put("metadata", Map.of("inscripcion_id", inscripcionId));
        body.put("notification_url", "https://timbatumbao-back.onrender.com/api/pagos/webhook");
        body.put("back_urls", Map.of(
                "success", successUrl,
                "failure", failureUrl,
                "pending", pendingUrl
        ));
        body.put("auto_return", "approved");

        // Ejecutar la solicitud POST
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(
                "https://api.mercadopago.com/checkout/preferences",
                entity,
                Map.class
        );

        // Retornar sandbox_init_point para pruebas
        return response.getBody().get("sandbox_init_point").toString();
    }

    public boolean pagoEsAprobado(String paymentId) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        ResponseEntity<Map> resp = restTemplate.exchange(
                "https://api.mercadopago.com/v1/payments/" + paymentId,
                HttpMethod.GET,
                entity,
                Map.class
        );

        String status = String.valueOf(resp.getBody().get("status"));
        Map metadata = (Map) resp.getBody().get("metadata");
        Integer inscripcionId = (Integer) metadata.get("inscripcion_id");

        if ("approved".equals(status)) {
            Inscripcion insc = inscripcionRepository.findById(inscripcionId)
                    .orElseThrow(() -> new RuntimeException("Inscripción no encontrada en pago exitoso"));
            insc.setEstado("aprobada");
            inscripcionRepository.save(insc);

        
        return true;
        }

        return false;
    }
}
