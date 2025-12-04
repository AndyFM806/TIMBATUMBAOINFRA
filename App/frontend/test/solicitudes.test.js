const {
    crearSolicitud,
    formatearTipo,
    filtrarSolicitudesPorUsuario
} = require("../src/solicitudes");

describe("Gestión de solicitudes", () => {

    // -------- crearSolicitud --------
    test("crearSolicitud crea una solicitud con estado PENDIENTE", () => {
        const solicitud = crearSolicitud(
            1,
            "CAMBIO_CONTRASENA",
            "Olvidé mi contraseña"
        );

        expect(solicitud.usuarioId).toBe(1);
        expect(solicitud.tipoSolicitud).toBe("CAMBIO_CONTRASENA");
        expect(solicitud.detalle).toBe("Olvidé mi contraseña");
        expect(solicitud.estado).toBe("PENDIENTE");
        expect(solicitud.fechaCreacion).toBeInstanceOf(Date);
    });

    test("crearSolicitud lanza error con datos inválidos", () => {
        expect(() => crearSolicitud(0, "CAMBIO_CONTRASENA", "Detalle"))
            .toThrow("ID de usuario inválido");

        expect(() => crearSolicitud(1, "", "Detalle"))
            .toThrow("Tipo de solicitud inválido");

        expect(() => crearSolicitud(1, "CAMBIO_USUARIO", ""))
            .toThrow("El detalle de la solicitud es obligatorio");
    });

    // -------- formatearTipo --------
    test("formatearTipo devuelve textos legibles", () => {
        expect(formatearTipo("CAMBIO_CONTRASENA"))
            .toBe("Cambio de contraseña");
        expect(formatearTipo("CAMBIO_USUARIO"))
            .toBe("Cambio de usuario");
        expect(formatearTipo("OTRO_CUALQUIERA"))
            .toBe("Otro");
    });

    // -------- filtrarSolicitudesPorUsuario --------
    test("filtrarSolicitudesPorUsuario devuelve solo las del usuario indicado", () => {
        const solicitudes = [
            { usuarioId: 1, tipoSolicitud: "CAMBIO_CONTRASENA" },
            { usuarioId: 2, tipoSolicitud: "CAMBIO_USUARIO" },
            { usuarioId: 1, tipoSolicitud: "CAMBIO_USUARIO" }
        ];

        const resultado = filtrarSolicitudesPorUsuario(solicitudes, 1);

        expect(resultado.length).toBe(2);
        expect(resultado.every(s => s.usuarioId === 1)).toBe(true);
    });

    test("filtrarSolicitudesPorUsuario lanza error si la lista o el usuarioId son inválidos", () => {
        expect(() => filtrarSolicitudesPorUsuario(null, 1))
            .toThrow("La lista de solicitudes no es válida");
        expect(() => filtrarSolicitudesPorUsuario([], 0))
            .toThrow("ID de usuario inválido");
    });
});
