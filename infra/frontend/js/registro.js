let inscripcionId = null;

function mostrarPaso(idPaso) {
  document.querySelectorAll('.step').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.progress-bar div').forEach(p => p.classList.remove('active'));
  document.getElementById(idPaso).classList.add('active');

  if (idPaso === 'datos-personales') document.getElementById('step1').classList.add('active');
  else if (idPaso === 'pago') document.getElementById('step2').classList.add('active');
  else if (idPaso === 'confirmacion') document.getElementById('step3').classList.add('active');
}

document.addEventListener('DOMContentLoaded', () => {
  const params = new URLSearchParams(window.location.search);
  const claseNivelId = parseInt(params.get('id'));
  
  const nivel = params.get('nivel');
  const precio = params.get('precio');
  const estado = params.get('estado');

  document.getElementById('clase-seleccionada').value = `| Precio de la Clase: S/${precio || 'N/A'}`;

  // Redirección por estado
  if (estado === "exito") {
    mostrarPaso("confirmacion");
    document.getElementById("mensaje-confirmacion").textContent = "🎉 ¡Pago realizado con éxito! Tu inscripción ha sido completada.";

    // Obtener inscripcionId de la URL si está disponible
    let inscripcionIdParam = params.get('inscripcionId');
    if (inscripcionIdParam) {
      inscripcionId = parseInt(inscripcionIdParam);
    }

    // Enviar correo de bienvenida
    if (inscripcionId) {
      fetch(`https://timbatumbao-back.onrender.com/api/inscripciones/${inscripcionId}/enviar-bienvenida`, {
        method: 'POST'
      }).catch(err => {
        console.error("Error enviando correo de bienvenida:", err);
      });
    }

    return;
  }
  if (estado === "fallo") {
    mostrarPaso("confirmacion");
    document.getElementById("mensaje-confirmacion").textContent = "❌ Hubo un problema con tu pago. Puedes intentar nuevamente.";
    return;
  }
  if (estado === "pendiente") {
    mostrarPaso("confirmacion");
    document.getElementById("mensaje-confirmacion").textContent = "⏳ Tu pago está pendiente. Te notificaremos cuando se confirme.";
    return;
  }

  // Paso 1: Registro
  window.registrarPaso1 = () => {
    const nombres = document.getElementById("nombres").value.trim();
    const apellidos = document.getElementById("apellidos").value.trim();
    const correo = document.getElementById("correo").value.trim();
    const direccion = document.getElementById("direccion").value.trim();
    const dni = document.getElementById("dni").value.trim();
    const codigoNotaCredito = document.getElementById("codigoNotaCredito").value.trim();

    if (!nombres || !apellidos || !correo || !dni || !claseNivelId) {
      alert("Por favor completa todos los campos obligatorios.");
      return;
    }

    const inscripcionDTO = {
      nombres,
      apellidos,
      correo,
      direccion,
      dni,
      claseNivelId,
      estado: "pendiente",
      codigoNotaCredito: codigoNotaCredito || null
    };

    fetch('https://timbatumbao-back.onrender.com/api/inscripciones', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(inscripcionDTO)
    })
    .then(async res => {
      if (!res.ok) {
        const errorMsg = await res.text();
        throw new Error(errorMsg || "Registro inválido");
      }
      return res.text();
    })
   .then(text => {
      const match = text.match(/\d+/);
      inscripcionId = match ? parseInt(match[0]) : null;
      if (!inscripcionId) throw new Error("No se pudo obtener el ID de inscripción");

      // Verificar saldo
      return fetch(`https://timbatumbao-back.onrender.com/api/inscripciones/${inscripcionId}/saldo`);
    })
    .then(res => {
      if (!res.ok) throw new Error("No se pudo verificar el saldo");
      return res.json();
    })
    .then(saldoDTO => {
      document.getElementById("info-saldo").textContent =
  `Saldo pendiente: S/${saldoDTO.saldoPendiente.toFixed(2)}`;

      if (saldoDTO.saldoPendiente <= 0) {
        mostrarPaso("confirmacion");
        document.getElementById("mensaje-confirmacion").textContent = "✅ Ya no necesitas pagar. Tu inscripción ha sido completada automáticamente.";
      } else {
        mostrarPaso('pago');
      }
    })
 
    .catch(err => {
      alert("❌ Error al registrar inscripción: " + err.message);
      console.error("Error en fetch:", err);
    });
  };

  // Paso 2: Subir comprobante
  window.subirComprobante = () => {
    const archivo = document.getElementById('comprobante').files[0];
    if (!archivo || !inscripcionId) {
      alert("Debes registrar tus datos y subir un comprobante JPG.");
      return;
    }

    const formData = new FormData();
    formData.append("file", archivo);

    fetch(`https://timbatumbao-back.onrender.com/api/inscripciones/comprobante/${inscripcionId}`, {
      method: 'POST',
      body: formData
    })
    .then(res => {
      if (!res.ok) throw new Error(`Error al subir comprobante. Código: ${res.status}`);
      mostrarPaso('confirmacion');
      document.getElementById("mensaje-confirmacion").textContent = "Tu inscripción está en espera de aprobación.";
    })
    .catch(err => {
      alert("❌ Error al subir el comprobante.");
      console.error("Error subiendo comprobante:", err);
    });
  };

  // Paso 2: Pagar con pasarela
  window.pagarConPasarela = () => {
    if (!inscripcionId) {
      alert("Debes completar tus datos antes de pagar.");
      return;
    }

    fetch(`https://timbatumbao-back.onrender.com/api/inscripciones/generar-pago/${inscripcionId}`, {
      method: 'POST'
    })
    .then(async res => {
      if (!res.ok) {
        const error = await res.text();
        throw new Error(error || "Error generando enlace");
      }
      return res.text();
    })
    .then(init_point => {
      if (!init_point.startsWith("http")) {
        throw new Error("Respuesta inválida: " + init_point);
      }
      window.location.href = init_point;
    })
    .catch(err => {
      alert("❌ Error al generar enlace de pago.");
      console.error("Error pasarela:", err);
    });
  };
});
