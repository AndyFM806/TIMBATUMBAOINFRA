package com.academiabaile.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.academiabaile.backend.entidades.Aula;

@Repository
public interface AulaRepository extends JpaRepository<Aula, Integer> {
    Optional<Aula> findByCodigo(String codigo);
    List<Aula> findAll();
}
