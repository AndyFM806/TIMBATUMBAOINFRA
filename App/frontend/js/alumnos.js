// Asegura que el usuario esté logeado
const API_URL = "https://timbatumbao-back.onrender.com/api";
const usuario = JSON.parse(sessionStorage.getItem("usuario"));
if (!usuario) window.location.href = "../html/login.html";

document.addEventListener("DOMContentLoaded", () => {
  cargarAlumnos();
  cargarClaseNiveles();

  document.getElementById("btnActualizarAlumno").addEventListener("click", actualizarAlumno);
  document.getElementById("btnCancelarEdicion").addEventListener("click", cancelarEdicion);
  document.getElementById("btnMoverAlumno").addEventListener("click", moverAlumno);
  document.getElementById("btnCancelarMovimiento").addEventListener("click", cancelarMovimiento);
  document.getElementById("btnInscribirAlumno").addEventListener("click", inscribirAlumno);
  document.getElementById("btnLimpiarInscripcion").addEventListener("click", limpiarCamposInscripcion);
  document.getElementById("btnEmitirNotaCredito").addEventListener("click", emitirNotaCredito);
  document.getElementById("btnInscribirExistente").addEventListener("click", inscribirAlumnoExistente);
  document.getElementById("btnCancelarInscripcion").addEventListener("click", cancelarInscripcionExistente);
  document.getElementById("nuevoDni").addEventListener("input", verificarDniExistente);
});


