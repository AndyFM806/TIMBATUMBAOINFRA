const base = "https://timbatumbao-back.onrender.com/api";

let últimosDatosHorarios = [];

window.onload = () => {

  cargarClases();
  cargarNiveles();
  cargarClaseNivel();
};


function cargarClases() {
  fetch(base + "/clases")
    .then(r => r.json())
    .then(data => {
      const tabla = document.getElementById("tablaClases");
      tabla.innerHTML = "<tr><th>Nombre</th><th>Descripción</th><th>Acciones</th></tr>";
      document.getElementById("selectClase").innerHTML = "";
      data.forEach(c => {
        tabla.innerHTML += `
          <tr>
            <td>${c.nombre}</td>
            <td>${c.descripcion}</td>
            <td>
              <button onclick="editarClase(${c.id}, '${c.nombre}', '${c.descripcion}')">✏️</button>
              <button onclick="eliminarClase(${c.id})">🗑️</button>
            </td>
          </tr>`;
        document.getElementById("selectClase").innerHTML += `<option value="${c.id}">${c.nombre}</option>`;
      });
    });
}

function cargarNiveles() {
  fetch(base + "/niveles")
    .then(r => r.json())
    .then(data => {
      const tabla = document.getElementById("tablaNiveles");
      tabla.innerHTML = "<tr><th>Nombre</th><th>Acciones</th></tr>";
      document.getElementById("selectNivel").innerHTML = "";
      data.forEach(n => {
        tabla.innerHTML += `
          <tr>
            <td>${n.nombre}</td>
            <td>
              <button onclick="editarNivel(${n.id}, '${n.nombre}')">✏️</button>
              <button onclick="eliminarNivel(${n.id})">🗑️</button>
            </td>
          </tr>`;
        document.getElementById("selectNivel").innerHTML += `<option value="${n.id}">${n.nombre}</option>`;
      });
    });
}

function renderClaseNiveles(data) {
  const tabla = document.getElementById('tablaClaseNivel');

  if (!Array.isArray(data)) {
    tabla.innerHTML = "<tr><td colspan='9'>⚠️ No se pudieron cargar los datos.</td></tr>";
    return;
  }

  tabla.innerHTML = `
    <thead>
      <tr>
        <th>Clase</th>
        <th>Nivel</th>
        <th>Aula</th>
        <th>Horarios</th>
        <th>Precio</th>
        <th>Aforo</th>
        <th>Estado</th>
        <th>Fecha Cierre</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody>
      ${
        data.map(cn => {
          if (!cn.id) return "";

          const clase = cn.clase?.nombre || "—";
          const nivel = cn.nivel?.nombre || "—";
          const aula = cn.aula?.codigo || "—";
          const horarios = Array.isArray(cn.horarios)
            ? cn.horarios.map(h => `${h.dias} ${h.hora}`).join("<br>")
            : "—";
          const precio = cn.precio != null ? `S/ ${cn.precio}` : "—";
          const aforo = cn.aforo != null ? cn.aforo : "—";
          const estado = cn.estado || "—";
          const fechaCierre = cn.fechaCierre || "—";

          return `
            <tr>
              <td>${clase}</td>
              <td>${nivel}</td>
              <td>${aula}</td>
              <td>${horarios}</td>
              <td>${precio}</td>
              <td>${aforo}</td>
              <td>${estado}</td>
              <td>${fechaCierre}</td>
              <td>
                <button onclick="editarClaseNivel(${cn.id})">✏️ Editar</button>
                <button onclick="eliminarClaseNivel(${cn.id})">🗑️ Eliminar</button>
                ${
                  estado === 'cerrada'
                    ? `<button onclick="reabrirClaseNivel(${cn.id})" class="btn-reabrir">🔓 Reabrir</button>`
                    : `<button onclick="cerrarClaseNivel(${cn.id})" class="btn-cerrar">🔒 Cerrar</button>`
                }
                <button onclick="mostrarAlumnosClase(${cn.id})">👥 Alumnos</button>
              </td>
            </tr>
          `;
        }).join('')
      }
    </tbody>
  `;
}





// ❌ Eliminar ClaseNivel con manejo de error por relaciones
function eliminarClaseNivel(id) {
  fetch(base + "/clase-nivel/" + id, { method: "DELETE" })
    .then(res => {
      if (!res.ok) return res.text().then(text => { throw new Error(text) });
      cargarClaseNivel();
    })
    .catch(err => alert("❌ No se puede eliminar esta ClaseNivel: tiene inscripciones relacionadas."));
}

