const BASE = "https://timbatumbao-back.onrender.com/api";

async function cargarHorarioAula() {
  const aulaId = parseInt(document.getElementById("selectAulaHorario").value);
  try {
    const res = await fetch(`${BASE}/clase-nivel/horario-disponibilidad`);
    if (!res.ok) throw new Error("Error al obtener horarios");

    const datos = await res.json();
    const filtrado = datos.filter(c => c.aulaId === aulaId);

    renderizarHorarioAula(filtrado);
  } catch (err) {
    alert("❌ Error al cargar horario: " + err.message);
  }
}

function renderizarHorarioAula(celdas) {
  const contenedor = document.getElementById("contenedorHorarioAula");
  contenedor.innerHTML = "";

  const dias = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado"];
  const horas = [...new Set(celdas.map(c => c.hora))];

  const tabla = document.createElement("table");
  tabla.className = "horario-aula-table";

  const thead = document.createElement("thead");
  const trHead = document.createElement("tr");
  trHead.innerHTML = `<th>Hora</th>` + dias.map(d => `<th>${d.charAt(0).toUpperCase() + d.slice(1)}</th>`).join("");
  thead.appendChild(trHead);
  tabla.appendChild(thead);

  const tbody = document.createElement("tbody");
  horas.forEach(hora => {
    const fila = document.createElement("tr");
    fila.innerHTML = `<td><strong>${hora}</strong></td>`;

    dias.forEach(dia => {
      const celda = document.createElement("td");
      const dato = celdas.find(c => c.dia === dia && c.hora === hora);

      if (dato && dato.ocupado) {
        celda.className = "horario-celda-ocupada";
        celda.innerHTML = `
          <div><strong>ID: ${dato.claseNivelId}</strong></div>
          <div>${dato.clase}</div>
        `;
      } else {
        celda.className = "horario-celda-libre";
        celda.textContent = "Libre";
      }

      fila.appendChild(celda);
    });

    tbody.appendChild(fila);
  });

  tabla.appendChild(tbody);
  contenedor.appendChild(tabla);
}

window.onload = () => {
  cargarHorarioAula();
};
