package com.academiabaile.backend.repository;


import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import com.academiabaile.backend.entidades.*;


public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    boolean existsByNombreUsuario(String nombreUsuario);
    Optional<Usuario> findByNombreUsuario(String nombreUsuario);
    Usuario findByCorreoRecuperacion(String correo);
    Usuario findByRol(Rol rol);
    Optional<Usuario> findByCodigoRecuperacion(String codigoRecuperacion);
}


