# CaféMatch → Marketplace de café (evolución del MVP)

Evolución del MVP "Tinder del café" hacia una plataforma de marketplace:
el swipe se conserva como mecanismo *opcional* de descubrimiento, pero el
centro de la app pasa a ser DESCUBRIR → VER PERFIL COMPLETO → MOSTRAR
INTERÉS → SOLICITUD → CONEXIÓN COMERCIAL → CHAT → COTIZACIÓN.

Sigue sin backend real (todo vive en memoria, como en la build de pruebas
anterior) porque así se decidió explícitamente para esta iteración. La
arquitectura de datos está organizada en colecciones equivalentes a las
que tendría Firestore, para que migrar sea un cambio de capa de datos, no
de arquitectura — ver la sección "Camino a Firestore" más abajo.

## Cómo correrla

```bash
cd cafe_match_marketplace
flutter pub get
flutter run                      # con el teléfono conectado
# o
flutter build apk --release      # genera build/app/outputs/flutter-apk/app-release.apk
```

Al abrir, usa "Entrar como comprador demo" para saltarte el registro, o
crea una cuenta eligiendo "Vender café" / "Comprar café". Hay 5 fincas
colombianas de ejemplo (Huila, Antioquia, Nariño, Quindío, Tolima) con
varios lotes cada una, ya publicadas.

---

## Resumen de la evolución (punto 32 del plan)

### Archivos modificados (reutilizados, no reescritos desde cero)
- `lib/services/session_provider.dart` — se agregó `actualizarUsuario()`
- `lib/screens/auth/login_screen.dart` — lenguaje de marketplace
- `lib/screens/auth/register_screen.dart` — selección "Vender/Comprar café", ciudad y tipo de comprador
- `lib/screens/home/home_shell.dart` — navegación reestructurada
- `lib/screens/profile/my_profile_screen.dart` — preferencias (comprador) / resumen de marca (vendedor)
- `lib/widgets/swipe_card.dart` — rediseñada con toda la info + botón "Ver perfil"
- `lib/theme/app_theme.dart` — sin cambios de fondo, reutilizado tal cual
- `pubspec.yaml` — descripción actualizada (mismas dependencias)

### Archivos nuevos
**Modelos**: `seller_profile.dart`, `coffee_lot.dart`, `interest_request.dart`, `favorite.dart`, `quote_request.dart`
**Utilidades**: `utils/format_utils.dart` (formato COP)
**Widgets**: `empty_state.dart`, `badges.dart`, `coffee_lot_card.dart`, `interest_dialog.dart`
**Pantallas**: `discover/discover_screen.dart`, `discover/swipe_mode_view.dart`, `discover/list_mode_view.dart`, `discover/filters_sheet.dart`, `seller/seller_detail_screen.dart`, `seller/seller_profile_edit_screen.dart`, `seller/my_coffee_lots_screen.dart`, `seller/coffee_lot_edit_screen.dart`, `coffee/coffee_lot_detail_screen.dart`, `requests/my_requests_screen.dart`, `requests/received_requests_screen.dart`, `saved/saved_screen.dart`, `chat/quote_request_screen.dart`, `onboarding/onboarding_screen.dart`

### Archivos eliminados (reemplazados conceptualmente)
- `models/coffee_profile.dart` → dividido en `SellerProfile` + `CoffeeLot`
- `models/match_model.dart` → reemplazado por `InterestRequest`
- `screens/swipe/swipe_screen.dart` → reemplazado por `discover/discover_screen.dart` + `swipe_mode_view.dart`
- `screens/matches/matches_screen.dart` → reemplazado por `requests/my_requests_screen.dart` y `requests/received_requests_screen.dart`
- `screens/profile/seller_profile_edit_screen.dart` (antiguo, mezclaba vendedor+café) → dividido en `seller/seller_profile_edit_screen.dart` + `seller/coffee_lot_edit_screen.dart`

### Modelos: creados/modificados
| Modelo | Cambio |
|---|---|
| `AppUser` | + ciudad, tipoComprador, preferencias (variedades/regiones/procesos/precioMax) |
| `SellerProfile` (nuevo) | Reemplaza la mitad "vendedor" de `CoffeeProfile`: marca, finca, galería, historia, verificación, reputación |
| `CoffeeLot` (nuevo) | Reemplaza la mitad "café" de `CoffeeProfile`: un vendedor puede tener N lotes, con perfil sensorial, certificaciones, precio COP |
| `InterestRequest` (nuevo) | Reemplaza `MatchModel`: pendiente → aceptada/rechazada, sin "like" automático |
| `Favorite` (nuevo) | Guardados de café/vendedor, separado de las solicitudes |
| `QuoteRequest` (nuevo) | Arquitectura preparada para cotización → pedido → pago |

