const {
    crearInscripcionDTO,
    decidirPasoPorSaldo,
    mensajePorEstadoPago
} = require("../src/registro");

describe("Lógica de registro de inscripciones", () => {

    // -------- crearInscripcionDTO --------
    test("crearInscripcionDTO construye correctamente el DTO", () => {
        const dto = crearInscripcionDTO({
            nombres: "Andy",
            apellidos: "Flores",
            correo: "andy@example.com",
            direccion: "Av. Siempre Viva 123",
            dni: "12345678",
            claseNivelId: 5,
            codigoNotaCredito: "NC-001"
        });

        expect(dto).toEqual({
            nombres: "Andy",
            apellidos: "Flores",
            correo: "andy@example.com",
            direccion: "Av. Siempre Viva 123",
            dni: "12345678",
            claseNivelId: 5,
            estado: "pendiente",
            codigoNotaCredito: "NC-001"
        });
    });

    test("crearInscripcionDTO pone null si no hay código de nota de crédito", () => {
        const dto = crearInscripcionDTO({
            nombres: "Andy",
            apellidos: "Flores",
            correo: "andy@example.com",
            direccion: "",
            dni: "12345678",
            claseNivelId: 5
        });

        expect(dto.codigoNotaCredito).toBeNull();
    });

    test("crearInscripcionDTO lanza error si faltan campos obligatorios", () => {
        // Falta nombres
        expect(() =>
            crearInscripcionDTO({
                apellidos: "Flores",
                correo: "andy@example.com",
                dni: "12345678",
                claseNivelId: 5
            })
        ).toThrow("Faltan datos obligatorios para la inscripción");

        // claseNivelId = 0 también cuenta como faltante
        expect(() =>
            crearInscripcionDTO({
                nombres: "Andy",
                apellidos: "Flores",
                correo: "andy@example.com",
                dni: "12345678",
                claseNivelId: 0
            })
        ).toThrow("Faltan datos obligatorios para la inscripción");
    });

    test("crearInscripcionDTO lanza error si el ID de clase/nivel es inválido", () => {
        // Aquí usamos un valor truthy pero inválido (-1)
        expect(() =>
            crearInscripcionDTO({
                nombres: "Andy",
                apellidos: "Flores",
                correo: "andy@example.com",
                dni: "12345678",
                claseNivelId: -1
            })
        ).toThrow("El ID de clase/nivel no es válido");
    });

    // -------- decidirPasoPorSaldo --------
    test("decidirPasoPorSaldo devuelve 'confirmacion' cuando saldo <= 0", () => {
        expect(decidirPasoPorSaldo(0)).toBe("confirmacion");
        expect(decidirPasoPorSaldo(-10)).toBe("confirmacion");
    });

    test("decidirPasoPorSaldo devuelve 'pago' cuando saldo > 0", () => {
        expect(decidirPasoPorSaldo(50)).toBe("pago");
    });

    test("decidirPasoPorSaldo lanza error si el saldo no es número", () => {
        expect(() => decidirPasoPorSaldo("no-numero"))
            .toThrow("El saldo pendiente no es válido");
    });

    // -------- mensajePorEstadoPago --------
    test("mensajePorEstadoPago devuelve el mensaje correcto según el estado", () => {
        expect(mensajePorEstadoPago("exito"))
            .toBe("🎉 ¡Pago realizado con éxito! Tu inscripción ha sido completada.");
        expect(mensajePorEstadoPago("fallo"))
            .toBe("❌ Hubo un problema con tu pago. Puedes intentar nuevamente.");
        expect(mensajePorEstadoPago("pendiente"))
            .toBe("⏳ Tu pago está pendiente. Te notificaremos cuando se confirme.");
    });

    test("mensajePorEstadoPago devuelve cadena vacía para estados desconocidos", () => {
        expect(mensajePorEstadoPago("otro")).toBe("");
        expect(mensajePorEstadoPago(undefined)).toBe("");
    });
});
