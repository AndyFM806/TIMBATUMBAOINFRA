const API = "https://timbatumbao-back.onrender.com/api";

document.addEventListener("DOMContentLoaded", () => {
  cargarUsuarios();
  cargarModulos();
  document.getElementById("rol").dispatchEvent(new Event("change"));
  document.getElementById("formUsuario").addEventListener("submit", guardarUsuario);
  document.getElementById("rol").addEventListener("change", () => {
    const rol = document.getElementById("rol").value;
    const correo = document.getElementById("correoRecuperacion");
    correo.disabled = (rol === "RECEPCIONISTA");
    if (rol === "RECEPCIONISTA") correo.value = "";
  });
});

function cargarUsuarios() {
  fetch(`${API}/usuarios`, {
    credentials: "include"
  })
    .then(res => res.json())
    .then(data => {
      const tbody = document.getElementById("tablaUsuarios");
      tbody.innerHTML = "";
      data.forEach(usuario => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
        <td>${usuario.nombreUsuario}</td>
        <td>${usuario.rol}</td>
        <td>${usuario.modulos.map(m => m.nombre).join(", ")}</td>
        <td>
          <button onclick="editarUsuario(${usuario.id})">✏️</button>
          <button onclick="eliminarUsuario(${usuario.id})">🗑️</button>
        </td>
      `;
        tbody.appendChild(tr);
      });
    });
}

function cargarModulos() {
  fetch(`${API}/modulos`, {
    credentials: "include"
  })
    .then(res => res.json())
    .then(modulos => {
      const contenedor = document.getElementById("modulosCheckboxes");
      contenedor.innerHTML = "";
      modulos.forEach(mod => {
        contenedor.innerHTML += `
          <label>
            <input type="checkbox" value="${mod.id}" name="modulos"> ${mod.nombre}
          </label><br>`;
      });
    });
}

function guardarUsuario(e) {
  e.preventDefault();

  const rol = document.getElementById("rol").value;
  const correo = document.getElementById("correoRecuperacion").value;

  // Validación extra
  if (rol === "RECEPCIONISTA" && correo.trim() !== "") {
    alert("Un recepcionista no debe tener correo de recuperación.");
    return;
  }

  const id = document.getElementById("usuarioId").value;
  const nombreUsuario = document.getElementById("nombreUsuario").value;
  const contrasena = document.getElementById("contrasena").value;
  const modulos = Array.from(document.querySelectorAll('input[name="modulos"]:checked'))
    .map(cb => ({ id: parseInt(cb.value) }));

  const payload = {
    nombreUsuario,
    contrasena: contrasena || null,
    correoRecuperacion: rol === 'ADMIN' ? correo : null,
    rol,
    modulos
  };

  const method = id ? "PUT" : "POST";
  const url = id ? `${API}/usuarios/${id}` : `${API}/usuarios`;

  fetch(url, {
    method: method,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(payload),
    credentials: "include" // 🔥 esto garantiza que se envíe la cookie de sesión
  })
  .then(response => {
    if (!response.ok) throw new Error("Error al guardar usuario");
    return response.json();
  })
  .then(() => {
    cargarUsuarios();
    document.getElementById("formUsuario").reset();
    document.getElementById("usuarioId").value = "";
    document.getElementById("rol").dispatchEvent(new Event("change"));
  })
  .catch(err => {
    console.error("Error al guardar:", err);
    alert("Hubo un error al guardar el usuario. Revisa la consola para más detalles.");
  });
}


function editarUsuario(id) {
  fetch(`${API}/usuarios/${id}`, {
    credentials: "include"
  })
    .then(res => {
      if (!res.ok) throw new Error("No se pudo obtener el usuario");
      return res.json();
    })
    .then(usuario => {
      document.getElementById("usuarioId").value = usuario.id;
      document.getElementById("nombreUsuario").value = usuario.nombreUsuario;
      document.getElementById("correoRecuperacion").value = usuario.correoRecuperacion || "";
      document.getElementById("rol").value = usuario.rol;

      // Aplica validación de campo correo según el rol
      const correo = document.getElementById("correoRecuperacion");
      correo.disabled = (usuario.rol === "RECEPCIONISTA");
      if (usuario.rol === "RECEPCIONISTA") correo.value = "";

      // Checkboxes de módulos
      document.querySelectorAll('input[name="modulos"]').forEach(cb => {
        cb.checked = usuario.modulos.some(m => m.id == cb.value);
      });
    })
    .catch(err => console.error("Error al editar:", err));
}

function eliminarUsuario(id) {
  if (confirm("¿Seguro que deseas eliminar este usuario?")) {
    fetch(`${API}/usuarios/${id}`, {
      method: "DELETE",
      credentials: "include"
    })
      .then(response => {
        if (!response.ok) throw new Error("No se pudo eliminar el usuario");
        return response.json().catch(() => ({})); // por si no hay body
      })
      .then(() => cargarUsuarios())
      .catch(err => {
        console.error("Error al eliminar:", err);
        alert("Hubo un error al eliminar el usuario. Revisa la consola para más detalles.");
      });
  }
}

// Solicitudes

function mostrarSolicitudes() {
  document.getElementById("seccionSolicitudes").style.display = "block";

  fetch(`${API}/solicitudes`, {
    credentials: "include"
  })
    .then(res => res.json())
    .then(data => {
      const tbody = document.getElementById("tablaSolicitudes");
      tbody.innerHTML = "";
      data.forEach(s => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
          <td>${s.usuario.nombreUsuario}</td>
          <td>${s.tipoSolicitud}</td>
          <td>${s.detalle}</td>
          <td>${s.estado}</td>
          <td>
            ${s.estado === 'PENDIENTE'
              ? `<button onclick="atenderSolicitud(${s.id}, true)">✔️</button>
                 <button onclick="atenderSolicitud(${s.id}, false)">❌</button>`
              : '<i>Finalizada</i>'}
          </td>
        `;
        tbody.appendChild(tr);
      });
    });
}

function atenderSolicitud(id, aprobar) {
  const respuesta = prompt("Ingresa una respuesta para el usuario:");
  if (!respuesta) return;

  fetch(`${API}/solicitudes/${id}/atender?respuesta=${encodeURIComponent(respuesta)}&aprobar=${aprobar}`, {
    method: "PUT",
    credentials: "include"
  })
    .then(() => mostrarSolicitudes());
}
