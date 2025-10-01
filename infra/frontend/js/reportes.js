const BASE = "https://timbatumbao-back.onrender.com";

async function consultarInscripciones() {
  const desde = document.getElementById("fechaDesde").value;
  const hasta = document.getElementById("fechaHasta").value;

  let url = `${BASE}/api/inscripciones/aprobadas`;
  const res = await fetch(url);
  const data = await res.json();

  const tbody = document.querySelector("#tablaInscripciones tbody");
  tbody.innerHTML = "";

  let total = 0;

  data.forEach(insc => {
    const fecha = new Date(insc.fechaInscripcion).toLocaleDateString();
    const monto = insc.claseNivel.precio || 0;
    total += monto;

    tbody.innerHTML += `
      <tr>
        <td>${insc.cliente.nombres} ${insc.cliente.apellidos}</td>
        <td>${insc.cliente.dni}</td>
        <td>${insc.claseNivel.clase.nombre}</td>
        <td>${insc.claseNivel.nivel.nombre}</td>
        <td>${insc.estado}</td>
        <td>${fecha}</td>
        <td>S/ ${monto.toFixed(2)}</td>
      </tr>`;
  });

  document.getElementById("totalInscripciones").innerText = `S/ ${total.toFixed(2)}`;
}

async function descargarReporteInscripcionesPDF() {
  const desde = document.getElementById("fechaDesde").value;
  const hasta = document.getElementById("fechaHasta").value;
  const params = new URLSearchParams();
  if (desde) params.append("desde", desde);
  if (hasta) params.append("hasta", hasta);

  const res = await fetch(`${BASE}/api/reportes/reporte-general?${params}`, {
    headers: { Accept: "application/pdf" }
  });

  const blob = await res.blob();
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "reporte_inscripciones.pdf";
  a.click();
  URL.revokeObjectURL(url);
}

async function cargarClaseNiveles() {
  const res = await fetch(`${BASE}/api/clase-nivel/abiertas`);
  const data = await res.json();
  const select = document.getElementById("claseNivelSelect");
  select.innerHTML = '<option value="">Seleccionar...</option>';
  data.forEach(cn => {
    const label = `${cn.clase.nombre} - ${cn.nivel.nombre}`;
    select.innerHTML += `<option value="${cn.id}">${label}</option>`;
    if (cn.aula) {
      select.options[select.options.length - 1].text += ` (Aula: ${cn.aula.codigo})`;
    }
  });
}

async function cargarAlumnosPorClase() {
  const id = document.getElementById("claseNivelSelect").value;
  if (!id) return;

  const res = await fetch(`${BASE}/api/clase-nivel/${id}/alumnos`);
  const data = await res.json();
  const tbody = document.querySelector("#tablaAlumnos tbody");
  tbody.innerHTML = "";

  data.forEach((alumno, i) => {
    tbody.innerHTML += `
      <tr>
        <td>${i + 1}</td>
        <td>${alumno.nombres} ${alumno.apellidos}</td>
        <td>${alumno.dni}</td>
      </tr>`;
  });
}

async function descargarAlumnosPDF() {
  const id = document.getElementById("claseNivelSelect").value;
  if (!id) return alert("Selecciona una clase-nivel");

  const res = await fetch(`${BASE}/api/reportes/alumnos-por-clase?id=${id}`, {
    headers: { Accept: "application/pdf" }
  });

  const blob = await res.blob();
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "alumnos_por_clase.pdf";
  a.click();
  URL.revokeObjectURL(url);
}

// Cargar clases al iniciar
document.addEventListener("DOMContentLoaded", () => {
  cargarClaseNiveles();
});
