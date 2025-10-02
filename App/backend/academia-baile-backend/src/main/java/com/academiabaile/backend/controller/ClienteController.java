package com.academiabaile.backend.controller;

import com.academiabaile.backend.entidades.Cliente;
import com.academiabaile.backend.entidades.ClienteDTO;
import com.academiabaile.backend.service.ClienteService;
import com.academiabaile.backend.repository.ClienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clientes")
@CrossOrigin(origins = {"https://timbatumbao-front.onrender.com", "http://localhost:5500"})
public class ClienteController {

    @Autowired
    private ClienteService clienteService;

    @Autowired
    private ClienteRepository clienteRepository;



    // ✅ Registro manual de cliente (sin claseNivel, ya no se usa directamente)
    @PostMapping
    public Cliente registrarCliente(@RequestBody Cliente cliente) {
        return clienteService.guardarCliente(cliente);
    }

    // ✅ Listado general de clientes
    @GetMapping
    public List<Cliente> listarClientes() {
        return clienteService.listarClientes();
    }

    // ✅ Obtener anotación
    @GetMapping("/{id}/anotacion")
    public ResponseEntity<String> obtenerAnotacion(@PathVariable Integer id) {
        Cliente cliente = clienteService.findById(id);
        if (cliente == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(cliente.getAnotacion());
    }

    // ✅ Actualizar anotación
    @PutMapping("/{id}/anotacion")
    public ResponseEntity<Cliente> actualizarAnotacion(@PathVariable Integer id, @RequestBody String nuevaAnotacion) {
        Cliente cliente = clienteService.findById(id);
        if (cliente == null) {
            return ResponseEntity.notFound().build();
        }
        cliente.setAnotacion(nuevaAnotacion);
        return ResponseEntity.ok(clienteService.guardarCliente(cliente));
    }

    // ✅ Eliminar cliente
    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarCliente(@PathVariable Integer id) {
        clienteRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
    // ✅ Editar datos generales de un cliente
@PutMapping("/{id}")
public ResponseEntity<?> editarCliente(@PathVariable Integer id, @RequestBody ClienteDTO dto) {
    try {
        Cliente cliente = clienteService.findById(id);
        cliente.setNombres(dto.getNombres());
        cliente.setApellidos(dto.getApellidos());
        cliente.setCorreo(dto.getCorreo());
        cliente.setDireccion(dto.getDireccion());

        Cliente actualizado = clienteService.guardarCliente(cliente);


        return ResponseEntity.ok(actualizado);
    } catch (Exception e) {
        return ResponseEntity.status(404).body("Cliente no encontrado");
    }
}

}
