# Proyecto: Sistema de Inscripciones y Gestión Académica 🎓

## Descripción General  
Este sistema está diseñado para **gestionar inscripciones, usuarios, horarios y clases** dentro de una academia. Su objetivo es digitalizar los procesos de matrícula y control académico, asegurando eficiencia, escalabilidad y seguridad.  

Los actores principales son:  
- **Usuarios (alumnos/clientes)** → se registran, visualizan cursos y realizan inscripciones.  
- **Administradores** → gestionan inscripciones, validan pagos, administran clases y alumnos. 

## Contexto y Problemática  

La aplicación tradicional presentaba desafíos que limitaban su rendimiento y confiabilidad:  

1. **Gestión manual de procesos:** Inscripciones y pagos poco escalables.  
2. **Falta de seguridad y control:** Sin autenticación robusta ni trazabilidad centralizada.  
3. **Notificaciones poco confiables:** Dificultades para manejar correos, SMS y colas de mensajes en alta demanda.  
4. **Picos de concurrencia:** Procesos críticos fallaban en temporadas de alta carga.  

## Solución Propuesta: Arquitectura en AWS  

Se implementó una arquitectura **serverless y modular** sobre AWS para cubrir los problemas identificados.  

### Beneficios Clave  
**Escalabilidad:** Uso de **AWS Lambda + API Gateway** para manejar picos de tráfico.  
**Seguridad:** Integración con **Cognito, WAF e IAM Roles** con privilegios mínimos.  
**Disponibilidad:** **S3 + CloudFront** para servir el frontend con baja latencia global.  
**Observabilidad:** **CloudWatch** centralizando logs y métricas en tiempo real.  
**Automatización:** Manejo de colas y notificaciones con **SQS y SNS**.  


## Arquitectura  

La solución implementa una arquitectura **basada en microservicios y servicios gestionados de AWS**, que se conectan de la siguiente manera:

### Frontend  
- **Amazon S3**:  
  Almacena todos los archivos estáticos del frontend (HTML, CSS, JS, imágenes).  
  El bucket es privado y solo accesible mediante **CloudFront**.  

- **Amazon CloudFront**:  
  CDN que distribuye el contenido con baja latencia y soporte HTTPS.  
  Optimiza tiempos de carga para usuarios finales en cualquier ubicación.  

- **AWS WAF**:  
  Firewall de aplicaciones web que protege contra ataques como SQL Injection, XSS y tráfico malicioso.  

---

### Autenticación y Roles  
- **Amazon Cognito**:  
  Administra usuarios y autenticación segura mediante pools.  
- **AWS IAM**:  
  Gestiona los permisos:  
  - **AdminRole** → Acceso completo a Lambdas, RDS vía Proxy, SES, SNS, SQS, pagos (Stripe) y CloudWatch.  
  - **SecretaryRole** → Acceso limitado a Lambdas específicas, actualizaciones restringidas en RDS, colas de correo, SES limitado y permisos parciales en CloudWatch.  

---

### Backend – Lambdas  
Microservicios serverless conectados por eventos:  

- **UploadVoucher Lambda**: Procesa comprobantes de pago.  
- **Inscriptions Lambda**: Maneja registros de estudiantes.  
- **Payment Lambda**: Integra pagos con **Stripe** a través de un **VPC NAT Gateway**.  
- **SendEmails Lambda**: Envía correos mediante **SES**.  
- **SendSMS Lambda**: Envía mensajes de texto mediante **SNS**.  

---

### Mensajería Asíncrona  
- **Amazon SQS**:  
  Sistema de colas que desacopla procesos y mejora resiliencia bajo alta concurrencia.  
- **Amazon SNS**:  
  Difusión de notificaciones a múltiples canales (SMS, emails, procesos internos).  

---

### Persistencia de Datos  
- **Amazon RDS (MySQL)**:  
  Base de datos relacional para usuarios, inscripciones y pagos.  
- **Amazon RDS Proxy**:  
  Optimiza conexiones concurrentes desde las Lambdas al RDS.  

---

### Monitoreo y Notificaciones  
- **Amazon CloudWatch**:  
  Monitorea métricas y logs de todo el sistema (Lambdas, API Gateway, RDS).  
- **Amazon SES**:  
  Servicio de correos transaccionales para confirmaciones y notificaciones.  

---

## Seguridad y Buenas Prácticas  
- Principio de mínimo privilegio con **IAM Roles**.  
- **S3 privado + CloudFront** para proteger los archivos del frontend.  
- **WAF** contra ataques en capa de aplicación.  
- **RDS Proxy** para seguridad y escalabilidad en conexiones.  

---