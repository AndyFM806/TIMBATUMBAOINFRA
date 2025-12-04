// Manejo de alumnos en una academia de baile

/**
 * Registra un nuevo alumno.
 *
 * @param {Array} listaAlumnos - Lista actual de alumnos.
 * @param {Object} alumno - Alumno a registrar.
 * @returns {Array} Nueva lista con el alumno agregado.
 */
function registrarAlumno(listaAlumnos, alumno) {
    if (!alumno || !alumno.nombre || !alumno.edad) {
        throw new Error("Datos del alumno incompletos");
    }
    return [...listaAlumnos, alumno];
}

/**
 * Busca un alumno por nombre en la lista.
 *
 * @param {Array} listaAlumnos
 * @param {String} nombre
 * @returns {Object|null}
 */
function buscarAlumno(listaAlumnos, nombre) {
    return listaAlumnos.find(a => a.nombre === nombre) || null;
}

module.exports = {
    registrarAlumno,
    buscarAlumno
};