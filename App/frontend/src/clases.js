// Gestión de clases de baile

/**
 * Crea una clase de baile.
 *
 * @param {String} nombre
 * @param {String} nivel
 * @returns {Object}
 */
function crearClase(nombre, nivel) {
    if (
        typeof nombre !== "string" ||
        nombre.trim() === "" ||
        typeof nivel !== "string" ||
        nivel.trim() === ""
    ) {
        throw new Error("Nombre y nivel son obligatorios");
    }

    return {
        nombre: nombre.trim(),
        nivel: nivel.trim(),
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
    if (
        !clase ||
        typeof clase !== "object" ||
        !Array.isArray(clase.alumnosInscritos) ||
        typeof alumno !== "string" ||
        alumno.trim() === ""
    ) {
        throw new Error("Clase o alumno inválidos");
    }

    return {
        ...clase,
        alumnosInscritos: [...clase.alumnosInscritos, alumno.trim()]
    };
}

module.exports = {
    crearClase,
    inscribirAlumnoEnClase
};
