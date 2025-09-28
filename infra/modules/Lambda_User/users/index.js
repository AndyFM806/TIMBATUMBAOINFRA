const AWS = require('aws-sdk');
const crypto = require('crypto');
const winston = require('winston');
const mysql = require('mysql2/promise'); // o 'pg' para PostgreSQL

// --- CONFIGURACIÓN DE WINSTON ---
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.printf(({ level, message, timestamp, ...meta }) => {
      return JSON.stringify({
        timestamp,
        level: level.toUpperCase(),
        message,
        ...meta,
      });
    })
  ),
  transports: [
    new winston.transports.Console({
      handleExceptions: true,
    }),
  ],
});

// --- CONFIGURACIÓN AWS Y RDS ---
const secretsManager = new AWS.SecretsManager();
let dbConfig = null;

// Cache de conexión para reutilizar entre invocaciones
let dbConnection = null;

// --- OBTENER CONFIGURACIÓN DE BASE DE DATOS ---
async function getDbConfig() {
  if (dbConfig) return dbConfig;

  try {
    const secretResponse = await secretsManager.getSecretValue({
      SecretId: process.env.DB_SECRET_ARN
    }).promise();

    const secret = JSON.parse(secretResponse.SecretString);
    
    dbConfig = {
      host: process.env.DB_PROXY_ENDPOINT,
      port: secret.port || 3306, // 5432 para PostgreSQL
      user: secret.username,
      password: secret.password,
      database: process.env.DB_NAME,
      ssl: { rejectUnauthorized: false },
      acquireTimeout: 60000,
      timeout: 60000,
      reconnect: true
    };

    logger.info('Database configuration loaded successfully');
    return dbConfig;
  } catch (error) {
    logger.error('Failed to get database configuration', { error: error.message });
    throw error;
  }
}

// --- OBTENER CONEXIÓN A BASE DE DATOS ---
async function getDbConnection() {
  if (dbConnection) {
    try {
      // Verificar si la conexión sigue activa
      await dbConnection.ping();
      return dbConnection;
    } catch (error) {
      logger.warn('Database connection lost, creating new one');
      dbConnection = null;
    }
  }

  try {
    const config = await getDbConfig();
    dbConnection = await mysql.createConnection(config);
    logger.info('New database connection established');
    return dbConnection;
  } catch (error) {
    logger.error('Failed to create database connection', { error: error.message });
    throw error;
  }
}

// --- HANDLER PRINCIPAL ---
exports.handler = async (event, context) => {
  // Prevenir que Lambda espere hasta que el event loop esté vacío
  context.callbackWaitsForEmptyEventLoop = false;
  
  logger.info('Users Lambda event received', { 
    httpMethod: event.httpMethod,
    pathParameters: event.pathParameters 
  });

  try {
    const { httpMethod, pathParameters, body } = event;
    const parsedBody = body ? JSON.parse(body) : {};

    let response;

    switch (httpMethod) {
      case 'GET':
        if (pathParameters && pathParameters.userId) {
          response = await getUser(pathParameters.userId);
        } else {
          response = await getAllUsers(event.queryStringParameters);
        }
        break;

      case 'POST':
        response = await createUser(parsedBody);
        break;

      case 'PUT':
        if (pathParameters && pathParameters.userId) {
          response = await updateUser(pathParameters.userId, parsedBody);
        } else {
          return createResponse(400, { error: 'User ID is required for update' });
        }
        break;

      case 'DELETE':
        if (pathParameters && pathParameters.userId) {
          response = await deleteUser(pathParameters.userId);
        } else {
          return createResponse(400, { error: 'User ID is required for delete' });
        }
        break;

      default:
        return createResponse(405, { error: `Method ${httpMethod} not allowed` });
    }

    return createResponse(200, response);

  } catch (error) {
    logger.error('Users Lambda failed', {
      error: error.message,
      stack: error.stack,
      requestId: context.awsRequestId,
    });

    if (error.code === 'ER_DUP_ENTRY' || error.code === '23505') {
      return createResponse(409, { error: 'User already exists' });
    }

    if (error.statusCode) {
      return createResponse(error.statusCode, { error: error.message });
    }

    return createResponse(500, {
      error: 'Internal server error',
      requestId: context.awsRequestId,
    });
  }
};