### "Colecciones" de datos (equivalente a Firestore, hoy en `MockStore`)
Antes: `usuarios · perfiles_cafe · likes · matches · chats`
Ahora: `usuarios · vendedores · lotes · solicitudes · favoritos · cotizaciones · mensajes`

Sin duplicación: `SellerProfile` no repite nombre/email del usuario (usa
`usuarioId` como referencia); `CoffeeLot` no repite datos del vendedor
(usa `sellerId`); el chat no repite datos de la solicitud (usa el id de
la `InterestRequest` como `chatId`).

### Camino a Firestore (si se retoma la versión con backend)
- `usuarios/{uid}` — igual que antes
- `vendedores/{sellerId}` — antes `perfiles_cafe`, ahora solo datos de marca
- `vendedores/{sellerId}/lotes/{loteId}` — subcolección, así "lotes de un vendedor" es una query directa sin filtrar del lado del cliente
- `solicitudes/{id}` — con índice compuesto `(compradorId, fecha desc)` y `(sellerId, estado, fecha desc)` para las dos pantallas de solicitudes sin descargar todo
- `favoritos/{id}` — índice `(compradorId, tipo)`
- `cotizaciones/{id}` — índice `(interestRequestId, fecha desc)`
- `chats/{interestRequestId}/mensajes/{id}` — el chat solo existe si la solicitud está aceptada (regla de seguridad lo valida)

Reglas conceptuales a portar: comprador solo crea sus propias solicitudes;
vendedor solo acepta/rechaza las dirigidas a él; chat legible solo por
`compradorId`/`sellerId` de la solicitud asociada; favoritos son privados
del comprador dueño; lotes con `estado == publicado` son de lectura
pública, el resto solo por su dueño.

### Nuevas pantallas
`SellerDetailScreen`, `CoffeeLotDetailScreen`, `DiscoverScreen` (+ modo tarjetas/lista), `MyRequestsScreen`, `ReceivedRequestsScreen`, `SavedScreen`, `MyCoffeeLotsScreen`, `SellerProfileEditScreen`, `CoffeeLotEditScreen`, `QuoteRequestScreen`, `OnboardingScreen`

### Nuevas funcionalidades
- Perfil de vendedor completamente explorable (galería, historia, cafés)
- Un vendedor puede publicar varios lotes de café
- Sistema de solicitudes comerciales con estados pendiente/aceptada/rechazada (sin "match" automático)
- Chat habilitado solo tras conexión comercial, con contexto (café + precio) y botón "Ver café"
- Solicitud de cotización (cantidad, unidad, lugar de entrega) — arquitectura lista para pedido/pago futuro
- Filtros ampliados: departamento, variedad, proceso, precio, altitud, puntaje, certificaciones, disponibilidad, tipo de café, vendedor verificado
- Modo lista además del modo swipe
- Favoritos separados en cafés/vendedores guardados
- Preferencias de compra del comprador (variedades, regiones, procesos)
- Precios en formato COP colombiano (`$32.000 / kg`)
- Insignia de verificado (solo cuando el dato existe), certificaciones, disponibilidad, calificación
- Onboarding con mensaje distinto para comprador/vendedor tras registrarse

### Terminología (sección 1) — aplicada en toda la app
Se eliminó "match/like/¿te gusta?" y se reemplazó por: Me interesa · Descartar · Ver perfil · Solicitar contacto · Mis solicitudes · Conexión comercial · Solicitudes recibidas · Aceptar/Rechazar solicitud · Compradores interesados.

### Mejoras dejadas preparadas pero NO implementadas (a propósito, sección 30)
- Persistencia real (Firestore) — estructura ya compatible, ver arriba
- Pagos, pedidos, envíos, facturación — `QuoteRequest` es el punto de partida
- Notificaciones push (nuevo mensaje, solicitud aceptada)
- Verificación real de vendedores (hoy es un campo booleano de demo)
- Calificaciones post-transacción
- Recomendación personalizada basada en `BuyerPreferences`
- Panel administrativo / analítica