// 🚫 Cierre manual de clase-nivel
function cerrarClaseNivel(id) {
  if (confirm("¿Deseas cerrar esta ClaseNivel manualmente?")) {
    fetch(base + `/clases/${id}/cerrar`, { method: "POST" })
      .then(res => {
        if (!res.ok) return res.text().then(text => { throw new Error(text) });
        alert("✅ Clase cerrada correctamente.");
        cargarClaseNivel();
      })
      .catch(err => alert("❌ Error al cerrar clase: " + err.message));
  }
}

function editarClase(id, nombre, descripcion) {
  document.getElementById("claseId").value = id;
  document.getElementById("claseNombre").value = nombre;
  document.getElementById("claseDescripcion").value = descripcion;
}

document.getElementById("formClase").addEventListener("submit", function (e) {
  e.preventDefault();
  const id = document.getElementById("claseId").value;
  const nombre = document.getElementById("claseNombre").value;
  const descripcion = document.getElementById("claseDescripcion").value;

  const metodo = id ? "PUT" : "POST";
  const url = base + "/clases" + (id ? `/${id}` : "");

  fetch(url, {
    method: metodo,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ nombre, descripcion })
  })
    .then(res => {
      if (!res.ok) return res.text().then(t => { throw new Error(t) });
      return res.json();
    })
    .then(() => {
      document.getElementById("formClase").reset();
      cargarClases();
    })
    .catch(err => alert("❌ Error al guardar clase: " + err.message));
});

function editarNivel(id, nombre) {
  document.getElementById("nivelId").value = id;
  document.getElementById("nivelNombre").value = nombre;
}

document.getElementById("formNivel").addEventListener("submit", function (e) {
  e.preventDefault();
  const id = document.getElementById("nivelId").value;
  const nombre = document.getElementById("nivelNombre").value;

  const metodo = id ? "PUT" : "POST";
  const url = base + "/niveles" + (id ? `/${id}` : "");

  fetch(url, {
    method: metodo,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ nombre })
  })
    .then(r => {
      if (!r.ok) return r.text().then(t => { throw new Error(t) });
      return r.json();
    })
    .then(() => {
      document.getElementById("formNivel").reset();
      cargarNiveles();
    })
    .catch(err => alert("❌ Error al guardar nivel: " + err.message));
});



const formClaseNivel = document.getElementById("formClaseNivel");
if (formClaseNivel) {
  formClaseNivel.addEventListener("submit", function (e) {
  e.preventDefault();

  const id = document.getElementById("claseNivelId").value;
  const claseId = document.getElementById("selectClase").value;
  const nivelId = document.getElementById("selectNivel").value;
  const horarioId = document.getElementById("selectHorario").value;
  const precio = parseFloat(document.getElementById("claseNivelPrecio").value);
  const aforo = parseInt(document.getElementById("claseNivelAforo").value);
  const estado = document.getElementById("claseNivelEstado").value;
  const fechaCierre = document.getElementById("claseNivelFechaCierre").value || null;

  if (precio < 1 || aforo < 1) {
    alert("❌ El precio y el aforo deben ser mayores a 0.");
    return;
  }

  if (fechaCierre) {
    const hoy = new Date();
    const cierreDate = new Date(fechaCierre);
    hoy.setHours(0, 0, 0, 0);
    if (cierreDate < hoy) {
      alert("❌ La fecha de cierre no puede ser anterior a hoy.");
      return;
    }
  }

  const metodo = id ? "PUT" : "POST";
  const url = id ? `${base}/clase-nivel/${id}` : `${base}/clase-nivel/crear`;

  const datos = {
    claseId,
    nivelId,
    horarioId,
    precio,
    aforo,
    estado,
    fechaCierre
  };

  fetch(url, {
    method: metodo,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(datos)
  })
    .then(res => {
      if (!res.ok) return res.text().then(text => { throw new Error(text) });
      return res.json();
    })
    .then(() => {
      document.getElementById("formClaseNivel").reset();
      document.getElementById("claseNivelId").value = ""; // ← Limpia ID
      cargarClaseNivel();
    })
    .catch(err => alert("❌ Error al guardar ClaseNivel: " + err.message));
});
}

    

// 🗑️ Eliminar CLASE
function eliminarClase(id) {
  if (!confirm("¿Estás seguro de eliminar esta clase?")) return;
  fetch(`${base}/clases/${id}`, { method: "DELETE" })
    .then(res => {
      if (!res.ok) throw new Error("No se pudo eliminar.");
      cargarClases();
    })
    .catch(err => alert("❌ No se pudo eliminar la clase: " + err.message));
}

