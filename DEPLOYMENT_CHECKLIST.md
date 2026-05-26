# Lista de Verificación - Despliegue en Railway

## Antes de desplegar

### Código
- [ ] Todos los cambios están en Git (`git status` debe estar limpio)
- [ ] Backend compila sin errores (`python manage.py check`)
- [ ] Frontend compila sin errores (`npm run build`)
- [ ] Tests pasan (`python manage.py test`)
- [ ] No hay archivos `.env` en Git (verifica `.gitignore`)

### Dependencias
- [ ] `requirements.txt` está actualizado con todas las librerías
- [ ] `package.json` está actualizado
- [ ] Probaste instalar dependencias desde cero (`pip install -r requirements.txt` y `npm install`)

### Configuración
- [ ] `Dockerfile` en raíz está correctamente configurado
- [ ] `Procfile` tiene los comandos web y release
- [ ] `runtime.txt` especifica Python 3.12
- [ ] `railway.json` existe y está configurado

## Preparación en Railway

- [ ] Cuenta de Railway creada
- [ ] Railway CLI instalado (`npm i -g @railway/cli`)
- [ ] Logueado en Railway (`railway login`)
- [ ] Nuevo proyecto creado en Railway

## Base de datos

- [ ] Plugin de PostgreSQL agregado a Railway
  - O MySQL si lo prefieres (requiere configuración adicional)
- [ ] `DATABASE_URL` está disponible en variables de Railway

## Variables de entorno

En Railway, agrega estas variables:

```
DJANGO_SECRET_KEY=<una-clave-fuerte-aleatoria>
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=*.up.railway.app,*.railway.app
JWT_ACCESS_MINUTES=60
JWT_REFRESH_DAYS=1
```

- [ ] `DJANGO_SECRET_KEY` configurado (clave fuerte)
- [ ] `DJANGO_DEBUG=False` (nunca True en producción)
- [ ] `DJANGO_ALLOWED_HOSTS` incluye dominio de Railway
- [ ] Variables JWT configuradas si cambió la configuración

## Despliegue

### Opción A: GitHub
- [ ] Repository conectado a Railway
- [ ] Rama `main` o `master` visible
- [ ] Push de cambios a GitHub

### Opción B: Railway CLI
```bash
railway login
railway init
railway up
```

- [ ] Logueado en Railway
- [ ] Proyecto inicializado
- [ ] Código desplegado sin errores

## Post-despliegue

- [ ] Despliegue completó sin errores (revisa `railway logs`)
- [ ] Aplicación inicia correctamente
- [ ] Migraciones se ejecutaron (`railway logs` debe mostrar "Running migrations")
- [ ] Puedes acceder a la aplicación en el navegador
- [ ] Frontend se carga correctamente
- [ ] API está accesible en `/api/`

## Verificaciones finales

```bash
# Ver logs en tiempo real
railway logs

# Abrir la app en navegador
railway open

# Ver el estado
railway status
```

- [ ] No hay errores en logs
- [ ] Frontend se ve correctamente
- [ ] API responde (prueba `/api/`)
- [ ] Base de datos está conectada (sin errores de migración)

## Troubleshooting

Si algo falla:

1. Revisa los logs: `railway logs`
2. Verifica variables de entorno: `railway variables`
3. Reinicia la app: desde el dashboard o `railway restart`
4. Revisa el Dockerfile localmente:
   ```bash
   docker build -t my-app .
   docker run -it my-app
   ```

## Documentos útiles

- [RAILWAY_DEPLOYMENT.md](./RAILWAY_DEPLOYMENT.md) - Instrucciones detalladas
- [Railway Docs](https://docs.railway.app) - Documentación oficial
- [Django Deployment](https://docs.djangoproject.com/en/5.2/howto/deployment/) - Guía de Django