### Calidad de código (sección 31)
No pude ejecutar `flutter analyze` ni pruebas automatizadas en este
entorno (no tiene el SDK de Flutter instalado). Sí hice verificación
estática manual: balance de llaves/paréntesis en los 36 archivos,
cruce de cada import relativo contra el árbol de archivos, y revisión
de que ninguna pantalla quedó referenciando clases eliminadas
(`CoffeeProfile`, `MatchModel`). Antes de tu primera prueba real,
corre `flutter analyze` en tu máquina — con este volumen de código es
razonable que aparezca algún ajuste menor de tipos u imports.

---

## Segunda ronda de mejoras (pulido hacia "producto")

Objetivo: pasar de "MVP funcional" a "prototipo pulido presentable". Sigue
sin Firebase/pagos reales — todo en `MockStore`, diseñado para migrar a
Firestore sin rehacer la UI (los widgets no saben de dónde vienen los datos).

### Funcionalidades nuevas
- **Visor de imágenes a pantalla completa** (`FullscreenImageViewer`): zoom con pellizco, swipe entre fotos, contador "2/5", cierre con X o deslizando hacia abajo. Reutilizado en perfil de vendedor, galería del café, formularios de fotos y tarjetas.
- **`AppImage`**: componente único que reemplazó los ~10 usos sueltos de `Image.file`/`FileImage` en toda la app — centraliza placeholder, error y apertura del visor.
- **Búsqueda + orden + filtros** en Descubrir: barra de búsqueda (café, variedad, finca, región, proceso), 6 criterios de orden, contador "X cafés encontrados" y "Limpiar filtros".
- **Prevención de solicitudes duplicadas**: `MockStore.crearSolicitud` ahora valida y lanza `DuplicateRequestException` con el mensaje correcto según el estado existente (pendiente/aceptada).
- **Descartes con "Deshacer"**: al descartar un café aparece un snackbar con acción "Deshacer" (solo el último descarte, como pide el PDF).
- **Recomendaciones simples** (`MockStore.puntuarLote` / `coincideConPreferencias`): puntuación por coincidencia de variedad/proceso/región/precio/disponibilidad contra las preferencias del comprador; se usa para el orden "Más relevantes" y la etiqueta "Coincide con tus preferencias" en las tarjetas.
- **Galería del café** con imagen grande, indicador de posición y miniaturas — funciona igual con 1 o con 10 fotos.
- **Perfil sensorial visual**: barras de progreso para Acidez/Cuerpo/Dulzor en vez de solo texto.
- **Sección "Origen"** con ícono por dato (finca, municipio, departamento, país, altitud).
- **Sección de confianza** en el perfil del vendedor: checklist ✓ que solo muestra indicadores respaldados por datos reales (nunca inventados).
- **"Mi catálogo"** del vendedor con estadísticas (cafés publicados, solicitudes pendientes, conexiones).
- **Gestión de fotos mejorada**: eliminar, ver en grande y elegir foto principal, tanto en el perfil de vendedor como en cada lote.
- **Chat con encabezado comercial**: foto+nombre+precio del café, botones explícitos [Ver café] / [Cotizar].
- **Cotización con resumen dinámico** antes de enviar ("Estás solicitando cotización de X kg de...").
- **Validaciones**: precio > 0, cantidad > 0, altitud ≥ 0, puntaje entre 50-100, variedad/proceso obligatorios.
- **Formulario de café dividido visualmente** en secciones (Fotografías, Identidad, Proceso y calidad, Venta, Certificaciones y envío) sin convertirlo en wizard.
- **Accesibilidad**: botones del swipe con etiqueta de texto + `Tooltip` + `Semantics`, no solo íconos.
- Sexto vendedor de demo (Cauca) para mayor diversidad regional.

### Archivos nuevos
`widgets/app_image.dart`, `widgets/fullscreen_image_viewer.dart`

