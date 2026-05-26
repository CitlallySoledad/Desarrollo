<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'

const API_BASE_URL = '/api/'

type Role = { id_role: number; nombre_role: string; descripcion: string }
type Usuario = {
  id_usuario: number
  username: string
  password_hash: string
  nombre_completo: string
  role: number
  role_nombre: string
  activo: boolean
}
type NamedItem = { nombre: string }
type Categoria = NamedItem & { id_categoria: number }
type Marca = NamedItem & { id_marca: number }
type Talla = NamedItem & { id_talla: number }
type ColorItem = NamedItem & { id_color: number; codigo_hex: string }
type Producto = {
  id_producto: number
  nombre: string
  descripcion: string
  categoria: number
  categoria_nombre: string
  marca: number
  marca_nombre: string
}
type Variante = {
  id_variante: number
  producto: number
  producto_nombre: string
  talla: number
  talla_nombre: string
  color: number
  color_nombre: string
  color_hex: string
  sku: string
  codigo_barras: string
  precio_venta: string
  stock_actual: number
}
type Venta = {
  id_venta: number
  fecha_venta: string
  total: string
  metodo_pago: string
  usuario: number
  usuario_nombre: string
  detalles: Array<{
    id_detalle: number
    producto: string
    sku: string
    cantidad: number
    precio_unitario_aplicado: string
    subtotal: string
  }>
}

type Section = 'catalogos' | 'productos' | 'usuarios' | 'ventas'

const activeSection = ref<Section>('catalogos')
const loading = ref(false)
const statusMessage = ref('Cargando datos...')
const statusKind = ref<'ok' | 'error' | 'info'>('info')
const token = ref(localStorage.getItem('access_token') || '')
const currentUser = ref(localStorage.getItem('current_user') || '')

const roles = ref<Role[]>([])
const usuarios = ref<Usuario[]>([])
const categorias = ref<Categoria[]>([])
const marcas = ref<Marca[]>([])
const tallas = ref<Talla[]>([])
const colores = ref<ColorItem[]>([])
const productos = ref<Producto[]>([])
const variantes = ref<Variante[]>([])
const ventas = ref<Venta[]>([])

const roleForm = reactive({ nombre_role: '', descripcion: '' })
const usuarioForm = reactive({
  username: '',
  password_hash: '',
  nombre_completo: '',
  role: '',
  activo: true,
})
const categoriaForm = reactive({ nombre: '' })
const marcaForm = reactive({ nombre: '' })
const tallaForm = reactive({ nombre: '' })
const colorForm = reactive({ nombre: '', codigo_hex: '#111827' })
const productoForm = reactive({ nombre: '', descripcion: '', categoria: '', marca: '' })
const varianteForm = reactive({
  producto: '',
  talla: '',
  color: '',
  sku: '',
  codigo_barras: '',
  precio_venta: '',
  stock_actual: 0,
})
const ventaForm = reactive({ usuario_id: '', variante_id: '', cantidad: 1, metodo_pago: 'Efectivo' })
const loginForm = reactive({ username: '', password: '' })

const dashboardCards = computed(() => [
  { label: 'Productos', value: productos.value.length },
  { label: 'Variantes', value: variantes.value.length },
  { label: 'Usuarios', value: usuarios.value.length },
  { label: 'Ventas', value: ventas.value.length },
])
const isAuthenticated = computed(() => Boolean(token.value))

const tabs: Array<{ id: Section; label: string }> = [
  { id: 'catalogos', label: 'Catalogos' },
  { id: 'productos', label: 'Productos' },
  { id: 'usuarios', label: 'Usuarios' },
  { id: 'ventas', label: 'Ventas' },
]

function money(value: string | number) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(value || 0))
}

function setStatus(message: string, kind: 'ok' | 'error' | 'info' = 'info') {
  statusMessage.value = message
  statusKind.value = kind
}

async function apiGet<T>(path: string): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`)
  if (!response.ok) throw new Error(`Error ${response.status}`)
  return response.json()
}

async function apiPost<T>(path: string, data: Record<string, unknown>): Promise<T> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  if (token.value) {
    headers.Authorization = `Bearer ${token.value}`
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: 'POST',
    headers,
    body: JSON.stringify(data),
  })

  if (!response.ok) {
    const errorData = await response.json().catch(() => null)
    throw new Error(formatApiError(errorData) || `Error ${response.status}`)
  }

  return response.json()
}

async function login() {
  loading.value = true
  try {
    const response = await fetch(`${API_BASE_URL}auth/login/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(loginForm),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => null)
      throw new Error(formatApiError(errorData) || 'No se pudo iniciar sesion.')
    }

    const data = await response.json()
    token.value = data.access
    currentUser.value = data.user?.username || loginForm.username
    localStorage.setItem('access_token', token.value)
    localStorage.setItem('current_user', currentUser.value)
    loginForm.password = ''
    await loadData()
    setStatus('Sesion iniciada. Ya puedes crear, editar y registrar ventas.', 'ok')
  } catch (error) {
    setStatus(error instanceof Error ? error.message : 'No se pudo iniciar sesion.', 'error')
  } finally {
    loading.value = false
  }
}

