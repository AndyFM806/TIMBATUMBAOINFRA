package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.Usuario;
import java.util.List;

public interface UsuarioService {
    List<Usuario> listarUsuarios();
    Usuario crearUsuario(Usuario usuario);
    Usuario editarUsuario(Long id, Usuario usuario);
    void eliminarUsuario(Long id);
    Usuario obtenerPorNombreUsuario(String nombreUsuario);
}
