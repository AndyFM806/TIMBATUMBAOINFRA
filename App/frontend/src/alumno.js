// Manejo de alumnos en una academia de baile

/**
 * Registra un nuevo alumno.
 *
 * @param {Array<Object>} listaAlumnos - Lista actual de alumnos.
 * @param {Object} alumno - Alumno a registrar.
 * @param {String} alumno.nombre - Nombre del alumno.
 * @param {Number} alumno.edad - Edad del alumno.
 * @returns {Array<Object>} Nueva lista con el alumno agregado.
 */
function registrarAlumno(listaAlumnos, alumno) {
    if (!alumno || !alumno.nombre || !alumno.edad) {
        throw new Error("Datos del alumno incompletos");
    }

    if (typeof alumno.nombre !== "string" || alumno.nombre.trim() === "") {
        throw new Error("El nombre del alumno no es válido");
    }

    if (typeof alumno.edad !== "number" || alumno.edad <= 0) {
        throw new Error("La edad del alumno no es válida");
    }

    return [...listaAlumnos, alumno];
}

/**
 * Busca un alumno por nombre en la lista.
 *
 * @param {Array<Object>} listaAlumnos - Lista de alumnos.
 * @param {String} nombre - Nombre a buscar.
 * @returns {Object|null} Alumno encontrado o null si no existe.
 */
function buscarAlumno(listaAlumnos, nombre) {
    if (!Array.isArray(listaAlumnos)) {
        throw new Error("La lista de alumnos no es válida");
    }

    if (typeof nombre !== "string" || nombre.trim() === "") {
        throw new Error("El nombre a buscar no es válido");
    }

    return listaAlumnos.find(a => a.nombre === nombre) || null;
}

module.exports = {
    registrarAlumno,
    buscarAlumno
};