### Archivos modificados (más relevantes)
`data/mock_store.dart` (búsqueda/orden/duplicados/recomendación/deshacer), `screens/discover/discover_screen.dart`, `screens/discover/swipe_mode_view.dart`, `screens/coffee/coffee_lot_detail_screen.dart`, `screens/seller/seller_detail_screen.dart`, `screens/seller/seller_profile_edit_screen.dart`, `screens/seller/coffee_lot_edit_screen.dart`, `screens/seller/my_coffee_lots_screen.dart`, `screens/chat/chat_screen.dart`, `screens/chat/quote_request_screen.dart`, `screens/requests/my_requests_screen.dart`, `screens/requests/received_requests_screen.dart`, `screens/saved/saved_screen.dart`, `screens/onboarding/onboarding_screen.dart`, `screens/profile/my_profile_screen.dart`, `screens/home/home_shell.dart`, `widgets/swipe_card.dart`, `widgets/coffee_lot_card.dart`

### Cambios en modelos
Ningún modelo de datos cambió de forma incompatible; `DiscoverFilters` ganó `busqueda` y `orden` (con defaults, no rompe nada existente).

### Cambios en MockStore
`DuplicateRequestException`, `DiscoverSort` (enum + comparador), `puntuarLote`/`coincideConPreferencias`, `deshacerUltimoDescarte`, `descubrirLotes` ahora aplica búsqueda + orden además de los filtros previos.

### Limitaciones actuales (honestas)
- No pude ejecutar `flutter analyze` ni compilar en este entorno (sin SDK de Flutter). Hice verificación estática manual (balance de llaves/paréntesis en los 40 archivos, cruce de imports relativos, cruce de parámetros de los widgets nuevos contra sus usos) — recomiendo correr `flutter analyze` como primer paso al abrir el proyecto.
- El "arrastre" del swipe no muestra las etiquetas "Me interesa"/"Descartar" en tiempo real durante el gesto (sí quedan como etiquetas de texto fijas bajo los botones) — `flutter_card_swiper` no expone el progreso del arrastre de forma sencilla sin arriesgar la mecánica que ya funciona.
- La verificación de vendedor sigue siendo un campo de demostración (no hay verificación real de identidad).
- Favoritos, solicitudes y cotizaciones no persisten entre reinicios de la app (por diseño, sigue siendo `MockStore`).

---

## Tercera ronda: corrección de UX/UI (foco, buscador, visor, SwipeCard)

Prioridad: corregir causas, no síntomas. Sin funcionalidades nuevas grandes,
sin Firebase, sin pagos. Se mantiene `MockStore` y la navegación comprador/vendedor.

### PROBLEMA 1 — Teclado que aparecía solo: causa raíz y solución
**Causa real**: `DiscoverScreen` tenía un `TextField` permanente de búsqueda.
Cuando ese campo llegaba a tener foco, Flutter lo restauraba al volver de
cualquier modal (filtros, ordenar) o de otra ruta (perfil) — de ahí el
teclado "fantasma" y el reacomodo del layout.

**Solución**: se sacó la búsqueda de Discover por completo. Ahora vive en
`SearchScreen`, una ruta aparte con su propio `Scaffold` (esa sí acepta el
teclado con normalidad). Discover ya **no tiene ningún campo de texto**, así
que no hay foco que restaurar. Además:
- `Discover` usa `resizeToAvoidBottomInset: false` — justificado y documentado
  en el propio código, porque esa pantalla nunca debería reaccionar al
  teclado (no tiene campos); no se aplicó "en todas partes" como pedía
  evitar el PDF.
- `liberarFoco()` (nuevo, `utils/focus_utils.dart`) se llama explícitamente
  antes/después de abrir filtros, ordenar y volver de la búsqueda — no como
  parche aislado, sino como parte del ciclo de esas transiciones.
- `DismissKeyboard` (nuevo) envuelve Chat, Cotización y los formularios de
  vendedor: tocar fuera de un campo cierra el teclado ahí donde sí existen
  TextFields.
- El chat usa `PopScope` para liberar foco antes de cerrarse.

### Nueva arquitectura de búsqueda
`SearchScreen` (nueva): AppBar con el propio `TextField` con `autofocus`,
contador de resultados, sugerencias rápidas (Geisha, Huila, Honey…), botón
de limpiar, estado sin-resultados propio, y botón "Ver N en Descubrir". Al
cerrar, Discover recibe el texto vía callback y lo muestra como un chip
compacto `Búsqueda: Geisha ×` — nunca vuelve a mostrar una barra grande.

### Cambios en DiscoverScreen
- AppBar reducido a "Descubrir café" + ícono de lupa (se quitaron los accesos
  directos a Guardados/Solicitudes: ya están en la navegación inferior).
