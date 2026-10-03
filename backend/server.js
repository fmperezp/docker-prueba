const fastify = require('fastify')({ logger: true });
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.PGHOST,
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  port: 5432
});

fastify.get('/api', async () => {
  return {
    mensaje: 'Backend funcionando correctamente - actualizado en desarrollo'
  };
});

fastify.get('/api/db', async () => {
  const result = await pool.query('SELECT NOW() AS fecha');
  return {
    mensaje: 'Conexion con PostgreSQL OK',
    fecha: result.rows[0].fecha
  };
});

fastify.listen({ port: 3000, host: '0.0.0.0' });