function cargarAlumnos() {
  fetch(`${API_URL}/clientes`)
    .then(res => res.json())
    .then(clientes => {
      const tbody = document.getElementById("tablaAlumnos");
      tbody.innerHTML = "";

      clientes.forEach(cliente => {
        fetch(`${API_URL}/alumnos/${cliente.id}/clases`)
          .then(res => res.json())
          .then(clases => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
              <td>${cliente.id}</td>
              <td>${cliente.nombres} ${cliente.apellidos || ''}</td>
              <td>${cliente.dni}</td>
              <td>${clases.map(c => c.clase.nombre + " (" + c.nivel.nombre + ")").join("<br>")}</td>
              <td>
                <button onclick="eliminarAlumno(${cliente.id})">🗑️ Eliminar</button>
                <button onclick="mostrarFormularioEdicion(${cliente.id})">✏️ Editar</button>
                 <button onclick="mostrarFormularioMovimiento(${cliente.id})" class="btn-accion">🔁 Mover</button>
                 <button onclick="mostrarFormularioInscripcion(${cliente.id}, '${cliente.nombres} ${cliente.apellidos || ''}', '${cliente.dni}')">➕ Inscribir</button>
              </td>
            `;
            tbody.appendChild(tr);
          });
      });
    });
}

function cargarClaseNiveles() {
  fetch(`${API_URL}/clase-nivel`)
    .then(res => res.json())
    .then(data => {
      const select = document.getElementById("claseNivelSelect");
      data.forEach(item => {
        const option = document.createElement("option");
        option.value = item.id;
        option.textContent = `${item.clase.nombre} - ${item.nivel.nombre}`;
        select.appendChild(option);
      });
    });
}


function emitirNotaCredito() {
  const dni = document.getElementById("clienteIdCredito").value.trim();
  const valor = document.getElementById("valorCredito").value.trim();

  if (!dni || !valor) {
    alert("Completa ambos campos");
    return;
  }

  // Buscar cliente por DNI
  fetch(`${API_URL}/clientes`)
    .then(res => res.json())
    .then(clientes => {
      const cliente = clientes.find(c => c.dni === dni);
      if (!cliente) {
        alert("Cliente no encontrado con ese DNI");
        return;
      }

      // Generar nota de crédito
      fetch(`${API_URL}/alumnos/${cliente.id}/nota-credito?valor=${valor}`, {
        method: "POST"
      })
        .then(res => res.ok ? res.json() : Promise.reject())
        .then(nota => {
          alert("Nota generada correctamente. Código: " + nota.codigo);
        })
        .catch(() => alert("Error al generar nota de crédito"));
    });
}


function eliminarAlumno(id) {
  if (!confirm("¿Eliminar este alumno de todas sus clases?")) return;

  fetch(`${API_URL}/alumnos/${id}/clases`)
    .then(res => res.json())
    .then(clases => {
      const eliminaciones = clases.map(cn =>
        fetch(`${API_URL}/alumnos/${id}/clase/${cn.id}`, { method: "DELETE" })
      );
      return Promise.all(eliminaciones);
    })
    .then(() => {
      alert("Alumno eliminado de todas las clases");
      cargarAlumnos();
    });
}
function mostrarFormularioEdicion(id) {
  fetch(`${API_URL}/alumnos/${id}/datos`)
    .then(res => res.json())
    .then(data => {
      document.getElementById("formularioEdicion").style.display = "block";
      document.getElementById("editarId").value = data.id;
      document.getElementById("editarNombre").value = `${data.nombres} ${data.apellidos || ''}`.trim();
      document.getElementById("editarDni").value = data.dni || '';
      document.getElementById("editarCorreo").value = data.correo || '';
      document.getElementById("editarDireccion").value = data.direccion || '';
    })
    .catch(error => {
      console.error("Error al cargar datos del alumno:", error);
      alert("No se pudo cargar la información del alumno.");
    });
}

function actualizarAlumno() {
  const id = document.getElementById("editarId").value;
  const nombreCompleto = document.getElementById("editarNombre").value.trim();
  const dni = document.getElementById("editarDni").value;
  const correo = document.getElementById("editarCorreo").value;
  const direccion = document.getElementById("editarDireccion").value;

  if (!nombreCompleto || !dni) {
    alert("Nombre y DNI son obligatorios");
    return;
  }

  const partes = nombreCompleto.split(" ");
  const nombres = partes.slice(0, -1).join(" ") || partes[0];
  const apellidos = partes.slice(-1).join(" ");

  const body = {
    id,
    nombres,
    apellidos,
    dni,
    correo,
    direccion
  };

  fetch(`${API_URL}/alumnos/${id}/datos`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  })
    .then(res => {
      if (res.ok) {
        alert("Alumno actualizado correctamente");
        document.getElementById("formularioEdicion").style.display = "none";
        cargarAlumnos();
      } else {
        alert("Error al actualizar los datos");
      }
    })
    .catch(error => {
      console.error("Error en la actualización:", error);
      alert("Hubo un problema al intentar actualizar.");
    });
}

function cancelarEdicion() {
  document.getElementById("formularioEdicion").style.display = "none";
}
function moverAlumnoDeClase() {
  const clienteId = document.getElementById("moverAlumnoId").value;
  const origenClaseNivelId = document.getElementById("moverDesdeClaseId").value;
  const destinoClaseNivelId = document.getElementById("moverHaciaClaseId").value;

  if (!clienteId || !origenClaseNivelId || !destinoClaseNivelId) {
    alert("Completa todos los campos");
    return;
  }

  fetch(`${API_URL}/alumnos/mover`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      clienteId: parseInt(clienteId),
      origenClaseNivelId: parseInt(origenClaseNivelId),
      destinoClaseNivelId: parseInt(destinoClaseNivelId)
    })
  })
    .then(res => {
      if (!res.ok) throw new Error("Error al mover alumno");
      return res.text();
    })
    .then(msg => {
      alert("Alumno movido correctamente");
      cargarAlumnos();
    })
    .catch(err => {
      console.error(err);
      alert("Error: no se pudo mover el alumno.");
    });
}

function cargarClasesDelAlumno(clienteId) {
  return fetch(`${API_URL}/alumnos/${clienteId}/clases`)
    .then(res => res.json());
}
function prepararFormularioMovimiento(clienteId) {
  Promise.all([
    cargarClasesDelAlumno(clienteId),
    fetch(`${API_URL}/alumnos/${clienteId}/clases-disponibles`).then(res => res.json())
  ]).then(([clasesActuales, clasesDisponibles]) => {
    const desdeSelect = document.getElementById("desdeClaseSelect");
    const haciaSelect = document.getElementById("haciaClaseSelect");

    desdeSelect.innerHTML = "";
    haciaSelect.innerHTML = "";

    clasesActuales.forEach(cn => {
      const opt = document.createElement("option");
      opt.value = cn.id;
      opt.textContent = `${cn.clase.nombre} (${cn.nivel.nombre})`;
      desdeSelect.appendChild(opt);
    });

    clasesDisponibles.forEach(cn => {
      const opt = document.createElement("option");
      opt.value = cn.id;
      opt.textContent = `${cn.clase.nombre} (${cn.nivel.nombre})`;
      haciaSelect.appendChild(opt);
    });

    document.getElementById("formularioMovimiento").style.display = "block";
    document.getElementById("moverId").value = clienteId;
  });
}
function moverAlumno() {
  const clienteId = document.getElementById("moverId").value;
  const origenClaseNivelId = document.getElementById("desdeClaseSelect").value;
  const destinoClaseNivelId = document.getElementById("haciaClaseSelect").value;

  if (!origenClaseNivelId || !destinoClaseNivelId) return alert("Selecciona ambas clases");

  fetch(`${API_URL}/alumnos/mover`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      clienteId,
      origenClaseNivelId,
      destinoClaseNivelId
    })
  })
    .then(res => {
      if (res.ok) {
        alert("Alumno movido correctamente");
        document.getElementById("formularioMovimiento").style.display = "none";
        cargarAlumnos();
      } else {
        res.text().then(msg => alert("Error: " + msg));
      }
    });
}


function cancelarMovimiento() {
  document.getElementById("formularioMovimiento").style.display = "none";
}
function mostrarFormularioMovimiento(id) {
  document.getElementById("formularioMovimiento").style.display = "block";
  document.getElementById("moverId").value = id;

  // Limpiar selects
  const desdeSelect = document.getElementById("desdeClaseSelect");
  const haciaSelect = document.getElementById("haciaClaseSelect");
  desdeSelect.innerHTML = "";
  haciaSelect.innerHTML = "";

  // Cargar clases actuales del alumno (para el "desde")
  fetch(`${API_URL}/alumnos/${id}/clases`)
    .then(res => res.json())
    .then(inscritas => {
      inscritas.forEach(cn => {
        const option = document.createElement("option");
        option.value = cn.id;
        option.textContent = `${cn.clase.nombre} (${cn.nivel.nombre})`;
        desdeSelect.appendChild(option);
      });
    });

  // Cargar TODAS las clases para el "hacia"
  fetch(`${API_URL}/clase-nivel`)
    .then(res => res.json())
    .then(todas => {
      // Ahora filtramos para que no aparezcan las ya inscritas
      fetch(`${API_URL}/alumnos/${id}/clases`)
        .then(res => res.json())
        .then(inscritas => {
          const idsInscritas = inscritas.map(c => c.id);
          const disponibles = todas.filter(cn => !idsInscritas.includes(cn.id));

          disponibles.forEach(cn => {
            const option = document.createElement("option");
            option.value = cn.id;
            option.textContent = `${cn.clase.nombre} (${cn.nivel.nombre})`;
            haciaSelect.appendChild(option);
          });
        });
    });
}
function cancelarMovimiento() {
  document.getElementById("formularioMovimiento").style.display = "none";
}
function verificarDniExistente() {
  const dni = document.getElementById("nuevoDni").value.trim();
  if (!dni || dni.length !== 8) return;

  fetch(`${API_URL}/clientes/dni/${dni}`)
    .then(res => {
      if (!res.ok) throw new Error("No existe");
      return res.json();
    })
    .then(cliente => {
      document.getElementById("nuevoNombre").value = cliente.nombres;
      document.getElementById("nuevoApellidos").value = cliente.apellidos || '';
      document.getElementById("nuevoCorreo").value = cliente.correo || '';
      document.getElementById("nuevoDireccion").value = cliente.direccion || '';

      document.getElementById("nuevoNombre").disabled = true;
      document.getElementById("nuevoApellidos").disabled = true;
      document.getElementById("nuevoCorreo").disabled = true;
      document.getElementById("nuevoDireccion").disabled = true;

      document.getElementById("nuevoDni").dataset.existingId = cliente.id;
    })
    .catch(() => {
      document.getElementById("nuevoNombre").value = "";
      document.getElementById("nuevoApellidos").value = "";
      document.getElementById("nuevoCorreo").value = "";
      document.getElementById("nuevoDireccion").value = "";

      document.getElementById("nuevoNombre").disabled = false;
      document.getElementById("nuevoApellidos").disabled = false;
      document.getElementById("nuevoCorreo").disabled = false;
      document.getElementById("nuevoDireccion").disabled = false;

      document.getElementById("nuevoDni").dataset.existingId = "";
    });
}


function inscribirAlumno() {
  const nombres = document.getElementById("nuevoNombre").value.trim();
  const apellidos = document.getElementById("nuevoApellidos").value.trim();
  const dni = document.getElementById("nuevoDni").value.trim();
  const correo = document.getElementById("nuevoCorreo").value.trim();
  const direccion = document.getElementById("nuevoDireccion").value.trim();
  const claseNivelId = document.getElementById("claseNivelSelect").value;

  if (!dni || !claseNivelId) {
    alert("DNI y clase son obligatorios");
    return;
  }

  const clienteExistenteId = document.getElementById("nuevoDni").dataset.existingId;

  // Ya existe, solo inscribir
  if (clienteExistenteId) {
    fetch(`${API_URL}/alumnos/inscribir?clienteId=${clienteExistenteId}&claseNivelId=${claseNivelId}`, {
      method: "POST"
    })
      .then(() => {
        alert("Alumno inscrito correctamente");
        cargarAlumnos();
      });
  } else {
    // Nuevo cliente
    if (!nombres || !apellidos || !correo || !direccion) {
      alert("Completa todos los campos");
      return;
    }

    const nuevoCliente = { nombres, apellidos, dni, correo, direccion };

    fetch(`${API_URL}/clientes`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(nuevoCliente)
    })
      .then(res => res.json())
      .then(cliente => {
        return fetch(`${API_URL}/alumnos/inscribir?clienteId=${cliente.id}&claseNivelId=${claseNivelId}`, {
          method: "POST"
        });
      })
      .then(() => {
        alert("Alumno inscrito correctamente");
        cargarAlumnos();
      });
  }
}
function limpiarCamposInscripcion() {
  document.getElementById("nuevoNombre").value = "";
  document.getElementById("nuevoApellidos").value = "";
  document.getElementById("nuevoDni").value = "";
  document.getElementById("nuevoCorreo").value = "";
  document.getElementById("nuevoDireccion").value = "";

  document.getElementById("nuevoNombre").disabled = false;
  document.getElementById("nuevoApellidos").disabled = false;
  document.getElementById("nuevoCorreo").disabled = false;
  document.getElementById("nuevoDireccion").disabled = false;

  document.getElementById("nuevoDni").dataset.existingId = "";
}
function mostrarFormularioInscripcion(clienteId, nombre, dni) {
  document.getElementById("formularioInscripcionExistente").style.display = "block";
  document.getElementById("inscribirAlumnoId").value = clienteId;
  document.getElementById("inscribirAlumnoNombre").textContent = nombre;
  document.getElementById("inscribirAlumnoDni").textContent = dni;

  const select = document.getElementById("claseNivelSelectExistente");
  select.innerHTML = "";

  // Obtener clases NO inscritas
  fetch(`${API_URL}/alumnos/${clienteId}/clases-disponibles`)
    .then(res => res.json())
    .then(clasesDisponibles => {
      if (clasesDisponibles.length === 0) {
        const option = document.createElement("option");
        option.disabled = true;
        option.textContent = "Ya está inscrito en todas las clases";
        select.appendChild(option);
        return;
      }

      clasesDisponibles.forEach(cn => {
        const option = document.createElement("option");
        option.value = cn.id;
        option.textContent = `${cn.clase.nombre} (${cn.nivel.nombre})`;
        select.appendChild(option);
      });
    });
}


function inscribirAlumnoExistente() {
  const clienteId = document.getElementById("inscribirAlumnoId").value;
  const claseNivelId = document.getElementById("claseNivelSelectExistente").value;

  if (!claseNivelId) {
    alert("Selecciona una clase");
    return;
  }

  fetch(`${API_URL}/alumnos/inscribir?clienteId=${clienteId}&claseNivelId=${claseNivelId}`, {
    method: "POST"
  })
    .then(res => {
      if (res.ok) {
        alert("Alumno inscrito correctamente");
        document.getElementById("formularioInscripcionExistente").style.display = "none";
        cargarAlumnos();
      } else {
        return res.text().then(msg => { throw new Error(msg); });
      }
    })
    .catch(err => alert("Error: " + err.message));
}
function cancelarInscripcionExistente() {
  document.getElementById("formularioInscripcionExistente").style.display = "none";
}