- Debajo: título + subtítulo cortos, `[Filtrar · N] [Ordenar]` compactos (40px),
  chip de búsqueda activa + "N filtros activos · Limpiar", contador de
  resultados, selector Tarjetas/Lista compacto (34px).
- Tres estados vacíos diferenciados: sin resultados por filtros, sin
  resultados solo por búsqueda, y "ya viste todos los cafés disponibles".
- Ya no observa `MockStore` de forma continua: solo recarga cuando cambia
  `catalogRevision` (nuevo contador en `MockStore`, incrementado únicamente
  por las operaciones que afectan lo que ve un comprador) y en momentos
  seguros (aplicar filtros/orden, volver de un detalle, reactivar la pestaña).

### Visor de imágenes: arquitectura de gestos separada
**Causa del conflicto anterior**: un único `GestureDetector` vertical
envolvía todo el `InteractiveViewer`, así que arrastrar para hacer zoom y
arrastrar para cerrar competían por el mismo gesto.

**Solución — `ZoomableImage` (nuevo)**: cada imagen del `PageView` es una
instancia independiente con su propio `TransformationController` (por lo
tanto su propio estado de zoom — cambiar de página nunca hereda el zoom de
otra). Reglas:
- 1x: `panEnabled: false` — la imagen no se arrastra libremente, solo pincha
  para ampliar o doble toque.
- Doble toque: 1x ↔ 2.5x, animado, centrado en el punto tocado.
- >1x: `panEnabled: true`, `boundaryMargin: EdgeInsets.zero` — se puede
  explorar la imagen ampliada sin que se salga de la pantalla.
- Botón discreto "Restablecer · 1x" cuando hay zoom.

`FullscreenImageViewer` ahora solo coordina: deshabilita el cambio de página
mientras una imagen está ampliada (`onZoomChanged`) y solo activa el cierre
por gesto vertical a 1x y con un dedo (se ignoran gestos multitáctiles vía
`Listener`), sin desplazar la imagen — únicamente atenúa el fondo.

### AppImage
Ahora resuelve la fuente con `imageProviderFor` (nuevo, `utils/image_source.dart`):
asset, archivo local o red según el prefijo de la ruta — mismo componente,
listo para cuando existan imágenes remotas. El placeholder dejó de ser un
degradado con un ícono perdido: es un contenedor diseñado (fondo cálido +
textura + ícono + "Sin fotografía" en tamaños grandes) que solo aparece
cuando de verdad no hay foto.

### Datos demo: imágenes reales del catálogo
El catálogo demo no tenía ninguna fotografía (`fotos: []`, `fotoPrincipal: null`
en todos los vendedores/lotes) — por eso "no debía haber zonas que parezcan
degradados si debería existir una fotografía" nunca se podía cumplir: no
había fotos que mostrar. Se generaron 9 ilustraciones de **demostración**
(paisajes de cafetal, granos, cerezas, taza, empaque, camas de secado;
`tools/generar_imagenes_demo.py`, con Pillow) como `assets/demo/*.jpg`,
declaradas en `pubspec.yaml`, y `MockStore` ahora asigna 2 a 6 fotos por
vendedor y 1 a 4 por lote — así la galería, el detalle y las tarjetas
muestran fotografías reales y no solo placeholders.
**Importante**: son ilustraciones generadas, no fotografías reales de fincas;
reemplázalas cuando existan fotos reales.

### SwipeCard: nueva composición
Foto protagonista (58 % de la altura) sin degradado ni texto encima; panel
sólido debajo con jerarquía clara: nombre del café, marca del vendedor,
"región · variedad · proceso", precio grande, y un único botón "Ver perfil"
(compacto, 38-42px). Insignias (verificado, "Coincide con tus preferencias",
calificación) se movieron a la esquina de la foto. La pista "Desliza" es
ahora una etiqueta pequeña en la esquina, y desaparece sola tras 3 gestos.

### SwipeModeView: acciones sin redundancia
Se eliminó el tercer botón circular "Ver perfil" que existía debajo del
mazo (quedaba duplicado con el botón ya visible dentro de la tarjeta). Ahora
solo hay dos decisiones explícitas abajo — **Descartar** / **Me interesa** —
con ícono + texto (no solo ícono), y equivalen exactamente al gesto. Si el
diálogo de "Me interesa" se cancela (o la solicitud ya existía), la tarjeta
vuelve al mazo (`CardSwiperController.undo()`) en vez de perderse.

