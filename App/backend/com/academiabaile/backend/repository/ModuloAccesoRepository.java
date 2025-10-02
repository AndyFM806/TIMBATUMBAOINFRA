package com.academiabaile.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.academiabaile.backend.entidades.ModuloAcceso;

public interface ModuloAccesoRepository extends JpaRepository<ModuloAcceso, Long> {
    ModuloAcceso findByNombre(String nombre);
}