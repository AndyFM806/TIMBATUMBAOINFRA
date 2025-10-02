document.addEventListener("DOMContentLoaded", () => {
  const usuario = JSON.parse(sessionStorage.getItem("usuario"));
  if (!usuario) {
    window.location.href = "../html/login.html";
    return;
  }

  const rolUsuario = usuario.rol.toLowerCase(); // ⬅️ Agrega esta línea
  const accesos = usuario.modulos.map(m => m.nombre.toLowerCase());

  const ordenDeseado = ["inscripciones", "clases", "alumnos", "usuarios", "reportes", "horario"];
  const iconos = {
    "inscripciones": "📄",
    "clases": "🕒",
    "alumnos": "🎓",
    "usuarios": "👥",
    "reportes": "📊",
    "horario": "📅"
  };

  const contenedor = document.getElementById("botonesPanel");

  ordenDeseado.forEach(modulo => {
    if (accesos.includes(modulo)) {
      const btn = document.createElement("button");
      btn.className = "modulo-btn";
      btn.innerHTML = `<i style="font-size:30px;display:block;">${iconos[modulo]}</i>${capitalize(modulo)}`;
      btn.onclick = () => window.location.href = `${modulo}.html`;
      // Puedes agregar estilos directamente aquí:
      btn.style.margin = "14px";
      btn.style.backgroundColor = "#4fc3f7";
      btn.style.borderRadius = "10px";
      btn.style.border = "1px solid #2196f3";
      btn.style.padding = "18px 36px";
      btn.style.fontSize = "22px";
      btn.style.cursor = "pointer";
      btn.style.color = "#fff";
      btn.style.boxShadow = "0 2px 8px rgba(33,150,243,0.15)";
      contenedor.appendChild(btn);
    }
  });

  // ✅ Mostrar botón de "Solicitudes" solo si el rol es recepcionista
  if (rolUsuario === "recepcionista") {
    const btnSolicitudes = document.createElement("button");
    btnSolicitudes.className = "modulo-btn";
    btnSolicitudes.innerHTML = `<i style="font-size:30px;display:block;">📬</i>Solicitudes`;
    btnSolicitudes.onclick = () => window.location.href = "solicitudes.html";
    contenedor.appendChild(btnSolicitudes);
  }

  // ✅ Botón de cerrar sesión

});

function capitalize(texto) {
  return texto.charAt(0).toUpperCase() + texto.slice(1);
}
