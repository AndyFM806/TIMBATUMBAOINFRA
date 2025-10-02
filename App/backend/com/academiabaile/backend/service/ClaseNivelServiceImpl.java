package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.Aula;
import com.academiabaile.backend.entidades.CeldaHorarioDTO;
import com.academiabaile.backend.entidades.Clase;
import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.ClaseNivelDTO;
import com.academiabaile.backend.entidades.ClaseNivelHorario;
import com.academiabaile.backend.entidades.ClaseNivelHorarioId;
import com.academiabaile.backend.entidades.CrearClaseNivelDTO;
import com.academiabaile.backend.entidades.Horario;
import com.academiabaile.backend.entidades.Inscripcion;
import com.academiabaile.backend.entidades.Nivel;
import com.academiabaile.backend.entidades.NotaCredito;
import com.academiabaile.backend.repository.ClaseNivelRepository;
import com.academiabaile.backend.repository.InscripcionRepository;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import com.academiabaile.backend.repository.ClaseRepository;
import com.academiabaile.backend.repository.NivelRepository;

import jakarta.transaction.Transactional;

import com.academiabaile.backend.repository.HorarioRepository;

@Service
public class ClaseNivelServiceImpl implements ClaseNivelService {



    @Autowired
    private ClaseRepository claseRepository;

    @Autowired
    private NivelRepository nivelRepository;

    @Autowired
    private HorarioRepository horarioRepository;



    @Autowired
    private ClaseNivelRepository claseNivelRepository;


    @Override
public List<ClaseNivelDTO> obtenerNivelesPorClase(Integer claseId) {
    List<ClaseNivel> claseNiveles = claseNivelRepository.findByClaseId(claseId);
    List<ClaseNivelDTO> resultado = new ArrayList<>();

    for (ClaseNivel cn : claseNiveles) {
        List<ClaseNivelHorario> horarios = claseNivelHorarioRepository.findByClaseNivelId(cn.getId());

        for (ClaseNivelHorario cnh : horarios) {
            Horario horario = cnh.getHorario();

            resultado.add(new ClaseNivelDTO(
                cn.getNivel().getNombre(),
                horario.getDias(),
                horario.getHora(),
                cn.getPrecio(),
                cn.getAforo(),
                cn.getFechaInicio(),
                cn.getFechaFin()
            ));
        }
    }

    return resultado;
}

     @Autowired
    private InscripcionRepository inscripcionRepository;

    @Autowired
    private NotaCreditoService notaCreditoService;

    @Autowired
    private EmailService emailService;
    

    @Override
public void cerrarClaseSiNoLlegaAlMinimo(ClaseNivel claseNivel) {
    List<Inscripcion> inscritos = inscripcionRepository.findByClaseNivelIn(List.of(claseNivel));

    if (inscritos.size() < 10 && "abierta".equalsIgnoreCase(claseNivel.getEstado())) {
        claseNivel.setEstado("cancelada");
        claseNivel.setMotivoCancelacion("Clase cancelada por no alcanzar el mínimo de 10 inscritos.");
        claseNivelRepository.save(claseNivel);

        for (Inscripcion insc : inscritos) {
            NotaCredito nota = notaCreditoService.generarNotaCredito(
                insc.getCliente(),
                claseNivel.getPrecio(),
                claseNivel
            );

            emailService.enviarCorreo(
                insc.getCliente().getCorreo(),
                "Clase cancelada: se ha emitido una nota de crédito",
                "Estimado/a " + insc.getCliente().getNombres() +
                ", la clase \"" + claseNivel.getClase().getNombre() + "\" ha sido cancelada por no alcanzar el mínimo de inscritos." +
                "\n\nSe le ha emitido una nota de crédito válida por 6 meses." +
                "\nCódigo: " + nota.getCodigo() +
                "\nMonto: S/ " + nota.getValor()
            );
        }
    }
}
@Autowired
private com.academiabaile.backend.repository.ClaseNivelHorarioRepository claseNivelHorarioRepository;
@Override
@Transactional
public ClaseNivel crearClaseNivel(CrearClaseNivelDTO dto) {
    Clase clase = claseRepository.findById(dto.getClaseId())
        .orElseThrow(() -> new RuntimeException("Clase no encontrada"));

    Nivel nivel = nivelRepository.findById(dto.getNivelId())
        .orElseThrow(() -> new RuntimeException("Nivel no encontrado"));

    Aula aula = aulaRepository.findById(dto.getAulaId())
        .orElseThrow(() -> new RuntimeException("Aula no encontrada"));

    // Validación: no más de 3 clases por cada horario + aula
    for (Integer horarioId : dto.getHorariosIds()) {
        int count = claseNivelHorarioRepository.countByHorarioIdAndClaseNivel_Aula_Id(horarioId, aula.getId());
        if (count >= 3) {
            throw new RuntimeException("Ya hay 3 clases en este horario y aula");
        }
    }

    // Crear clase nivel
    ClaseNivel claseNivel = new ClaseNivel();
    claseNivel.setClase(clase);
    claseNivel.setNivel(nivel);
    claseNivel.setAula(aula);
    claseNivel.setPrecio(dto.getPrecio());
    claseNivel.setAforo(dto.getAforo());
    claseNivel.setEstado("abierta");
    claseNivel.setFechaCierre(dto.getFechaCierre());

    claseNivelRepository.save(claseNivel);

    // Relacionar con horarios
    for (Integer horarioId : dto.getHorariosIds()) {
        Horario horario = horarioRepository.findById(horarioId)
            .orElseThrow(() -> new RuntimeException("Horario no encontrado"));

        ClaseNivelHorario cnHorario = new ClaseNivelHorario();
        cnHorario.setId(new ClaseNivelHorarioId(claseNivel.getId(), horario.getId()));
        cnHorario.setClaseNivel(claseNivel);
        cnHorario.setHorario(horario);
        claseNivelHorarioRepository.save(cnHorario);
    }

    return claseNivel;
}




