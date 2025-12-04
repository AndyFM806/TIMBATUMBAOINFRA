// Gestión de solicitudes (ej. cambio de contraseña / usuario)

/**
 * Crea una nueva solicitud.
 *
 * @param {Number} usuarioId - ID del usuario que realiza la solicitud.
 * @param {String} tipoSolicitud - Tipo de solicitud (ej: "CAMBIO_CONTRASENA").
 * @param {String} detalle - Detalle de la solicitud.
 * @returns {Object} Solicitud creada.
 */
function crearSolicitud(usuarioId, tipoSolicitud, detalle) {
    if (typeof usuarioId !== "number" || usuarioId <= 0) {
        throw new Error("ID de usuario inválido");
    }

    if (typeof tipoSolicitud !== "string" || tipoSolicitud.trim() === "") {
        throw new Error("Tipo de solicitud inválido");
    }

    if (typeof detalle !== "string" || detalle.trim() === "") {
        throw new Error("El detalle de la solicitud es obligatorio");
    }

    return {
        usuarioId,
        tipoSolicitud: tipoSolicitud.trim(),
        detalle: detalle.trim(),
        estado: "PENDIENTE",
        fechaCreacion: new Date()
    };
}

/**
 * Devuelve un texto legible para el tipo de solicitud.
 *
 * @param {String} tipoSolicitud
 * @returns {String}
 */
function formatearTipo(tipoSolicitud) {
    switch (tipoSolicitud) {
        case "CAMBIO_CONTRASENA":
            return "Cambio de contraseña";
        case "CAMBIO_USUARIO":
            return "Cambio de usuario";
        default:
            return "Otro";
    }
}

/**
 * Filtra las solicitudes de un usuario específico.
 *
 * @param {Array<Object>} listaSolicitudes
 * @param {Number} usuarioId
 * @returns {Array<Object>} Solicitudes del usuario.
 */
function filtrarSolicitudesPorUsuario(listaSolicitudes, usuarioId) {
    if (!Array.isArray(listaSolicitudes)) {
        throw new Error("La lista de solicitudes no es válida");
    }

    if (typeof usuarioId !== "number" || usuarioId <= 0) {
        throw new Error("ID de usuario inválido");
    }

    return listaSolicitudes.filter(s => s.usuarioId === usuarioId);
}

module.exports = {
    crearSolicitud,
    formatearTipo,
    filtrarSolicitudesPorUsuario
};
