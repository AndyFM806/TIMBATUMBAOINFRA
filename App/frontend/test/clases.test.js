const { crearClase, inscribirAlumnoEnClase } = require("../src/clases");

describe("Gestión de clases de baile", () => {
    test("crearClase crea una clase sin alumnos inscritos", () => {
        const clase = crearClase("Salsa", "Intermedio");

        expect(clase.nombre).toBe("Salsa");
        expect(clase.nivel).toBe("Intermedio");
        expect(Array.isArray(clase.alumnosInscritos)).toBe(true);
        expect(clase.alumnosInscritos.length).toBe(0);
    });

    test("crearClase lanza error si falta nombre o nivel", () => {
        expect(() => crearClase("", "Intermedio")).toThrow("Nombre y nivel son obligatorios");
        expect(() => crearClase("Salsa", "")).toThrow("Nombre y nivel son obligatorios");
    });

    test("inscribirAlumnoEnClase agrega un alumno a la lista", () => {
        const clase = crearClase("Salsa", "Intermedio");
        const actualizada = inscribirAlumnoEnClase(clase, "Andy");

        expect(actualizada.alumnosInscritos.length).toBe(1);
        expect(actualizada.alumnosInscritos).toContain("Andy");
        // no muta el original
        expect(clase.alumnosInscritos.length).toBe(0);
    });

    test("inscribirAlumnoEnClase lanza error con datos inválidos", () => {
        const clase = crearClase("Salsa", "Intermedio");

        expect(() => inscribirAlumnoEnClase(null, "Andy"))
            .toThrow("Clase o alumno inválidos");
        expect(() => inscribirAlumnoEnClase(clase, ""))
            .toThrow("Clase o alumno inválidos");
    });
});
