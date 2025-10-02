const baseUrl = "https://timbatumbao-back.onrender.com/api/inscripciones";
let todas = [];

window.onload = () => {
  fetch(`${baseUrl}`)
    .then(res => res.json())
    .then(data => {
      todas = data;
      mostrar(todas);
    });
};

function mostrar(lista) {
  const contenedor = document.getElementById("contenidoTabla");
  contenedor.innerHTML = "";
    lista.sort((a, b) => new Date(b.fechaInscripcion) - new Date(a.fechaInscripcion));

    function formatearFecha(fechaIso) {
    const f = new Date(fechaIso);
    return f.toLocaleDateString("es-PE", { year: 'numeric', month: '2-digit', day: '2-digit' });
    }

  lista.forEach(insc => {
    const fila = document.createElement("tr");

    const cliente = `${insc.cliente.nombres} ${insc.cliente.apellidos}`;
    const dni = insc.cliente.dni;
    const claseNivel = `${insc.claseNivel.clase.nombre} - ${insc.claseNivel.nivel.nombre}`;
    const precio = insc.montoPendiente ?? insc.claseNivel.precio;
    const estado = insc.estado;
    const comprobante = insc.comprobanteUrl
      ? `<a href="${insc.comprobanteUrl}" target="_blank">Ver</a>` : "—";
      const fecha = formatearFecha(insc.fechaInscripcion);

    let acciones = "";

    if (estado === "pendiente") {
      acciones += `<button class="accion aprobar" onclick="aprobar(${insc.id})">Aprobar</button>`;
      acciones += `<button class="accion rechazar" onclick="rechazar(${insc.id})">Rechazar</button>`;
    }

    if (estado === "pendiente_pago_diferencia") {
      acciones += `<button class="accion pago" onclick="generarPago(${insc.id})">Pagar diferencia</button>`;
    }

    fila.innerHTML = `
      <td>${cliente}</td>
      <td>${dni}</td>
      <td>${claseNivel}</td>
      <td>S/ ${precio.toFixed(2)}</td>
      <td>${estado}</td>
      <td>${comprobante}</td>
      <td>${fecha}</td>
      <td>${acciones}</td>
    `;

    contenedor.appendChild(fila);
  });
}

function cargarPorEstado(estado) {
  if (estado === 'todos') return mostrar(todas);
  const filtradas = todas.filter(i => i.estado === estado);
  mostrar(filtradas);
}

function verConComprobante() {
  fetch(`${baseUrl}/pendientes-con-comprobante`)
    .then(res => res.json())
    .then(data => mostrar(data));
}

function verConDiferencia() {
  fetch(`${baseUrl}/pendientes-diferencia`)
    .then(res => res.json())
    .then(data => mostrar(data));
}

function buscar() {
  const texto = document.getElementById("buscarTexto").value.toLowerCase();
  const resultados = todas.filter(i =>
    i.cliente.nombres.toLowerCase().includes(texto) ||
    i.cliente.apellidos?.toLowerCase().includes(texto) ||
    i.cliente.dni.includes(texto)
  );
  mostrar(resultados);
}

function aprobar(id) {
  fetch(`${baseUrl}/${id}/aprobar-manual`, { method: "PATCH" })
    .then(() => window.location.reload());
}

function rechazar(id) {
  fetch(`${baseUrl}/${id}/rechazar`, { method: "PATCH" })
    .then(() => window.location.reload());
}

function generarPago(id) {
  fetch(`${baseUrl}/generar-pago/${id}`, { method: "POST" })
    .then(res => res.text())
    .then(link => window.open(link, "_blank"));
}
