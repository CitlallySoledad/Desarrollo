from rest_framework import viewsets

from core.permissions import IsAuthenticatedOrReadOnly

from .models import Categoria, Color, Marca, Producto, Talla, VarianteProducto
from .serializers import (
    CategoriaSerializer,
    ColorSerializer,
    MarcaSerializer,
    ProductoSerializer,
    TallaSerializer,
    VarianteProductoSerializer,
)


class CategoriaViewSet(viewsets.ModelViewSet):
    queryset = Categoria.objects.all()
    serializer_class = CategoriaSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]


class MarcaViewSet(viewsets.ModelViewSet):
    queryset = Marca.objects.all()
    serializer_class = MarcaSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]


class TallaViewSet(viewsets.ModelViewSet):
    queryset = Talla.objects.all()
    serializer_class = TallaSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]


class ColorViewSet(viewsets.ModelViewSet):
    queryset = Color.objects.all()
    serializer_class = ColorSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]


class ProductoViewSet(viewsets.ModelViewSet):
    queryset = Producto.objects.select_related('categoria', 'marca').all()
    serializer_class = ProductoSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]


class VarianteProductoViewSet(viewsets.ModelViewSet):
    queryset = VarianteProducto.objects.select_related('producto', 'talla', 'color').all()
    serializer_class = VarianteProductoSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
