const API_SOLICITUD = "https://timbatumbao-back.onrender.com/api/solicitudes";
let usuarioActual = null;

function verificarUsuario() {
  const nombreUsuario = document.getElementById("inputNombreUsuario").value;

  fetch(`https://timbatumbao-back.onrender.com/api/usuarios/public/usuario-por-nombre/${nombreUsuario}`)
    .then(res => {
      if (!res.ok) throw new Error("Usuario no encontrado");
      return res.json();
    })
    .then(usuario => {
      usuarioActual = usuario;
      document.getElementById("verificacionUsuario").style.display = "none";
      document.getElementById("seccionSolicitudes").style.display = "block";
      cargarSolicitudes();
      inicializarFormulario();
    })
    .catch(err => {
      alert("Usuario no válido. Intenta nuevamente.");
    });
}

function inicializarFormulario() {
  document.getElementById("formSolicitud").addEventListener("submit", async (e) => {
    e.preventDefault();
    const tipo = document.getElementById("tipo").value;
    const detalle = document.getElementById("detalle").value;

    const solicitud = {
      tipoSolicitud: tipo,
      detalle: detalle,
      usuario: { id: usuarioActual.id }
    };

    const res = await fetch(API_SOLICITUD, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(solicitud)
    });

    if (res.ok) {
      document.getElementById("mensaje").textContent = "Solicitud enviada correctamente.";
      document.getElementById("formSolicitud").reset();
      cargarSolicitudes();
    } else {
      document.getElementById("mensaje").textContent = "Error al enviar solicitud.";
    }
  });
}

function cargarSolicitudes() {
  fetch(`${API_SOLICITUD}/usuario/${usuarioActual.id}`)
    .then(res => res.json())
    .then(data => {
      const tbody = document.getElementById("tablaSolicitudes");
      tbody.innerHTML = "";
      data.forEach(s => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
          <td>${formatearTipo(s.tipoSolicitud)}</td>
          <td>${s.estado}</td>
          <td>${s.respuesta || '---'}</td>
          <td>${new Date(s.fechaCreacion).toLocaleString()}</td>
        `;
        tbody.appendChild(tr);
      });
    });
}

function formatearTipo(tipo) {
  switch (tipo) {
    case "CAMBIO_CONTRASENA": return "Cambio de contraseña";
    case "CAMBIO_USUARIO": return "Cambio de usuario";
    default: return "Otro";
  }
}
