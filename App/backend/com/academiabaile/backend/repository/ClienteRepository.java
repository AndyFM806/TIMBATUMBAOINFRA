package com.academiabaile.backend.repository;

import com.academiabaile.backend.entidades.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClienteRepository extends JpaRepository<Cliente, Integer> {
    Optional<Cliente> findByDni(String dni);
    Optional<Cliente> findById(long id);

}
