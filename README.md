# Naar

Catálogo de ropa online para **Manar**, con panel de administración propio, gestión de productos con variantes e imágenes, carrito de compras y checkout por WhatsApp.

## Stack

- Ruby 3.3.6
- Rails 8.1.3
- PostgreSQL
- Active Storage con soporte para Amazon S3 (direct upload) y disco local
- Turbo + Stimulus (importmap, sin bundler de JS)
- Bootstrap 5.3 + Sass
- Ransack (filtros de búsqueda) + Pagy (paginación) en el panel admin

## Funcionalidades

- **Catálogo público**: listado de productos, categorías, FAQs y reels.
- **Carrito de compras**: agregado de productos con variantes, checkout que genera un pedido y redirige a WhatsApp.
- **Panel de administración** (`/admin`):
  - Productos, variantes e imágenes (con reordenamiento e imágenes múltiples)
  - Categorías
  - Pedidos
  - FAQs
  - Reels
  - Configuración de la home

## Requisitos

- Ruby 3.3.6
- Bundler
- PostgreSQL

## Instalación

```bash
git clone https://github.com/innoagostinelli/naar.git
cd naar
bundle install
bin/rails db:setup
```

### Configuración

La app usa Rails credentials para las claves de AWS S3. Asegurate de tener `config/master.key` (no versionado).

## Desarrollo

```bash
bin/dev
```

## Tests

```bash
bin/rails test
```

Chequeos de seguridad y estilo:

```bash
bin/brakeman
bin/bundler-audit
bin/rubocop
```

## Deploy

Deploy estándar de Rails: `git pull`, `bundle install`, `rails db:migrate`, `rails assets:precompile` y reinicio del servicio de aplicación detrás de nginx.

## Carpeta `recursos`

Los recursos internos del proyecto (logos, brandboard, manuales de usuario/administrador) no se versionan en este repositorio. Se mantienen localmente y están excluidos vía `.gitignore`.
