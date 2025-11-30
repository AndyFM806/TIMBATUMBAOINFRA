const { crearClase, inscribirAlumnoEnClase } = require("../src/clases");

console.log("==== TEST: clases.js ====");

// ------------------ Test crearClase ------------------
try {
    const clase = crearClase("Salsa", "Intermedio");

    console.assert(clase.nombre === "Salsa", "El nombre debe ser Salsa");
    console.assert(clase.nivel === "Intermedio", "El nivel debe ser Intermedio");
    console.assert(Array.isArray(clase.alumnosInscritos), "Debe contener lista de alumnos");

    console.log("✔ crearClase OK");
} catch (e) {
    console.error("✘ crearClase FAIL:", e.message);
}

// ------------------ Test inscribirAlumnoEnClase ------------------
try {
    const clase = crearClase("Salsa", "Intermedio");
    const claseActualizada = inscribirAlumnoEnClase(clase, "Andy");

    console.assert(claseActualizada.alumnosInscritos.length === 1, "Debe tener un alumno inscrito");
    console.assert(claseActualizada.alumnosInscritos[0] === "Andy", "Debe inscribir Andy");

    console.log("✔ inscribirAlumnoEnClase OK");
} catch (e) {
    console.error("✘ inscribirAlumnoEnClase FAIL:", e.message);
}

console.log();