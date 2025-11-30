// Gestión de clases de baile

/**
 * Crea una clase de baile.
 *
 * @param {String} nombre
 * @param {String} nivel
 * @returns {Object}
 */
function crearClase(nombre, nivel) {
    if (!nombre || !nivel) {
        throw new Error("Nombre y nivel son obligatorios");
    }
    return {
        nombre,
        nivel,
        alumnosInscritos: []
    };
}

/**
 * Inscribe a un alumno en una clase
 *
 * @param {Object} clase
 * @param {String} alumno
 * @returns {Object} Clase actualizada
 */
function inscribirAlumnoEnClase(clase, alumno) {
    if (!clase || !alumno) {
        throw new Error("Clase o alumno inválidos");
    }
    return {
        ...clase,
        alumnosInscritos: [...clase.alumnosInscritos, alumno]
    };
}

module.exports = {
    crearClase,
    inscribirAlumnoEnClase
};