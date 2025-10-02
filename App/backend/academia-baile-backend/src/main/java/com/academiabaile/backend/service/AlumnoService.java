package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.ClienteDTO;
import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.MovimientoAlumnoDTO;
import com.academiabaile.backend.entidades.NotaCredito;

import java.util.List;

public interface AlumnoService {

    List<ClaseNivel> listarClasesDeAlumno(Integer clienteId);

    void inscribirAlumnoEnClase(Integer clienteId, Integer claseNivelId);

    void moverAlumno(MovimientoAlumnoDTO dto);

    void eliminarAlumnoDeClase(Integer clienteId, Integer claseNivelId);

    NotaCredito generarManualNotaCredito(Integer clienteId, Double valor);

    ClienteDTO obtenerDatosDelAlumno(Integer clienteId);

    void actualizarDatosCliente(ClienteDTO dto);

    void moverAlumnoDeClase(Integer clienteId, Integer origenClaseNivelId, Integer destinoClaseNivelId);
    
    public List<ClaseNivel> listarClasesNoInscritas(Integer clienteId);
    
    List<ClienteDTO> listarAlumnosPorClaseNivel(Integer claseNivelId);

}