// 🗑️ Eliminar NIVEL
function eliminarNivel(id) {
  if (!confirm("¿Eliminar este nivel?")) return;
  fetch(`${base}/niveles/${id}`, { method: "DELETE" })
    .then(res => {
      if (!res.ok) throw new Error("No se pudo eliminar.");
      cargarNiveles();
    })
    .catch(err => alert("❌ No se pudo eliminar el nivel: " + err.message));
}

function resetClase() {
    document.getElementById("formClase").reset();
    document.getElementById("claseId").value = "";
}

function resetNivel() {
    document.getElementById("formNivel").reset();
    document.getElementById("nivelId").value = "";
}

function resetHorario() {
    document.getElementById("formHorario").reset();
    document.getElementById("horarioId").value = "";
}

function resetClaseNivel() {
    document.getElementById("formClaseNivel").reset();
    // Si tienes un campo oculto de id para ClaseNivel, resetea aquí también
    // document.getElementById("claseNivelId").value = "";
}
function reabrirClaseNivel(id) {
  if (!confirm("¿Estás seguro de que deseas reabrir esta clase?")) return;

  fetch(`https://timbatumbao-back.onrender.com/api/clase-nivel/${id}/reabrir`, {
    method: 'PATCH'
  })
    .then(response => {
      if (!response.ok) {
        return response.text().then(msg => { throw new Error(msg); });
      }
      alert("Clase reabierta correctamente.");
      location.reload(); // recarga para ver cambios
    })
    .catch(error => {
      console.error("Error al reabrir clase:", error);
      alert("❌ No se pudo reabrir la clase: " + error.message);
    });
}
function cargarClaseNivel() {
  fetch(base + "/clase-nivel")
    .then(res => {
      if (!res.ok) throw new Error("Error al cargar clases-nivel");
      return res.json();
    })
    .then(data => renderClaseNiveles(data))
    .catch(err => alert("❌ No se pudieron cargar las clases-nivel: " + err.message));
}
async function editarClaseNivel(id) {
  try {
    const res = await fetch(`${BASE}/clase-nivel/${id}`);
    if (!res.ok) throw new Error("No se pudo obtener la ClaseNivel");
    const claseNivel = await res.json();

    // Setear campos
    document.getElementById("selectClase").value = claseNivel.clase.id;
    document.getElementById("selectNivel").value = claseNivel.nivel.id;
    document.getElementById("selectAula").value = claseNivel.aula.id;
    document.getElementById("precio").value = claseNivel.precio;
    document.getElementById("aforo").value = claseNivel.aforo;
    document.getElementById("estado").value = claseNivel.estado;
    document.getElementById("fechaInicio").value = claseNivel.fechaInicio;
    document.getElementById("fechaFin").value = claseNivel.fechaFin;
    document.getElementById("fechaCierre").value = claseNivel.fechaCierre;
    document.getElementById("distintivo").value = claseNivel.distintivo;

    // Setear data-id y horarios seleccionados
    document.getElementById("formCrearClaseNivel").setAttribute("data-id", claseNivel.id);
    horariosSeleccionados = claseNivel.horarios.map(h => ({ horarioId: h.id, aulaId: claseNivel.aula.id }));

    // Mostrar modal y renderizar
    document.getElementById("modalCrearClaseNivel").style.display = "flex";
    const horariosDisponibles = await fetch(`${BASE}/clase-nivel/horario-disponibilidad`).then(r => r.json());
    últimosDatosHorarios = horariosDisponibles;
    renderizarTablaHorario(últimosDatosHorarios);
  } catch (e) {
    alert("Error al editar: " + e.message);
  }
}

