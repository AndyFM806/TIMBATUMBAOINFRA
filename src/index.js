
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const { Client } = require("pg");

// Variable global para reutilizar el cliente de la base de datos
let dbClient;

/**
 * Obtiene las credenciales de la base de datos desde AWS Secrets Manager.
 */
async function getDbSecret() {
    const secretArn = process.env.DB_SECRET_ARN;
    const client = new SecretsManagerClient({ region: process.env.AWS_REGION });

    try {
        const command = new GetSecretValueCommand({ SecretId: secretArn });
        const response = await client.send(command);
        return JSON.parse(response.SecretString);
    } catch (error) {
        console.error("ERROR: No se pudo obtener el secreto de la base de datos:", error);
        throw error;
    }
}

/**
 * Crea y devuelve un cliente de base de datos conectado.
 */
async function getDbClient(dbCreds) {
    if (!dbClient) {
        try {
            dbClient = new Client({
                host: dbCreds.host,
                port: dbCreds.port,
                user: dbCreds.username,
                password: dbCreds.password,
                database: dbCreds.dbname,
                ssl: { rejectUnauthorized: false } // Ajusta según la configuración de tu RDS
            });
            await dbClient.connect();
        } catch (error) {
            console.error("ERROR: No se pudo conectar a la base de datos:", error);
            throw error;
        }
    }
    return dbClient;
}

/**
 * Handler principal de la función Lambda.
 */
exports.handler = async (event) => {
    try {
        // 1. Obtener credenciales y conectar a la BD
        const dbCredentials = await getDbSecret();
        const client = await getDbClient(dbCredentials);

        // 2. Obtener parámetro de nivel y construir la consulta
        const level = event.queryStringParameters ? event.queryStringParameters.level : null;
        
        let query;
        const params = [];

        if (level) {
            // IMPORTANTE: ¡DEBES CAMBIAR ESTA CONSULTA POR LA TUYA!
            query = "SELECT nivel, dias, hora, precio, aforo, estado, fecha_inicio, fecha_fin FROM cursos WHERE nivel = $1;";
            params.push(level);
        } else {
            // IMPORTANTE: ¡DEBES CAMBIAR ESTA CONSULTA POR LA TUYA!
            query = "SELECT nivel, dias, hora, precio, aforo, estado, fecha_inicio, fecha_fin FROM cursos;";
        }

        // 3. Ejecutar la consulta
        const res = await client.query(query, params);

        // 4. Devolver la respuesta
        return {
            statusCode: 200,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(res.rows),
        };

    } catch (error) {
        console.error("ERROR INESPERADO:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Error interno del servidor." }),
        };
    }
};
