# Despliegue en Railway

Este proyecto está configurado para desplegarse en Railway.

## Pasos para desplegar:

### 1. Crear cuenta en Railway
Ve a [railway.app](https://railway.app) y crea una cuenta.

### 2. Instalar Railway CLI
```bash
npm i -g @railway/cli
```

### 3. Hacer login en Railway
```bash
railway login
```

### 4. Inicializar proyecto en Railway (desde la carpeta raíz)
```bash
railway init
```

### 5. Agregar variable de entorno (Base de datos PostgreSQL)
Railway proporciona una variable `DATABASE_URL` automáticamente cuando agregues un plugin de PostgreSQL.

En el dashboard de Railway:
- Click en "Add" → "Database" → "PostgreSQL"
- Railway agregará automáticamente `DATABASE_URL`

### 6. Configurar variables de entorno en Railway

En el dashboard del proyecto, en "Variables", agrega:

```
DJANGO_SECRET_KEY=tu-clave-secreta-muy-larga-y-aleatoria
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=*.up.railway.app,*.railway.app
JWT_ACCESS_MINUTES=60
JWT_REFRESH_DAYS=1
```

### 7. Desplegar

Desde la carpeta raíz del proyecto:
```bash
railway up
```

O usando el dashboard de Railway:
- Conecta tu repositorio de GitHub
- Railway detectará automáticamente el Dockerfile
- Se desplegará automáticamente

## Variables de entorno importantes

- `DJANGO_DEBUG`: Debe ser `False` en producción
- `DJANGO_SECRET_KEY`: Usa una clave secreta fuerte
- `DATABASE_URL`: Proporcionada por Railway (PostgreSQL)

## Notas importantes

1. El Dockerfile en la raíz construye tanto el frontend (Vue) como el backend (Django)
2. El frontend se compila a archivos estáticos y se sirven desde Django
3. La base de datos PostgreSQL debe usarse en producción (no SQLite)
4. Railway maneja automáticamente los certificados SSL

## Troubleshooting

### Si falla la compilación de frontend:
Verifica que `npm run build` funciona localmente:
```bash
cd frontend
npm run build
```

### Si falla la migración:
Verifica que el `Procfile` tiene el comando correcto:
```
release: cd backend && python manage.py migrate
```

### Logs en Railway:
```bash
railway logs
```

## Conexión a la base de datos en producción

Railway proporciona la variable `DATABASE_URL` automáticamente. Django detectará esta variable a través del archivo settings.py que está configurado para usar PostgreSQL en producción.

Para forzar el uso de PostgreSQL, modifica `settings.py`:

```python
import dj_database_url

if os.getenv('DATABASE_URL'):
    DATABASES = {
        'default': dj_database_url.config(default=os.getenv('DATABASE_URL'), conn_max_age=600)
    }
```

Agrega `dj-database-url` a requirements.txt si usas esta configuración.