function mostrarAlumnosClase(claseNivelId) {
  fetch(`${base}/clase-nivel/${claseNivelId}/alumnos`)
    .then(res => {
      if (!res.ok) throw new Error("No se pudo obtener los alumnos.");
      return res.json();
    })
    .then(alumnos => {
      const tbody = document.getElementById("tablaAlumnosClase");
      tbody.innerHTML = "";

      if (alumnos.length === 0) {
        tbody.innerHTML = "<tr><td colspan='3'>No hay alumnos inscritos.</td></tr>";
      } else {
        alumnos.forEach(al => {
          const tr = document.createElement("tr");
          tr.innerHTML = `
          <td>${(al.nombres || "") + " " + (al.apellidos || "")}</td>
          <td>${al.dni}</td>
          <td><button onclick="retirarAlumnoDeClase(${al.id}, ${claseNivelId})">❌ Retirar</button></td>
        `;
          tbody.appendChild(tr);
        });
      }

      document.getElementById("modalAlumnosClase").style.display = "flex";
    })
    .catch(err => alert("Error: " + err.message));
}
function retirarAlumnoDeClase(clienteId, claseNivelId) {
  if (!confirm("¿Seguro que deseas retirar a este alumno?")) return;

  fetch(`${base}/alumnos/${clienteId}/clase/${claseNivelId}`, {
    method: "DELETE"
  })
    .then(res => {
      if (!res.ok) throw new Error("No se pudo retirar al alumno.");
      alert("Alumno retirado correctamente.");
      mostrarAlumnosClase(claseNivelId); // Recargar lista
    })
    .catch(err => alert("❌ Error al retirar alumno: " + err.message));
}

  function cerrarModalAlumnos() {
    document.getElementById("modalAlumnosClase").style.display = "none";
  }
  function abrirModalCrearClaseNivel() {
    document.getElementById("modalCrearClaseNivel").style.display = "block";
    cargarDatosCrearClaseNivel(); // carga selects y tabla
  }

  function cerrarModalCrearClaseNivel() {
    document.getElementById("modalCrearClaseNivel").style.display = "none";
  }
  let horarioSeleccionado = null;

  // Cargar los datos al abrir el modal
  function abrirModalCrearClaseNivel() {
    document.getElementById("modalCrearClaseNivel").style.display = "block";
    cargarDatosCrearClaseNivel();
  }

  function cerrarModalCrearClaseNivel() {
    document.getElementById("modalCrearClaseNivel").style.display = "none";
    horarioSeleccionado = null;
  }

  // Cargar clases, niveles, aulas y horario
  const BASE = "https://timbatumbao-back.onrender.com/api";

async function cargarDatosCrearClaseNivel() {
  try {
    const [clases, niveles, aulas, horarios] = await Promise.all([
      fetch(`${BASE}/clases`).then(r => r.json()),
      fetch(`${BASE}/niveles`).then(r => r.json()),
      Promise.resolve([{ id: 1, codigo: "A1" }, { id: 2, codigo: "A2" }, { id: 3, codigo: "A3" }]),
      fetch(`${BASE}/clase-nivel/horario-disponibilidad`).then(r => r.json())
    ]);

    llenarSelect("selectClase", clases);
    llenarSelect("selectNivel", niveles);
    llenarSelect("selectAula", aulas);

    document.getElementById("selectAula").value = aulas[0].id;
    document.getElementById("distintivo").value = aulas[0].codigo;

    últimosDatosHorarios = horarios;
    renderizarTablaHorario(últimosDatosHorarios);
  } catch (err) {
    alert("❌ Error al cargar datos: " + err.message);
  }
}



  function llenarSelect(id, lista) {
  const select = document.getElementById(id);
  select.innerHTML = "";
  lista.forEach(el => {
    const option = document.createElement("option");
    option.value = el.id;
    option.textContent = el.nombre || el.codigo || el.descripcion;
    select.appendChild(option);
  });
}

  let horariosSeleccionados = [];

function renderizarTablaHorario(celdas) {
  const contenedor = document.getElementById("contenedorTablasHorario");
  contenedor.innerHTML = "";

  const aulaSeleccionadaId = parseInt(document.getElementById("selectAula").value);
  const aulaSeleccionada = ["A1", "A2", "A3"][aulaSeleccionadaId - 1];
  const claseNivelIdEditando = document.getElementById("formCrearClaseNivel").getAttribute("data-id");

  const dias = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado"];
  const horas = [...new Set(celdas.map(c => c.hora))];

  const tabla = document.createElement("table");
  tabla.className = "horario-table";

  const thead = document.createElement("thead");
  const headerRow = document.createElement("tr");
  headerRow.innerHTML = `<th>${aulaSeleccionada}</th>` + dias.map(d => `<th>${d[0].toUpperCase() + d.slice(1)}</th>`).join("");
  thead.appendChild(headerRow);
  tabla.appendChild(thead);

  const tbody = document.createElement("tbody");

  horas.forEach(hora => {
    const fila = document.createElement("tr");
    fila.innerHTML = `<td>${hora}</td>`;

    dias.forEach(dia => {
      const celda = document.createElement("td");
      const dato = celdas.find(c => c.aula === aulaSeleccionada && c.dia === dia && c.hora === hora);

      if (dato) {
        const esMismoClaseNivel = claseNivelIdEditando && dato.claseNivelId == claseNivelIdEditando;

        if (dato.ocupado && !esMismoClaseNivel) {
          celda.className = "celda-ocupada";
          celda.textContent = "Ocupado";
          celda.title = `${dato.clase || 'Clase'} - ${dato.estado || ''}`;
        } else {
          celda.className = "celda-libre";
          celda.textContent = "Libre";

          const yaSeleccionada = horariosSeleccionados.some(h => h.horarioId === dato.horarioId);
          if (yaSeleccionada) celda.classList.add("celda-seleccionada");

          celda.onclick = () => {
            const index = horariosSeleccionados.findIndex(h => h.horarioId === dato.horarioId);
            if (index >= 0) {
              horariosSeleccionados.splice(index, 1);
              celda.classList.remove("celda-seleccionada");
            } else {
              horariosSeleccionados.push({ horarioId: dato.horarioId, aulaId: dato.aulaId });
              celda.classList.add("celda-seleccionada");
            }

            document.getElementById("infoHorarioSeleccionado").textContent =
              horariosSeleccionados.length > 0
                ? `${horariosSeleccionados.length} horario(s) seleccionado(s)`
                : "Ningún horario seleccionado";
          };
        }
      } else {
        celda.className = "celda-vacia";
        celda.textContent = "-";
      }

      fila.appendChild(celda);
    });

    tbody.appendChild(fila);
  });

  tabla.appendChild(tbody);
  contenedor.appendChild(tabla);
}






  // Autocompletar fecha de cierre = fecha de inicio
  document.getElementById("fechaInicio").addEventListener("change", function () {
    const fecha = new Date(this.value);
    if (!isNaN(fecha)) {
      const cierreStr = fecha.toISOString().split("T")[0];
      document.getElementById("fechaCierre").value = cierreStr;
      document.getElementById("fechaCierre").readOnly = true;
    }
  });
  // ✅ Detectar cambio de aula y volver a renderizar solo esa tabla
