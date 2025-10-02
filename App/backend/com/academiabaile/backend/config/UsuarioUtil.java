package com.academiabaile.backend.config;

import com.academiabaile.backend.entidades.Usuario;
import com.academiabaile.backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class UsuarioUtil {

    private static UsuarioRepository staticUsuarioRepository;

    @Autowired
    public UsuarioUtil(UsuarioRepository usuarioRepository) {
        UsuarioUtil.staticUsuarioRepository = usuarioRepository;
    }

    public static Usuario obtenerUsuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated()) {
            String username = auth.getName();
            return staticUsuarioRepository.findByNombreUsuario(username).orElse(null);
        }
        return null;
    }

    public static String obtenerNombreUsuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated()) {
            return auth.getName();
        }
        return null;
    }
}
