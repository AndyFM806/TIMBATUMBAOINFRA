package com.academiabaile.backend.repository;


import com.academiabaile.backend.entidades.NotaCredito;
import org.springframework.data.jpa.repository.JpaRepository;


import java.util.Optional;

public interface NotaCreditoRepository extends JpaRepository<NotaCredito, Integer> {
    Optional<NotaCredito> findByCodigoAndUsadaFalse(String codigo);
    Optional<NotaCredito> findByCodigo(String codigo);


}
