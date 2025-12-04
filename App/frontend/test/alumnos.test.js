const { registrarAlumno, buscarAlumno } = require("../src/alumno");

describe("Manejo de alumnos", () => {
    // ------------------ Test registrarAlumno (OK) ------------------
    test("registrarAlumno agrega un alumno a la lista", () => {
        const lista = [];
        const alumno = { nombre: "Andy", edad: 20 };

        const resultado = registrarAlumno(lista, alumno);

        expect(resultado.length).toBe(1);
        expect(resultado[0].nombre).toBe("Andy");
        expect(resultado[0].edad).toBe(20);
    });

    // ------------------ Test registrarAlumno (datos incompletos) ------------------
    test("registrarAlumno lanza error si los datos están incompletos", () => {
        const lista = [];
        const alumnoInvalido = { nombre: "SinEdad" }; // falta edad

        expect(() => registrarAlumno(lista, alumnoInvalido))
            .toThrow("Datos del alumno incompletos");
    });

    // ------------------ Test buscarAlumno (encuentra) ------------------
    test("buscarAlumno encuentra un alumno existente por nombre", () => {
        const lista = [
            { nombre: "Andy", edad: 20 },
            { nombre: "Luis", edad: 22 }
        ];

        const alumno = buscarAlumno(lista, "Luis");

        expect(alumno).not.toBeNull();
        expect(alumno.nombre).toBe("Luis");
        expect(alumno.edad).toBe(22);
    });

    // ------------------ Test buscarAlumno (no encuentra) ------------------
    test("buscarAlumno devuelve null si el alumno no existe", () => {
        const lista = [
            { nombre: "Andy", edad: 20 },
            { nombre: "Luis", edad: 22 }
        ];

        const alumno = buscarAlumno(lista, "Carlos");

        expect(alumno).toBeNull();
    });
});
