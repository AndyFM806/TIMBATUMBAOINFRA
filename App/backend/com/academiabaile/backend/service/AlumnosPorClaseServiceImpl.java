package com.academiabaile.backend.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.academiabaile.backend.entidades.Cliente;
import com.academiabaile.backend.entidades.ClienteDTO;
import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.Inscripcion;
import com.academiabaile.backend.repository.ClaseNivelRepository;
import com.academiabaile.backend.repository.InscripcionRepository;

@Service
public class AlumnosPorClaseServiceImpl implements AlumnosPorClaseService {

    @Autowired
    private ClaseNivelRepository claseNivelRepository;

    @Autowired
    private InscripcionRepository inscripcionRepository;

    @Override
    public List<ClienteDTO> obtenerAlumnosPorClaseNivel(Integer claseId) {
        // Obtiene todos los ClaseNivel asociados a una Clase
        List<ClaseNivel> niveles = claseNivelRepository.findByClaseId(claseId);

        // Extrae los IDs de esos ClaseNivel
        List<Integer> nivelIds = niveles.stream()
                                        .map(ClaseNivel::getId)
                                        .collect(Collectors.toList());

        // Consulta inscripciones con estado aprobado y clase_nivel_id IN (...)
        List<Cliente> alumnos = inscripcionRepository
            .findByClaseNivel_IdInAndEstado(nivelIds, "aprobada")
            .stream()
            .map(Inscripcion::getCliente)
            .distinct()
            .toList();

        // Convierte los Clientes a ClienteDTO
        return alumnos.stream().map(c -> {
            ClienteDTO dto = new ClienteDTO();
            dto.setNombres(c.getNombres());
            dto.setApellidos(c.getApellidos());
            dto.setDni(c.getDni());
            dto.setCorreo(c.getCorreo());
            dto.setDireccion(c.getDireccion());
            return dto;
        }).collect(Collectors.toList());
    }
}
