package com.academiabaile.backend.controller;


import com.academiabaile.backend.entidades.Rol;
import com.academiabaile.backend.entidades.Usuario;
import com.academiabaile.backend.service.UsuarioService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {


  
    @Autowired
    private PasswordEncoder passwordEncoder;


    @Autowired
    private UsuarioService usuarioService;

    @GetMapping
    public List<Usuario> listar() {
        return usuarioService.listarUsuarios();
    }

    @PostMapping
    public Usuario crear(@RequestBody Usuario usuario) {
        return usuarioService.crearUsuario(usuario);
    }

    @PutMapping("/{id}")
    public Usuario editar(@PathVariable Long id, @RequestBody Usuario usuario) {
        return usuarioService.editarUsuario(id, usuario);
    }

    @DeleteMapping("/{id}")
    public void eliminar(@PathVariable Long id) {
        usuarioService.eliminarUsuario(id);
    }

    @GetMapping("/buscar/{nombreUsuario}")
    public Usuario obtenerPorNombre(@PathVariable String nombreUsuario) {
        return usuarioService.obtenerPorNombreUsuario(nombreUsuario);
    }
    @Autowired
    private com.academiabaile.backend.repository.UsuarioRepository usuarioRepository;

    @GetMapping("/{id}")
    public Usuario obtenerPorId(@PathVariable Long id) {
        return usuarioRepository.findById(id).orElseThrow();
    }
    @Autowired
    private com.academiabaile.backend.service.EmailService emailService;

    @PostMapping("/recuperar")
    public String recuperarContrasena() {
        // Buscar al usuario con rol ADMIN
        Usuario admin = usuarioRepository.findByRol(Rol.ADMIN);

        if (admin == null || admin.getCorreoRecuperacion() == null || admin.getCorreoRecuperacion().isBlank()) {
            return "No se encontró un administrador con correo de recuperación configurado.";
        }

        // Generar código de recuperación (6 dígitos)
        String codigo = generarCodigoRecuperacion();
        String mensaje = "Este es tu código de recuperación: " + codigo;

        // Guardar el código en la base de datos
        admin.setCodigoRecuperacion(codigo);
        usuarioRepository.save(admin);

        // Enviar el correo
        emailService.enviarCorreo(admin.getCorreoRecuperacion(), "Recuperación de contraseña", mensaje);



        return "Se envió un código de recuperación al correo del administrador.";
    }



    // Método auxiliar para generar código de recuperación
    private String generarCodigoRecuperacion() {
        int codigo = (int)(Math.random() * 900000) + 100000; // 6 dígitos aleatorios
        return String.valueOf(codigo);
    }
       @PostMapping("/validar-codigo")
public ResponseEntity<?> validarCodigo(@RequestBody Map<String, String> payload) {
    String codigo = payload.get("codigo");
    String nuevaContrasena = payload.get("nuevaContrasena");

    // Buscar por código
    Optional<Usuario> optionalUsuario = usuarioRepository.findByCodigoRecuperacion(codigo);
    if (optionalUsuario.isEmpty()) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Código inválido");
    }

    Usuario usuario = optionalUsuario.get();

    // Cambiar contraseña
    usuario.setContrasena(passwordEncoder.encode(nuevaContrasena));
    usuario.setCodigoRecuperacion(null); // opcional: limpiar el código después de usarlo
    usuarioRepository.save(usuario);

    return ResponseEntity.ok("Contraseña actualizada correctamente");
}



@GetMapping("/public/usuario-por-nombre/{username}")
public ResponseEntity<Usuario> obtenerPorNombreUsuario(@PathVariable String username) {
    Optional<Usuario> userOpt = usuarioRepository.findByNombreUsuario(username);
    return userOpt.map(ResponseEntity::ok)
              .orElse(ResponseEntity.notFound().build());

}
@GetMapping("/usuario-actual")
public ResponseEntity<String> obtenerUsuarioActual() {
    org.springframework.security.core.Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    return ResponseEntity.ok("Usuario logeado: " + auth.getName());
}

}