function logout() {
  token.value = ''
  currentUser.value = ''
  localStorage.removeItem('access_token')
  localStorage.removeItem('current_user')
  setStatus('Sesion cerrada.', 'info')
}

function formatApiError(errorData: unknown) {
  if (!errorData || typeof errorData !== 'object') return ''
  return Object.entries(errorData as Record<string, unknown>)
    .map(([field, value]) => `${field}: ${Array.isArray(value) ? value.join(', ') : String(value)}`)
    .join(' | ')
}

async function loadData() {
  loading.value = true
  try {
    const [
      rolesData,
      usuariosData,
      categoriasData,
      marcasData,
      tallasData,
      coloresData,
      productosData,
      variantesData,
      ventasData,
    ] = await Promise.all([
      apiGet<Role[]>('roles/'),
      apiGet<Usuario[]>('usuarios/'),
      apiGet<Categoria[]>('categorias/'),
      apiGet<Marca[]>('marcas/'),
      apiGet<Talla[]>('tallas/'),
      apiGet<ColorItem[]>('colores/'),
      apiGet<Producto[]>('productos/'),
      apiGet<Variante[]>('variantes/'),
      apiGet<Venta[]>('ventas/'),
    ])

    roles.value = rolesData
    usuarios.value = usuariosData
    categorias.value = categoriasData
    marcas.value = marcasData
    tallas.value = tallasData
    colores.value = coloresData
    productos.value = productosData
    variantes.value = variantesData
    ventas.value = ventasData
    setStatus('Backend conectado y datos actualizados.', 'ok')
  } catch (error) {
    setStatus(error instanceof Error ? error.message : 'No se pudo conectar con el backend.', 'error')
  } finally {
    loading.value = false
  }
}

async function saveRole() {
  await submitForm(() => apiPost<Role>('roles/', { ...roleForm }), () => {
    roleForm.nombre_role = ''
    roleForm.descripcion = ''
  })
}

async function saveUsuario() {
  await submitForm(
    () =>
      apiPost<Usuario>('usuarios/', {
        ...usuarioForm,
        role: Number(usuarioForm.role),
      }),
    () => {
      usuarioForm.username = ''
      usuarioForm.password_hash = ''
      usuarioForm.nombre_completo = ''
      usuarioForm.role = ''
      usuarioForm.activo = true
    },
  )
}

async function saveSimpleCatalog(path: string, form: { nombre: string }) {
  await submitForm(() => apiPost(path, { nombre: form.nombre }), () => {
    form.nombre = ''
  })
}

async function saveColor() {
  await submitForm(() => apiPost('colores/', { ...colorForm }), () => {
    colorForm.nombre = ''
    colorForm.codigo_hex = '#111827'
  })
}

async function saveProducto() {
  await submitForm(
    () =>
      apiPost<Producto>('productos/', {
        nombre: productoForm.nombre,
        descripcion: productoForm.descripcion,
        categoria: Number(productoForm.categoria),
        marca: Number(productoForm.marca),
      }),
    () => {
      productoForm.nombre = ''
      productoForm.descripcion = ''
      productoForm.categoria = ''
      productoForm.marca = ''
    },
  )
}

async function saveVariante() {
  await submitForm(
    () =>
      apiPost<Variante>('variantes/', {
        producto: Number(varianteForm.producto),
        talla: Number(varianteForm.talla),
        color: Number(varianteForm.color),
        sku: varianteForm.sku,
        codigo_barras: varianteForm.codigo_barras,
        precio_venta: varianteForm.precio_venta,
        stock_actual: Number(varianteForm.stock_actual),
      }),
    () => {
      varianteForm.producto = ''
      varianteForm.talla = ''
      varianteForm.color = ''
      varianteForm.sku = ''
      varianteForm.codigo_barras = ''
      varianteForm.precio_venta = ''
      varianteForm.stock_actual = 0
    },
  )
}