// --- FUNCIONES CRUD ---
async function getAllUsers(queryParams = {}) {
  logger.info('Getting all users');

  const connection = await getDbConnection();
  
  try {
    const limit = parseInt(queryParams?.limit) || 50;
    const offset = parseInt(queryParams?.offset) || 0;
    const status = queryParams?.status;

    let query = `
      SELECT user_id, email, first_name, last_name, full_name, status, 
             phone, phone_verified, email_verified, created_at, updated_at,
             date_of_birth, registration_source, marketing_opt_in
      FROM users 
    `;
    
    const params = [];
    
    if (status) {
      query += ' WHERE status = ?';
      params.push(status);
    }
    
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const [rows] = await connection.execute(query, params);
    
    // Contar total de registros
    let countQuery = 'SELECT COUNT(*) as total FROM users';
    const countParams = [];
    
    if (status) {
      countQuery += ' WHERE status = ?';
      countParams.push(status);
    }
    
    const [countResult] = await connection.execute(countQuery, countParams);
    const total = countResult[0].total;

    logger.info('Retrieved users successfully', { count: rows.length, total });

    return { 
      success: true, 
      users: rows, 
      pagination: {
        count: rows.length,
        total,
        limit,
        offset,
        hasMore: offset + limit < total
      }
    };
  } catch (error) {
    logger.error('Failed to get users', { error: error.message });
    throw error;
  }
}

async function getUser(userId) {
  logger.info('Getting user by ID', { userId });

  const connection = await getDbConnection();

  try {
    const query = `
      SELECT user_id, email, first_name, last_name, full_name, status,
             phone, phone_verified, email_verified, created_at, updated_at,
             date_of_birth, address, registration_source, marketing_opt_in,
             login_attempts, last_login_at
      FROM users 
      WHERE user_id = ?
    `;

    const [rows] = await connection.execute(query, [userId]);

    if (rows.length === 0) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    logger.info('Retrieved user successfully', { userId });
    return { success: true, user: rows[0] };
  } catch (error) {
    logger.error('Failed to get user', { userId, error: error.message });
    throw error;
  }
}

