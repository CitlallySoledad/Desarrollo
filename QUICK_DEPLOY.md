# 🚀 Guía Rápida: Despliegue en Railway

## Resumen de cambios realizados

Tu proyecto ya está completamente configurado para Railway:

✅ `requirements.txt` - Actualizado con gunicorn, whitenoise, psycopg2, dj-database-url
✅ `Dockerfile` - Compila frontend y backend en una imagen
✅ `Procfile` - Define comandos web (gunicorn) y release (migraciones)
✅ `railway.json` - Configuración específica de Railway
✅ `backend/settings.py` - Configurado para PostgreSQL en producción
✅ `backend/runtime.txt` - Especifica Python 3.12
✅ Documentación - `RAILWAY_DEPLOYMENT.md` y `DEPLOYMENT_CHECKLIST.md`

## Paso a paso: Despliegue en 5 minutos

### 1️⃣ Crear cuenta en Railway
```
https://railway.app → Sign up → Completa el formulario
```

### 2️⃣ Instalar Railway CLI
```powershell
npm i -g @railway/cli
```

### 3️⃣ Hacer login
```powershell
railway login
# Te abrirá una ventana en el navegador
```

### 4️⃣ Agregar base de datos (desde Railway Dashboard)
- Ve a tu proyecto en Railway
- Click en "Add" → "Database" → "PostgreSQL"
- Railway agregará automáticamente `DATABASE_URL`

### 5️⃣ Configurar variables de entorno

En el dashboard de Railway, en "Variables", agrega:

| Variable | Valor |
|----------|-------|
| `DJANGO_SECRET_KEY` | Genera una clave fuerte, ej: `openssl rand -hex 32` |
| `DJANGO_DEBUG` | `False` |
| `DJANGO_ALLOWED_HOSTS` | `*.up.railway.app,*.railway.app` |
| `JWT_ACCESS_MINUTES` | `60` |
| `JWT_REFRESH_DAYS` | `1` |

### 6️⃣ Desplegar desde CLI
```powershell
cd c:\Users\21160\OneDrive\Documentos\DDSW\e5_backend

railway init
railway up
```

O desde GitHub:
- Conecta tu repo de GitHub a Railway
- Railway desplegará automáticamente en cada push

## ✅ Verificar despliegue

```powershell
# Ver logs en tiempo real
railway logs

# Abrir la aplicación
railway open

# Ver estado
railway status
```

**Espera a ver en logs:**
```
Running migrations...
Starting Gunicorn...
[SUCCESS]
```

## 🎉 ¡Listo!

Tu aplicación estará disponible en: `https://<tu-proyecto>.up.railway.app`

---

## Troubleshooting rápido

| Problema | Solución |
|----------|----------|
| "ModuleNotFoundError" | Revisa `requirements.txt` y `railway logs` |
| "Database does not exist" | Agrega PostgreSQL desde Railway Dashboard |
| "ALLOWED_HOSTS error" | Edita `DJANGO_ALLOWED_HOSTS` en variables |
| "Frontend no se carga" | Verifica `npm run build` funciona localmente |

---

## Comandos útiles Railway

```powershell
railway login               # Login a Railway
railway init               # Inicializar proyecto
railway up                 # Desplegar
railway logs               # Ver logs
railway variables          # Ver variables de entorno
railway open               # Abrir app en navegador
railway restart            # Reiniciar servicio
railway logout             # Logout
```

---

## Documentos de referencia

- 📋 [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) - Lista completa de verificación
- 📖 [RAILWAY_DEPLOYMENT.md](./RAILWAY_DEPLOYMENT.md) - Instrucciones detalladas
- 🔧 [Docker Docs](https://docs.docker.com) - Documentación Docker
- 🚂 [Railway Docs](https://docs.railway.app) - Documentación Railway
- 🎯 [Django Deployment](https://docs.djangoproject.com/en/5.2/howto/deployment/) - Guía Django

---

## Generar clave secreta fuerte

En PowerShell:
```powershell
# Opción 1: Usar online generator
# https://djecrety.ir/

# Opción 2: Usar Python
python -c "import secrets; print(secrets.token_urlsafe(50))"
```

Copia la salida y úsala como `DJANGO_SECRET_KEY` en Railway.

---

¿Preguntas? Consulta los documentos de referencia o revisa `railway logs` para más detalles.
