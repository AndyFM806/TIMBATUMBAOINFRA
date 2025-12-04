const { registrarAlumno, buscarAlumno } = require("../src/alumno");

describe("Manejo de alumnos", () => {
    // -------- registrarAlumno --------
    test("registrarAlumno agrega un alumno a la lista", () => {
        const lista = [];
        const alumno = { nombre: "Andy", edad: 20 };

        const resultado = registrarAlumno(lista, alumno);

        expect(resultado.length).toBe(1);
        expect(resultado[0]).toEqual(alumno);
    });

    test("registrarAlumno lanza error si faltan datos", () => {
        const lista = [];

        expect(() => registrarAlumno(lista, { nombre: "Andy" }))
            .toThrow("Datos del alumno incompletos");

        expect(() => registrarAlumno(lista, { edad: 20 }))
            .toThrow("Datos del alumno incompletos");

        expect(() => registrarAlumno(lista, null))
            .toThrow("Datos del alumno incompletos");
    });

    test("registrarAlumno lanza error si el nombre es inválido", () => {
        const lista = [];

        // nombre no string
        expect(() =>
            registrarAlumno(lista, { nombre: 123, edad: 20 })
        ).toThrow("El nombre del alumno no es válido");

        // nombre solo espacios (pasa el primer if, pero cae en el trim === "")
        expect(() =>
            registrarAlumno(lista, { nombre: "   ", edad: 20 })
        ).toThrow("El nombre del alumno no es válido");
    });

    test("registrarAlumno lanza error si la edad es inválida", () => {
        const lista = [];

        // edad negativa (truthy, pasa primer if)
        expect(() =>
            registrarAlumno(lista, { nombre: "Andy", edad: -5 })
        ).toThrow("La edad del alumno no es válida");

        // edad no numérica (truthy, pasa primer if)
        expect(() =>
            registrarAlumno(lista, { nombre: "Andy", edad: "20" })
        ).toThrow("La edad del alumno no es válida");
    });

    // -------- buscarAlumno --------
    test("buscarAlumno encuentra un alumno existente", () => {
        const lista = [
            { nombre: "Andy", edad: 20 },
            { nombre: "Luis", edad: 22 }
        ];

        const alumno = buscarAlumno(lista, "Luis");

        expect(alumno).not.toBeNull();
        expect(alumno.nombre).toBe("Luis");
        expect(alumno.edad).toBe(22);
    });

    test("buscarAlumno devuelve null si el alumno no existe", () => {
        const lista = [
            { nombre: "Andy", edad: 20 },
            { nombre: "Luis", edad: 22 }
        ];

        const alumno = buscarAlumno(lista, "Carlos");

        expect(alumno).toBeNull();
    });

    test("buscarAlumno lanza error si la lista no es un array", () => {
        expect(() => buscarAlumno(null, "Andy"))
            .toThrow("La lista de alumnos no es válida");

        expect(() => buscarAlumno({}, "Andy"))
            .toThrow("La lista de alumnos no es válida");
    });

    test("buscarAlumno lanza error si el nombre es inválido", () => {
        const lista = [{ nombre: "Andy", edad: 20 }];

        expect(() => buscarAlumno(lista, ""))
            .toThrow("El nombre a buscar no es válido");

        expect(() => buscarAlumno(lista, "   "))
            .toThrow("El nombre a buscar no es válido");

        expect(() => buscarAlumno(lista, 123))
            .toThrow("El nombre a buscar no es válido");
    });
});