async function saveVenta() {
  await submitForm(
    () =>
      apiPost<Venta>('ventas/', {
        usuario_id: Number(ventaForm.usuario_id),
        variante_id: Number(ventaForm.variante_id),
        cantidad: Number(ventaForm.cantidad),
        metodo_pago: ventaForm.metodo_pago,
      }),
    () => {
      ventaForm.variante_id = ''
      ventaForm.cantidad = 1
      ventaForm.metodo_pago = 'Efectivo'
    },
  )
}

async function submitForm(action: () => Promise<unknown>, reset: () => void) {
  if (!isAuthenticated.value) {
    setStatus('Inicia sesion para crear registros. Las consultas son publicas.', 'error')
    return
  }

  loading.value = true
  try {
    await action()
    reset()
    await loadData()
    setStatus('Registro guardado correctamente.', 'ok')
  } catch (error) {
    setStatus(error instanceof Error ? error.message : 'No se pudo guardar el registro.', 'error')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (isAuthenticated.value) {
    loadData()
  }
})
</script>

<template>
  <main v-if="!isAuthenticated" class="login-shell">
    <section class="login-panel panel">
      <div>
        <p class="eyebrow">Punto de venta</p>
        <h1 class="page-title">Iniciar sesion</h1>
        <p class="page-subtitle">
          Accede con un usuario de Django para administrar catalogos, productos, usuarios y ventas.
        </p>
      </div>

      <form class="login-form" @submit.prevent="login">
        <label>
          Usuario
          <input v-model="loginForm.username" required autocomplete="username" placeholder="admin" />
        </label>
        <label>
          Contrasena
          <input
            v-model="loginForm.password"
            required
            autocomplete="current-password"
            placeholder="********"
            type="password"
          />
        </label>
        <button class="primary-button" type="submit" :disabled="loading">Entrar</button>
      </form>

      <p class="status-message" :class="statusKind">{{ statusMessage }}</p>

      <div class="login-actions">
        <span>Usa el usuario creado con <code>python manage.py createsuperuser</code>.</span>
      </div>
    </section>
  </main>

  <main v-else class="app-shell">
    <header class="app-header">
      <div>
        <p class="eyebrow">Punto de venta</p>
        <h1 class="page-title">Inventario, usuarios y ventas</h1>
        <p class="page-subtitle">
          Administra catalogos, productos, variantes, usuarios y registro de ventas desde Vue.
        </p>
      </div>
    </header>

    <section class="panel auth-panel">
      <div>
        <h2 class="panel-title">Sesion</h2>
        <p class="panel-subtitle">
          Sesion activa con permisos de escritura.
        </p>
      </div>

      <div class="session-row">
        <span class="status-pill active">Autenticado: {{ currentUser }}</span>
        <button class="secondary-button" type="button" @click="logout">Cerrar sesion</button>
      </div>
    </section>

    <section class="summary-grid dashboard-summary">
      <div v-for="card in dashboardCards" :key="card.label">
        <span>{{ card.label }}</span>
        <strong>{{ card.value }}</strong>
      </div>
    </section>

    <div class="toolbar">
      <div class="tabs" role="tablist" aria-label="Secciones">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          type="button"
          :class="{ active: activeSection === tab.id }"
          @click="activeSection = tab.id"
        >
          {{ tab.label }}
        </button>
      </div>

      <button class="secondary-button" type="button" :disabled="loading" @click="loadData">Actualizar</button>
    </div>

    <p class="status-message" :class="statusKind">{{ statusMessage }}</p>

    <section v-if="activeSection === 'catalogos'" class="dashboard-grid">
      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Roles</h2>
            <p class="panel-subtitle">Perfiles para usuarios.</p>
          </div>
        </div>
        <form class="panel-body form-grid" @submit.prevent="saveRole">
          <input v-model="roleForm.nombre_role" required placeholder="Nombre del rol" />
          <textarea v-model="roleForm.descripcion" placeholder="Descripcion"></textarea>
          <button class="primary-button" type="submit">Guardar rol</button>
        </form>
        <div class="panel-body tag-cloud">
          <span v-for="role in roles" :key="role.id_role">{{ role.nombre_role }}</span>
        </div>
      </article>

      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Catalogos</h2>
            <p class="panel-subtitle">Categorias, marcas, tallas y colores.</p>
          </div>
        </div>
        <div class="panel-body stacked">
          <form class="inline-form" @submit.prevent="saveSimpleCatalog('categorias/', categoriaForm)">
            <input v-model="categoriaForm.nombre" required placeholder="Nueva categoria" />
            <button class="primary-button" type="submit">Agregar</button>
          </form>
          <form class="inline-form" @submit.prevent="saveSimpleCatalog('marcas/', marcaForm)">
            <input v-model="marcaForm.nombre" required placeholder="Nueva marca" />
            <button class="primary-button" type="submit">Agregar</button>
          </form>
          <form class="inline-form" @submit.prevent="saveSimpleCatalog('tallas/', tallaForm)">
            <input v-model="tallaForm.nombre" required placeholder="Nueva talla" />
            <button class="primary-button" type="submit">Agregar</button>
          </form>
          <form class="form-grid color-grid" @submit.prevent="saveColor">
            <input v-model="colorForm.nombre" required placeholder="Nuevo color" />
            <input v-model="colorForm.codigo_hex" class="color-input" type="color" required />
            <button class="primary-button" type="submit">Agregar</button>
          </form>
        </div>
      </article>

      <article class="panel wide">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Listas de catalogos</h2>
            <p class="panel-subtitle">Datos disponibles para productos y ventas.</p>
          </div>
        </div>
        <div class="panel-body catalog-grid">
          <div>
            <h3>Categorias</h3>
            <p v-for="item in categorias" :key="item.id_categoria">{{ item.nombre }}</p>
          </div>
          <div>
            <h3>Marcas</h3>
            <p v-for="item in marcas" :key="item.id_marca">{{ item.nombre }}</p>
          </div>
          <div>
            <h3>Tallas</h3>
            <p v-for="item in tallas" :key="item.id_talla">{{ item.nombre }}</p>
          </div>
          <div>
            <h3>Colores</h3>
            <p v-for="item in colores" :key="item.id_color">
              <span class="color-dot" :style="{ backgroundColor: item.codigo_hex }"></span>{{ item.nombre }}
            </p>
          </div>
        </div>
      </article>
    </section>

    <section v-if="activeSection === 'productos'" class="dashboard-grid">
      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Nuevo producto</h2>
            <p class="panel-subtitle">Producto base con categoria y marca.</p>
          </div>
        </div>
        <form class="panel-body form-grid two" @submit.prevent="saveProducto">
          <input v-model="productoForm.nombre" required placeholder="Nombre" />
          <select v-model="productoForm.categoria" required>
            <option value="" disabled>Categoria</option>
            <option v-for="categoria in categorias" :key="categoria.id_categoria" :value="categoria.id_categoria">
              {{ categoria.nombre }}
            </option>
          </select>
          <select v-model="productoForm.marca" required>
            <option value="" disabled>Marca</option>
            <option v-for="marca in marcas" :key="marca.id_marca" :value="marca.id_marca">
              {{ marca.nombre }}
            </option>
          </select>
          <textarea v-model="productoForm.descripcion" class="span-2" placeholder="Descripcion"></textarea>
          <button class="primary-button span-2" type="submit">Guardar producto</button>
        </form>
      </article>

      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Nueva variante</h2>
            <p class="panel-subtitle">SKU, color, talla, precio y stock.</p>
          </div>
        </div>
        <form class="panel-body form-grid two" @submit.prevent="saveVariante">
          <select v-model="varianteForm.producto" required>
            <option value="" disabled>Producto</option>
            <option v-for="producto in productos" :key="producto.id_producto" :value="producto.id_producto">
              {{ producto.nombre }}
            </option>
          </select>
          <select v-model="varianteForm.talla" required>
            <option value="" disabled>Talla</option>
            <option v-for="talla in tallas" :key="talla.id_talla" :value="talla.id_talla">
              {{ talla.nombre }}
            </option>
          </select>
          <select v-model="varianteForm.color" required>
            <option value="" disabled>Color</option>
            <option v-for="color in colores" :key="color.id_color" :value="color.id_color">
              {{ color.nombre }}
            </option>
          </select>
          <input v-model="varianteForm.sku" required placeholder="SKU" />
          <input v-model="varianteForm.codigo_barras" required placeholder="Codigo de barras" />
          <input v-model="varianteForm.precio_venta" required min="0.01" step="0.01" type="number" placeholder="Precio" />
          <input v-model.number="varianteForm.stock_actual" required min="0" type="number" placeholder="Stock" />
          <button class="primary-button" type="submit">Guardar variante</button>
        </form>
      </article>

      <article class="panel wide">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Inventario</h2>
            <p class="panel-subtitle">Productos y variantes registrados.</p>
          </div>
        </div>
        <div class="panel-body table-wrap">
          <table class="table">
            <thead>
              <tr>
                <th>Producto</th>
                <th>Categoria</th>
                <th>Marca</th>
                <th>SKU</th>
                <th>Talla</th>
                <th>Color</th>
                <th>Precio</th>
                <th>Stock</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="variante in variantes" :key="variante.id_variante">
                <td>{{ variante.producto_nombre }}</td>
                <td>{{ productos.find((p) => p.id_producto === variante.producto)?.categoria_nombre || '-' }}</td>
                <td>{{ productos.find((p) => p.id_producto === variante.producto)?.marca_nombre || '-' }}</td>
                <td>{{ variante.sku }}</td>
                <td>{{ variante.talla_nombre }}</td>
                <td><span class="color-dot" :style="{ backgroundColor: variante.color_hex }"></span>{{ variante.color_nombre }}</td>
                <td>{{ money(variante.precio_venta) }}</td>
                <td>{{ variante.stock_actual }}</td>
              </tr>
              <tr v-if="variantes.length === 0">
                <td colspan="8" class="empty-state">Aun no hay variantes registradas.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </article>
    </section>

    <section v-if="activeSection === 'usuarios'" class="dashboard-grid">
      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Nuevo usuario</h2>
            <p class="panel-subtitle">Usuarios del punto de venta.</p>
          </div>
        </div>
        <form class="panel-body form-grid" @submit.prevent="saveUsuario">
          <input v-model="usuarioForm.username" required placeholder="Usuario" />
          <input v-model="usuarioForm.password_hash" required placeholder="Password o hash" />
          <input v-model="usuarioForm.nombre_completo" required placeholder="Nombre completo" />
          <select v-model="usuarioForm.role" required>
            <option value="" disabled>Rol</option>
            <option v-for="role in roles" :key="role.id_role" :value="role.id_role">{{ role.nombre_role }}</option>
          </select>
          <label class="check-line">
            <input v-model="usuarioForm.activo" type="checkbox" />
            Activo
          </label>
          <button class="primary-button" type="submit">Guardar usuario</button>
        </form>
      </article>

      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Usuarios registrados</h2>
            <p class="panel-subtitle">Lista operativa para ventas.</p>
          </div>
        </div>
        <div class="panel-body table-wrap">
          <table class="table compact-table">
            <thead>
              <tr>
                <th>Usuario</th>
                <th>Nombre</th>
                <th>Rol</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="usuario in usuarios" :key="usuario.id_usuario">
                <td>{{ usuario.username }}</td>
                <td>{{ usuario.nombre_completo }}</td>
                <td>{{ usuario.role_nombre }}</td>
                <td>{{ usuario.activo ? 'Activo' : 'Inactivo' }}</td>
              </tr>
              <tr v-if="usuarios.length === 0">
                <td colspan="4" class="empty-state">Aun no hay usuarios registrados.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </article>
    </section>

    <section v-if="activeSection === 'ventas'" class="dashboard-grid">
      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Registrar venta</h2>
            <p class="panel-subtitle">Selecciona usuario, variante y cantidad.</p>
          </div>
        </div>
        <form class="panel-body form-grid two" @submit.prevent="saveVenta">
          <select v-model="ventaForm.usuario_id" required>
            <option value="" disabled>Usuario</option>
            <option v-for="usuario in usuarios" :key="usuario.id_usuario" :value="usuario.id_usuario">
              {{ usuario.nombre_completo }}
            </option>
          </select>
          <select v-model="ventaForm.variante_id" required>
            <option value="" disabled>Variante</option>
            <option v-for="variante in variantes" :key="variante.id_variante" :value="variante.id_variante">
              {{ variante.producto_nombre }} - {{ variante.sku }} - Stock {{ variante.stock_actual }}
            </option>
          </select>
          <input v-model.number="ventaForm.cantidad" required min="1" type="number" placeholder="Cantidad" />
          <select v-model="ventaForm.metodo_pago" required>
            <option>Efectivo</option>
            <option>Tarjeta</option>
            <option>Transferencia</option>
          </select>
          <button class="primary-button span-2" type="submit">Registrar venta</button>
        </form>
      </article>

      <article class="panel">
        <div class="panel-header">
          <div>
            <h2 class="panel-title">Ventas recientes</h2>
            <p class="panel-subtitle">Historial generado por el backend.</p>
          </div>
        </div>
        <div class="panel-body stacked">
          <div v-for="venta in ventas" :key="venta.id_venta" class="sale-card">
            <div>
              <strong>Venta #{{ venta.id_venta }}</strong>
              <span>{{ venta.usuario_nombre }} - {{ venta.metodo_pago }}</span>
            </div>
            <strong>{{ money(venta.total) }}</strong>
          </div>
          <p v-if="ventas.length === 0" class="empty-state">Aun no hay ventas registradas.</p>
        </div>
      </article>
    </section>
  </main>
</template>