async function createUser(userData) {
  logger.info('Creating new user', { email: userData.email });

  const validationError = validateUserData(userData);
  if (validationError) {
    const error = new Error(validationError);
    error.statusCode = 400;
    throw error;
  }

  const connection = await getDbConnection();
  const userId = generateUserId();
  const timestamp = new Date();

  try {
    const query = `
      INSERT INTO users (
        user_id, email, first_name, last_name, password_hash,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    const values = [
      userId,
      userData.email.toLowerCase().trim(),
      userData.firstName.trim(),
      userData.lastName.trim(),
      userData.password ? hashPassword(userData.password) : null,
      timestamp,
      timestamp
    ];

    await connection.execute(query, values);

    // Obtener el usuario creado (sin password_hash)
    const [newUser] = await connection.execute(`
      SELECT user_id, email, first_name, last_name, created_at, updated_at
      FROM users WHERE user_id = ?
    `, [userId]);

    logger.info('User created successfully', { userId });

    return { 
      success: true, 
      message: 'User created successfully', 
      user: newUser[0] 
    };
  } catch (error) {
    logger.error('Failed to create user', { userId, email: userData.email, error: error.message });
    throw error;
  }
}

async function updateUser(userId, updateData) {
  logger.info('Updating user', { userId });

  if (!updateData || Object.keys(updateData).length === 0) {
    const error = new Error('No data provided for update');
    error.statusCode = 400;
    throw error;
  }

  const connection = await getDbConnection();
  const timestamp = new Date();

  try {
    const allowedFields = ['first_name', 'last_name', 'phone', 'address', 'date_of_birth', 'marketing_opt_in'];
    const updateFields = [];
    const updateValues = [];

    // Construir campos de actualización
    Object.keys(updateData).forEach((key) => {
      const dbField = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      
      if (allowedFields.includes(dbField)) {
        updateFields.push(`${dbField} = ?`);
        updateValues.push(key === 'address' ? JSON.stringify(updateData[key]) : updateData[key]);
      }
    });

    // Actualizar full_name si se actualizó firstName o lastName
    if (updateData.firstName || updateData.lastName) {
      // Obtener datos actuales si solo se actualiza uno de los campos
      if (!updateData.firstName || !updateData.lastName) {
        const [currentUser] = await connection.execute(
          'SELECT first_name, last_name FROM users WHERE user_id = ?', 
          [userId]
        );
        
        if (currentUser.length === 0) {
          const error = new Error('User not found');
          error.statusCode = 404;
          throw error;
        }
        
        const firstName = updateData.firstName || currentUser[0].first_name;
        const lastName = updateData.lastName || currentUser[0].last_name;
        
        updateFields.push('full_name = ?');
        updateValues.push(`${firstName} ${lastName}`);
      } else {
        updateFields.push('full_name = ?');
        updateValues.push(`${updateData.firstName} ${updateData.lastName}`);
      }
    }

    if (updateFields.length === 0) {
      const error = new Error('No valid fields provided for update');
      error.statusCode = 400;
      throw error;
    }

    // Agregar updated_at
    updateFields.push('updated_at = ?');
    updateValues.push(timestamp);

    // Agregar userId para el WHERE
    updateValues.push(userId);

    const query = `
      UPDATE users 
      SET ${updateFields.join(', ')}
      WHERE user_id = ?
    `;

    const [result] = await connection.execute(query, updateValues);

    if (result.affectedRows === 0) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    // Obtener el usuario actualizado
    const [updatedUser] = await connection.execute(`
      SELECT user_id, email, first_name, last_name, full_name, status,
             phone, phone_verified, email_verified, created_at, updated_at,
             date_of_birth, address, registration_source, marketing_opt_in
      FROM users WHERE user_id = ?
    `, [userId]);

    logger.info('User updated successfully', { userId });

    return { 
      success: true, 
      message: 'User updated successfully', 
      user: updatedUser[0] 
    };
  } catch (error) {
    logger.error('Failed to update user', { userId, error: error.message });
    throw error;
  }
}

async function deleteUser(userId) {
  logger.info('Deleting user', { userId });

  const connection = await getDbConnection();

  try {
    // Primero obtener el usuario para devolverlo
    const [user] = await connection.execute(`
      SELECT user_id, email, first_name, last_name, full_name, status,
             phone, phone_verified, email_verified, created_at, updated_at,
             date_of_birth, address, registration_source, marketing_opt_in
      FROM users WHERE user_id = ?
    `, [userId]);

    if (user.length === 0) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    // Soft delete - cambiar status a 'deleted'
    const [result] = await connection.execute(`
      UPDATE users 
      SET status = 'deleted', updated_at = ? 
      WHERE user_id = ?
    `, [new Date(), userId]);

    if (result.affectedRows === 0) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    logger.info('User deleted successfully', { userId });

    return { 
      success: true, 
      message: 'User deleted successfully', 
      deletedUser: user[0] 
    };
  } catch (error) {
    logger.error('Failed to delete user', { userId, error: error.message });
    throw error;
  }
}

// --- UTILIDADES ---
function validateUserData(userData) {
  if (!userData) return 'User data is required';

  const required = ['email', 'firstName', 'lastName'];
  for (const field of required) {
    if (!userData[field] || typeof userData[field] !== 'string' || !userData[field].trim()) {
      return `Field '${field}' is required and must be a non-empty string`;
    }
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(userData.email)) return 'Invalid email format';

  if (userData.password && userData.password.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  if (userData.phone) {
    const phoneRegex = /^\+?[\d\s\-\(\)]+$/;
    if (!phoneRegex.test(userData.phone)) {
      return 'Invalid phone format';
    }
  }

  return null;
}

function generateUserId() {
  const timestamp = Date.now().toString(36);
  const randomStr = crypto.randomBytes(6).toString('hex');
  return `usr_${timestamp}_${randomStr}`;
}

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, 10000, 64, 'sha512').toString('hex');
  return `${salt}:${hash}`;
}

function createResponse(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type,Authorization',
      'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    },
    body: JSON.stringify(body),
  };
}