### Relevancia y "Coincide con tus preferencias" (antes "Para ti")
`puntuarLote` se reescribió con una fórmula explícita y documentada (0–100
puntos): 55 preferencias directas (variedad/proceso/región, proporcional a
cuántas coincidieron de las que el comprador configuró), 15 precio, 15
disponibilidad, 15 calidad (puntaje de taza). `coincideConPreferencias` ahora
exige disponibilidad + respetar el precio máximo + coincidir en **todas** las
preferencias configuradas (si solo configuró una) o en **al menos dos** (si
configuró varias) — ya no basta con un solo dato suelto para etiquetar un
café como recomendado.

### Búsqueda sin tildes
`_normalizar` (nuevo, en `MockStore`) quita tildes antes de comparar, así
"narino" encuentra "Nariño" y "cafe" encuentra "café".

### Archivos nuevos
`widgets/zoomable_image.dart`, `utils/image_source.dart`, `utils/focus_utils.dart`,
`widgets/dismiss_keyboard.dart`, `services/home_tab_notifier.dart`,
`screens/discover/search_screen.dart`, `tools/generar_imagenes_demo.py`,
`assets/demo/*.jpg` (9 archivos)

### Archivos modificados (más relevantes)
`data/mock_store.dart` (catalogRevision, numFiltrosActivos, búsqueda sin
tildes, puntuarLote/coincideConPreferencias reescritos, fotos demo),
`widgets/fullscreen_image_viewer.dart` (reescrito), `widgets/app_image.dart`
(reescrito), `widgets/swipe_card.dart` (reescrito), `widgets/coffee_lot_card.dart`,
`widgets/interest_dialog.dart` (confirmación + "Ver solicitudes" + devuelve bool),
`screens/discover/discover_screen.dart` (reescrito), `screens/discover/swipe_mode_view.dart`
(reescrito), `screens/discover/list_mode_view.dart`, `screens/discover/filters_sheet.dart`,
`screens/home/home_shell.dart` (usa HomeTabNotifier), `screens/chat/chat_screen.dart`,
`screens/chat/quote_request_screen.dart`, `screens/seller/seller_profile_edit_screen.dart`,
`screens/seller/coffee_lot_edit_screen.dart`, `screens/profile/my_profile_screen.dart`,
`main.dart`, `pubspec.yaml` (assets)

### "Implementado" vs "verificado mediante ejecución" — muy importante
Este entorno no tiene el SDK de Flutter, así que **nada de esto se ejecutó
en un emulador o dispositivo real**. Todo lo anterior está **implementado**
(el código existe, está escrito con la lógica descrita) y pasó una
verificación **estática** exhaustiva: balance de llaves/paréntesis y
validez de imports en los 44 archivos `.dart`, y un cruce automático de los
parámetros de cada widget nuevo/reescrito contra todos sus usos reales en el
proyecto. Ninguno de los 16 casos de prueba de la sección 33 del PDF fue
**verificado mediante ejecución** — no puedo afirmar que lo probé, solo que
el código está escrito para producir ese comportamiento. Recomiendo
encarecidamente correr `flutter analyze` y los 16 casos manuales en tu
máquina antes de dar esto por cerrado.

### Riesgos conocidos que no pude verificar
- `CardSwiperController.undo()` (usado para "Deshacer descarte" y para
  devolver la tarjeta al mazo si se cancela "Me interesa") existe en la API
  pública de `flutter_card_swiper` según su documentación, pero no pude
  confirmarlo compilando. Si el nombre del método difiera en la versión
  instalada, `flutter analyze` lo señalará de inmediato en ese único archivo
  (`swipe_mode_view.dart`).
- El umbral y la sensibilidad del cierre por gesto vertical en el visor
  (110 px o velocidad > 900) son valores razonables pero no ajustados con
  pruebas táctiles reales.

### Pendientes / no incluido en esta ronda (a propósito)
Pagos, Firebase, geolocalización, IA, pedidos reales, logística, panel
administrativo — tal como pidió el PDF. Tampoco se hizo una auditoría
exhaustiva de cada margen/tipografía de toda la app (sección 34): se ajustaron
los puntos señalados explícitamente (Discover, SwipeCard, selector de modo,
botones Filtrar/Ordenar); el resto de pantallas conserva el estilo de la
ronda anterior.