    @Override
public void cerrarClaseNivel(Integer id) {
    ClaseNivel claseNivel = claseNivelRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("ClaseNivel no encontrada"));

    if ("cerrada".equalsIgnoreCase(claseNivel.getEstado())) {
        throw new RuntimeException("Clase ya cerrada");
    }

    claseNivel.setEstado("cerrada");
    claseNivelRepository.save(claseNivel);

    List<Inscripcion> inscripciones = inscripcionRepository
        .findByClaseNivelAndEstado(claseNivel, "aprobada");

    for (Inscripcion insc : inscripciones) {
        NotaCredito nota = notaCreditoService.generarNotaCredito(
        insc.getCliente(),
        claseNivel.getPrecio(),
        claseNivel
    );

        emailService.enviarCorreo(
            insc.getCliente().getCorreo(),
            "Clase cancelada",
            "La clase fue cancelada. Puedes usar el código " + nota.getCodigo() +
            " por S/ " + nota.getValor() + " hasta el " + nota.getFechaExpiracion() + ".");

    }
}

@Override
public void reabrirClaseNivel(Integer id) {
    ClaseNivel claseNivel = claseNivelRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("ClaseNivel no encontrada"));

    if (!"cerrada".equalsIgnoreCase(claseNivel.getEstado())) {
        throw new RuntimeException("Solo se pueden reabrir clases que estén en estado 'cerrada'");
    }

    claseNivel.setEstado("abierta");
    claseNivel.setMotivoCancelacion(null);
    claseNivel.setFechaCierre(null); // opcional: si quieres limpiar la fecha
    claseNivelRepository.save(claseNivel);

}
@Override
public List<ClaseNivel> findByClaseIdAndEstado(Integer claseId, String estado) {
    return claseNivelRepository.findByClaseIdAndEstado(claseId, estado);
}
@Autowired
private com.academiabaile.backend.repository.AulaRepository aulaRepository;

@Override
public List<CeldaHorarioDTO> obtenerMapaHorarioDisponible() {
    List<Aula> aulas = aulaRepository.findAll();
    List<Horario> horarios = horarioRepository.findAll();
    List<ClaseNivel> clases = claseNivelRepository.findAll();

    List<CeldaHorarioDTO> resultado = new ArrayList<>();

    for (Horario horario : horarios) {
        for (Aula aula : aulas) {
            // Buscar si existe una clase nivel con ese horario y aula
            Optional<ClaseNivel> ocupado = clases.stream()
                .filter(cn -> cn.getAula().getId().equals(aula.getId())
                           && cn.getHorarios().stream()
                               .anyMatch(h -> h.getId().equals(horario.getId())))
                .findFirst();

            if (ocupado.isPresent()) {
                ClaseNivel cn = ocupado.get();
                resultado.add(new CeldaHorarioDTO(
                    horario.getDias(),
                    horario.getHora(),
                    aula.getCodigo(),
                    true,
                    cn.getClase().getNombre() + " - " + cn.getNivel().getNombre(),
                    cn.getEstado(),
                    horario.getId(),
                    aula.getId(),
                    cn.getId() // Incluye el claseNivelId
                ));
            } else {
                resultado.add(new CeldaHorarioDTO(
                    horario.getDias(),
                    horario.getHora(),
                    aula.getCodigo(),
                    false,
                    null,
                    null,
                    horario.getId(),
                    aula.getId(),
                    null // No hay claseNivelId
                ));
            }
        }
    }

    return resultado;
}


}

