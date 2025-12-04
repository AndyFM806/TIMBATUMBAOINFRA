// Lógica de registro de inscripciones para una academia de baile

/**
 * Crea el DTO de inscripción a partir de los datos del formulario.
 *
 * @param {Object} datos
 * @param {String} datos.nombres
 * @param {String} datos.apellidos
 * @param {String} datos.correo
 * @param {String} [datos.direccion]
 * @param {String} datos.dni
 * @param {Number} datos.claseNivelId
 * @param {String} [datos.codigoNotaCredito]
 * @returns {Object} inscripcionDTO
 */
function crearInscripcionDTO(datos) {
    const {
        nombres,
        apellidos,
        correo,
        direccion = "",
        dni,
        claseNivelId,
        codigoNotaCredito
    } = datos || {};

    if (!nombres || !apellidos || !correo || !dni || !claseNivelId) {
        throw new Error("Faltan datos obligatorios para la inscripción");
    }

    if (typeof claseNivelId !== "number" || claseNivelId <= 0) {
        throw new Error("El ID de clase/nivel no es válido");
    }

    return {
        nombres: nombres.trim(),
        apellidos: apellidos.trim(),
        correo: correo.trim(),
        direccion: direccion.trim(),
        dni: dni.trim(),
        claseNivelId,
        estado: "pendiente",
        codigoNotaCredito: codigoNotaCredito
            ? codigoNotaCredito.trim()
            : null
    };
}

/**
 * Decide el siguiente paso del flujo según el saldo pendiente.
 *
 * @param {Number} saldoPendiente
 * @returns {String} "confirmacion" si no debe pagar, "pago" si aún debe.
 */
function decidirPasoPorSaldo(saldoPendiente) {
    if (typeof saldoPendiente !== "number" || isNaN(saldoPendiente)) {
        throw new Error("El saldo pendiente no es válido");
    }

    return saldoPendiente <= 0 ? "confirmacion" : "pago";
}

/**
 * Devuelve el mensaje de confirmación según el estado del pago recibido por URL.
 *
 * @param {String} estado - "exito" | "fallo" | "pendiente" | otro
 * @returns {String} mensaje a mostrar al usuario
 */
function mensajePorEstadoPago(estado) {
    switch (estado) {
        case "exito":
            return "🎉 ¡Pago realizado con éxito! Tu inscripción ha sido completada.";
        case "fallo":
            return "❌ Hubo un problema con tu pago. Puedes intentar nuevamente.";
        case "pendiente":
            return "⏳ Tu pago está pendiente. Te notificaremos cuando se confirme.";
        default:
            return "";
    }
}

module.exports = {
    crearInscripcionDTO,
    decidirPasoPorSaldo,
    mensajePorEstadoPago
};
