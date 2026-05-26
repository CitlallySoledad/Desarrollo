web: cd backend && python manage.py collectstatic --no-input && gunicorn core.wsgi:application --bind 0.0.0.0:$PORT --workers 4 --worker-class sync --timeout 60
release: cd backend && python manage.py migrate