document.getElementById("selectAula").addEventListener("change", () => {
  renderizarTablaHorario(últimosDatosHorarios);
});


document.getElementById("formCrearClaseNivel").addEventListener("submit", async (e) => {
  e.preventDefault();

  const claseNivelId = document.getElementById("formCrearClaseNivel").getAttribute("data-id");
  const esEdicion = !!claseNivelId;

  if (horariosSeleccionados.length === 0) {
    alert("Debes seleccionar al menos un horario.");
    return;
  }

  const payload = {
    claseId: parseInt(document.getElementById("selectClase").value),
    nivelId: parseInt(document.getElementById("selectNivel").value),
    aulaId: parseInt(document.getElementById("selectAula").value),
    precio: parseFloat(document.getElementById("precio").value),
    aforo: parseInt(document.getElementById("aforo").value),
    estado: document.getElementById("estado").value,
    fechaInicio: document.getElementById("fechaInicio").value,
    fechaFin: document.getElementById("fechaFin").value,
    fechaCierre: document.getElementById("fechaCierre").value,
    distintivo: document.getElementById("distintivo").value,
    horariosIds: horariosSeleccionados.map(h => h.horarioId)
  };

  const url = esEdicion ? `${BASE}/clase-nivel/${claseNivelId}` : `${BASE}/clase-nivel/crear`;
  const metodo = esEdicion ? "PUT" : "POST";

  const res = await fetch(url, {
    method: metodo,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  const respuestaTexto = await res.text();
  console.log("Respuesta del backend:", respuestaTexto);

  if (res.ok) {
    alert(esEdicion ? "✅ ClaseNivel actualizada con éxito" : "✅ ClaseNivel creada con éxito");
    cerrarModalCrearClaseNivel();
  } else {
    alert("❌ Error: " + respuestaTexto);
  }
});


  function cerrarModalCrearClaseNivel() {
  document.getElementById("modalCrearClaseNivel").style.display = "none";
  document.getElementById("formCrearClaseNivel").removeAttribute("data-id");
  horariosSeleccionados = [];
  document.getElementById("infoHorarioSeleccionado").textContent = "Ningún horario seleccionado";
}
    function abrirModalCrearClaseNivel() {
      const form = document.getElementById("formCrearClaseNivel");
      form.removeAttribute("data-id"); // Limpia edición previa
      horariosSeleccionados = [];
      document.getElementById("infoHorarioSeleccionado").textContent = "Ningún horario seleccionado";
      document.getElementById("modalCrearClaseNivel").style.display = "flex";
      cargarDatosCrearClaseNivel(); // Carga desde cero
    }

  async function abrirSelectorHorario() {
    try {
      const res = await fetch(`${BASE}/clase-nivel/horario-disponibilidad`);
      if (!res.ok) throw new Error("No se pudo cargar la disponibilidad");
      const datos = await res.json();
      renderizarTablaHorario(datos);
      document.getElementById("modalHorario").style.display = "flex";
    } catch (e) {
      alert("Error al abrir selector: " + e.message);
    }
  }
