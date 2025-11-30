const { registrarAlumno, buscarAlumno } = require("../src/alumnos");

console.log("==== TEST: alumnos.js ====");

// ------------------ Test registrarAlumno ------------------
try {
    const lista = [];
    const alumno = { nombre: "Andy", edad: 20 };

    const resultado = registrarAlumno(lista, alumno);

    console.assert(resultado.length === 1, "El alumno debe ser agregado");
    console.assert(resultado[0].nombre === "Andy", "El nombre debe coincidir");

    console.log("✔ registrarAlumno OK");
} catch (e) {
    console.error("✘ registrarAlumno FAIL:", e.message);
}

// ------------------ Test buscarAlumno ------------------
try {
    const lista = [
        { nombre: "Andy", edad: 20 },
        { nombre: "Luis", edad: 22 }
    ];

    const alumno = buscarAlumno(lista, "Luis");

    console.assert(alumno !== null, "Debe encontrar el alumno");
    console.assert(alumno.nombre === "Luis", "El nombre debe coincidir");

    console.log("✔ buscarAlumno OK");
} catch (e) {
    console.error("✘ buscarAlumno FAIL:", e.message);
}

console.log();