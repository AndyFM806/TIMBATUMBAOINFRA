const API = "https://timbatumbao-back.onrender.com/api/auth";
const API_USUARIOS = "https://timbatumbao-back.onrender.com/api/usuarios";

// 🔐 Login
document.getElementById("formLogin").addEventListener("submit", async (e) => {
  e.preventDefault();

  const nombreUsuario = document.getElementById("username").value.trim();
  const contrasena = document.getElementById("password").value;

  if (!nombreUsuario || !contrasena) {
    mostrarMensaje("Por favor, complete todos los campos.");
    return;
  }

  try {
    const res = await fetch(`${API}/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ nombreUsuario, contrasena }),
    });

    if (res.ok) {
      const usuario = await res.json();
      sessionStorage.setItem("usuario", JSON.stringify(usuario));

      // Redirige al panel de administrador
      window.location.href = "../html/admin_panel.html";
    } else {
      mostrarMensaje("Credenciales inválidas. Intenta nuevamente.");
    }

  } catch (error) {
    console.error("Error en el login:", error);
    mostrarMensaje("Error al conectar con el servidor.");
  }
});

// 🔁 Mostrar mensaje general
function mostrarMensaje(texto, color = "red") {
  const mensaje = document.getElementById("mensaje");
  mensaje.textContent = texto;
  mensaje.style.color = color;
}

// 🔁 Mostrar recuperación (admin + recepcionista)
function mostrarRecuperacion() {
  document.getElementById("recuperacion").style.display = "block"; // admin
  document.getElementById("solicitudRecepcionista").style.display = "block"; // recepcionista
}

// 🔐 Solicitar código para admin
function solicitarCodigo() {
  fetch(`${API_USUARIOS}/recuperar`, {
    method: "POST"
  })
  .then(res => {
    if (res.ok) {
      mostrarMensaje("✅ Código enviado a tu correo.", "green");
    } else {
      mostrarMensaje("No se pudo enviar el código.");
    }
  })
  .catch(() => {
    mostrarMensaje("Error al solicitar código.");
  });
}

// 🔐 Validar código recibido (admin)
function validarCodigo() {
  const codigo = document.getElementById("codigoRecuperacion").value.trim();
  const nuevaContrasena = document.getElementById("nuevaContrasena").value.trim();

  if (!codigo || !nuevaContrasena) {
    mostrarMensaje("Por favor, complete ambos campos.");
    return;
  }

  fetch(`${API_USUARIOS}/validar-codigo`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ codigo, nuevaContrasena })
  })
  .then(res => res.text())
  .then(msg => {
    mostrarMensaje(msg, "green");
  })
  .catch(() => {
    mostrarMensaje("Error al validar código.");
  });
}

// 📩 Enviar solicitud de recuperación (recepcionista)
async function enviarSolicitud() {
  const usernameInput = document.getElementById("usuarioSolicitud");
  const detalleInput = document.getElementById("detalleSolicitud");
  const mensaje = document.getElementById("mensajeSolicitud");

  const username = usernameInput.value.trim();
  const detalle = detalleInput.value.trim();

  if (!username || !detalle) {
    mensaje.style.color = "orange";
    mensaje.textContent = "⚠️ Completa todos los campos.";
    return;
  }

  try {
    const resUsuario = await fetch(`${API_USUARIOS}/public/usuario-por-nombre/${username}`);
    if (!resUsuario.ok) {
      mensaje.style.color = "orange";
      mensaje.textContent = "⚠️ El usuario no existe.";
      return;
    }

    const usuario = await resUsuario.json();

    const solicitud = {
      usuario: { id: usuario.id },
      tipoSolicitud: "CAMBIO_CONTRASENA",
      detalle: detalle
    };

    const resSolicitud = await fetch("https://timbatumbao-back.onrender.com/api/solicitudes", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(solicitud)
    });

    if (resSolicitud.ok) {
      mensaje.style.color = "green";
      mensaje.textContent = "✅ Solicitud enviada correctamente.";
      usernameInput.value = "";
      detalleInput.value = "";
    } else {
      mensaje.style.color = "red";
      mensaje.textContent = "❌ Error al enviar solicitud.";
    }

  } catch (error) {
    console.error(error);
    mensaje.style.color = "red";
    mensaje.textContent = "❌ Error al validar o enviar la solicitud.";
  }
}

// 📄 Acceder a historial de solicitudes
function accederAHistorial() {
  const usuario = document.getElementById("usuarioSolicitud").value;
  const mensaje = document.getElementById("mensajeSolicitud");

  if (!usuario) {
    mensaje.style.color = "orange";
    mensaje.textContent = "⚠️ Debes ingresar tu nombre de usuario.";
    return;
  }

  sessionStorage.setItem("usuarioTemporal", usuario);
  window.location.href = "solicitudes.html";
}
