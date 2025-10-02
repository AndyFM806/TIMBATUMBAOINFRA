package infra.inscripcionesLambda.java;

public class InscripcionService {

    public static class ResultadoInscripcion {
        public final boolean exito;
        public final String mensaje;

        public ResultadoInscripcion(boolean exito, String mensaje) {
            this.exito = exito;
            this.mensaje = mensaje;
        }
    }

    public ResultadoInscripcion inscribirCliente(String nombreCliente, String correoCliente, String claseBaile, String fecha) {
        if (nombreCliente == null || nombreCliente.isEmpty() ||
            claseBaile == null || claseBaile.isEmpty()) {
            return new ResultadoInscripcion(false, "Faltan datos obligatorios para la inscripción.");
        }

        // Aquí podrías agregar lógica real, como verificar disponibilidad, guardar en base de datos, etc.
        String mensaje = String.format(
            "El cliente %s (%s) fue inscrito a la clase de %s en la fecha %s.",
            nombreCliente,
            correoCliente != null ? correoCliente : "correo no especificado",
            claseBaile,
            fecha != null ? fecha : "sin fecha asignada"
        );

        return new ResultadoInscripcion(true, mensaje);
    }
}
