# CUARTA RONDA DE MEJORAS — LOTEA CAFÉ
## Migración a Firebase, eliminación de datos demo, nueva identidad y cotizaciones comerciales completas

Quiero realizar la cuarta ronda de desarrollo del proyecto Flutter + Dart que anteriormente se llamaba CaféMatch y que ahora se llamará **Lotea Café**.

Lotea Café es un marketplace móvil especializado en café, inicialmente orientado al mercado colombiano. Su objetivo es conectar productores y vendedores de café con compradores, permitiéndoles explorar perfiles, publicar lotes, enviar solicitudes comerciales, conversar y negociar cotizaciones.

El proyecto actual ya dispone de pantallas para descubrimiento, búsqueda, filtros, perfiles de vendedores, lotes, favoritos, solicitudes comerciales, conversaciones y creación de solicitudes de cotización.

La prioridad de esta cuarta fase es convertirlo en una aplicación con datos persistentes y cuentas reales utilizando Firebase, eliminar los datos de demostración y completar el proceso comercial de cotización.

## REGLAS GENERALES

1. No rehagas el proyecto desde cero.
2. Revisa primero todo el código de la versión que te proporciono.
3. Conserva las pantallas, los widgets, el tema visual y las funcionalidades que ya funcionan.
4. No elimines funcionalidades existentes simplemente para simplificar el desarrollo.
5. Mantén Flutter + Dart. La aplicación es móvil, no web.
6. Utiliza Firebase como backend.
7. No incorpores datos falsos de vendedores, compradores, cafés, conversaciones, solicitudes, calificaciones o cotizaciones.
8. No implementes pagos reales, compras reales ni logística en esta fase.
9. No inventes credenciales, claves, identificadores de proyecto ni configuración de Firebase.
10. No dejes las reglas de seguridad abiertas.
11. No afirmes haber probado funcionalidades que realmente no hayas ejecutado.
12. Si encuentras problemas en la arquitectura actual, corrígelos de forma progresiva y explica los cambios.

Antes de editar, identifica la estructura actual y explica brevemente qué conservarás, qué refactorizarás y cómo organizarás la migración.

---

# 1. CAMBIAR LA IDENTIDAD DE LA APLICACIÓN A LOTEA CAFÉ

El nombre definitivo será:

**Lotea Café**

Eslogan:

**Descubre. Compara. Conecta.**

La aplicación debe identificarse en toda su interfaz con esta marca.

Revisa y actualiza:

- Nombre del proyecto en `pubspec.yaml`, si procede.
- Nombre de la clase principal y comentarios que todavía utilicen CaféMatch.
- Título de `MaterialApp`.
- Pantalla de inicio de sesión.
- Registro.
- Onboarding.
- Pantallas de comprador y vendedor.
- Mensajes, encabezados y estados vacíos.
- README y documentación.
- Textos visibles y referencias a CaféMatch.
- Metadatos de la aplicación móvil, cuando exista la configuración nativa.

Para el nombre interno de Dart utiliza el formato apropiado, por ejemplo `lotea_cafe`, sin espacios ni tildes. Actualiza las importaciones de paquete que dependan del nombre anterior.

No cambies de forma improvisada el identificador técnico de Android. Si hace falta definir o cambiar el `applicationId`, explica la decisión antes de hacerlo.

## Identidad visual

Mantén una identidad relacionada con el café colombiano y el comercio entre productores y compradores.

Paleta sugerida:

- Café oscuro: `#3E2723`
- Café tostado: `#6F4E37`
- Crema: `#FBF3E7`
- Verde cafetal: `#3F6C51`
- Beige: `#D7B899`

Utiliza estos colores como referencia y conserva las decisiones del tema actual cuando sean coherentes con la marca.

Si te adjunto la imagen de referencia del logotipo, utilízala como referencia visual. No uses toda la composición de presentación como si fuera el icono de la aplicación: el icono debe contener únicamente el símbolo, legible a tamaño pequeño.

Organiza los recursos de marca, por ejemplo:

- `assets/branding/lotea_cafe_logo.png`
- `assets/branding/lotea_cafe_icon.png`

Si es posible, configura el icono de aplicación para Android mediante una herramienta apropiada como `flutter_launcher_icons`. No generes archivos finales falsos ni afirmes haber configurado un icono nativo si faltan los recursos o la estructura Android.

El logotipo completo se utiliza dentro de la interfaz; el símbolo aislado se utiliza para el icono.

---

# 2. ELIMINAR EL ACCESO DEMO

Actualmente la pantalla `LoginScreen` incluye una acción similar a:

`Entrar como comprador demo`

Debe desaparecer completamente de la interfaz y del flujo de autenticación.

Elimina también:

- La función `_accesoRapidoComprador()`.
- Las credenciales del comprador demo.
- La lógica para registrar automáticamente ese usuario.
- Cualquier mecanismo que permita acceder sin una cuenta real.
- Cualquier ruta alternativa que dependa de los usuarios demo.

El inicio de sesión debe realizarse exclusivamente con Firebase Authentication.

No reemplaces el botón demo por otro acceso que cree automáticamente una cuenta.

---

# 3. ELIMINAR LOS DATOS DE PRUEBA DEL CATÁLOGO

Actualmente `MockStore` contiene datos generados mediante `_sembrarDatosDemo()`.

Quiero que elimines la inicialización automática de vendedores y lotes de demostración del flujo normal de producción.

La aplicación no debe crear automáticamente:

- Vendedores demo.
- Compradores demo.
- Cafés demo.
- Perfiles con fotografías ficticias presentadas como fotografías reales.
- Calificaciones ficticias.
- Vendedores verificados ficticios.
- Operaciones comerciales ficticias.
- Solicitudes y conversaciones de prueba.

Retira también las contraseñas almacenadas manualmente en `_passwords`. Firebase Authentication será responsable de la autenticación.

Revisa los recursos `assets/demo/` y `tools/generar_imagenes_demo.py`. Elimina los que ya no sean necesarios, pero comprueba antes que ningún componente todavía dependa de ellos.

Si una fotografía no existe, utiliza un placeholder visual que indique que no hay fotografía. No muestres una imagen de demostración como si perteneciera a una finca real.

Los datos de prueba de las pruebas automatizadas pueden mantenerse dentro de `test/`, aislados de la aplicación que utiliza un usuario real.

## Comportamiento sin datos

Al eliminar los datos demo, el catálogo de un comprador nuevo puede estar vacío. Esto es correcto.

No vuelvas a llenar el catálogo con registros falsos para que la aplicación parezca más poblada.

En su lugar, diseña estados vacíos útiles.

Comprador:

«Todavía no hay cafés publicados».

«Cuando los productores publiquen sus lotes, podrás descubrirlos aquí».

Vendedor:

«Aún no tienes cafés publicados».

«Completa tu perfil y publica tu primer lote para que los compradores puedan encontrarlo».

Solicitudes:

«Todavía no tienes solicitudes comerciales».

Cotizaciones:

«Aquí aparecerán las cotizaciones que envíes o recibas».

Los estados vacíos deben diferenciarse de los errores de conexión.

No muestres el mensaje «No hay cafés disponibles» cuando el problema real sea que Firestore no pudo cargar la información.

---

# 4. INCORPORAR FIREBASE AL PROYECTO

Actualmente el proyecto no tiene una integración de Firebase configurada.

Quiero preparar el proyecto para utilizar estos servicios:

### Firebase Authentication

Registro, inicio de sesión, cierre de sesión, recuperación de contraseña y restauración de la sesión.

### Cloud Firestore

Persistencia de usuarios, perfiles de vendedor, lotes, solicitudes, favoritos, chats, mensajes y cotizaciones.

### Cloud Storage for Firebase

Preparar la subida y consulta de imágenes de perfiles, fincas y lotes de café.

### Firebase Security Rules

Proteger los datos y restringir las operaciones según el usuario autenticado y su rol.

## Dependencias

Revisa las versiones compatibles con el SDK de Flutter y el archivo `pubspec.yaml`.

Añade únicamente las dependencias necesarias para:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`

Conserva `provider` si continúa siendo apropiado para el estado de la aplicación.

No añadas dependencias innecesarias.

## Configuración de Firebase

El proyecto compartido no contiene `lib/firebase_options.dart` ni configuración nativa de Firebase.

Por tanto:

- No inventes `FirebaseOptions`.
- No inventes `google-services.json`.
- No generes claves falsas.
- No uses credenciales administrativas.
- No finjas que el proyecto ya está conectado a una base de datos real.
- No dejes importaciones hacia archivos inexistentes.

Prepara la integración de Firebase y crea una guía `FIREBASE_SETUP.md` que explique exactamente los pasos manuales pendientes.

La guía debe cubrir:

1. Crear o seleccionar un proyecto en Firebase Console.
2. Confirmar el identificador de paquete Android.
3. Generar la estructura nativa de Android si todavía no existe.
4. Instalar Firebase CLI y FlutterFire CLI.
5. Ejecutar `flutterfire configure`.
6. Generar la configuración correspondiente a la plataforma.
7. Activar Email/Password en Firebase Authentication.
8. Crear la base de datos Cloud Firestore.
9. Configurar Cloud Storage cuando corresponda.
10. Instalar las reglas y los índices preparados por el proyecto.
11. Ejecutar la aplicación y verificar la conexión.

Si el entorno no permite generar la configuración real porque requiere que yo inicie sesión o seleccione un proyecto, deja documentado el paso pendiente. No presentes la integración como terminada si depende de una acción que todavía no se ha realizado.

La aplicación debe compilar sin archivos de configuración inventados. Si falta la configuración real de Firebase al ejecutar, muestra un error comprensible que explique el paso pendiente, sin volver a activar el sistema demo.

---

# 5. INICIALIZAR FIREBASE CORRECTAMENTE

Prepara la inicialización de Firebase para que se realice una sola vez antes de ejecutar la aplicación.

Cuando exista la configuración generada por FlutterFire, utiliza el mecanismo apropiado para inicializar Firebase en las plataformas configuradas.

Gestiona adecuadamente:

- Inicialización correcta.
- Falta de configuración.
- Error de conexión.
- Error de autenticación.
- Error de permisos.
- Datos inexistentes.
- Reintento de una operación fallida.

No permitas que un error de inicialización termine en una pantalla completamente blanca.

No uses un `catch` general que oculte todos los errores y simule una conexión exitosa.

La aplicación debe distinguir entre no tener datos y no poder acceder a Firebase.

---

# 6. REEMPLAZAR MOCKSTORE POR UNA ARQUITECTURA DE DATOS REAL

Actualmente varias pantallas dependen directamente de `MockStore`.

Necesito reemplazar esa dependencia por servicios o repositorios reales sin reescribir las pantallas innecesariamente.

Evalúa una estructura semejante a:

`lib/repositories/`

- `auth_repository.dart`
- `user_repository.dart`
- `seller_repository.dart`
- `coffee_lot_repository.dart`
- `interest_request_repository.dart`
- `favorite_repository.dart`
- `chat_repository.dart`
- `quote_repository.dart`

Puedes adaptar los nombres a la estructura existente.

El objetivo es que los widgets no tengan que conocer directamente los detalles de Firestore.

Los repositorios deben concentrar:

- Consultas.
- Creación y actualización de documentos.
- Conversión de modelos.
- Validaciones esenciales.
- Gestión de errores.
- Suscripciones cuando se requieran datos en tiempo real.

Utiliza operaciones asíncronas con `Future` y `Stream` según corresponda.

No simules que una operación fue guardada si Firestore la rechazó.

No mantengas un `MockStore` como fuente de datos de la aplicación normal.

Si necesitas repositorios falsos para probar widgets, mantenlos únicamente en pruebas automatizadas o en un entorno de desarrollo claramente separado.

---

# 7. MODELO DE DATOS EN FIRESTORE

Diseña una estructura clara, consistente y documentada.

Como base, considera estas colecciones.

## `users/{uid}`

Información privada y general de la cuenta:

- UID.
- Correo electrónico.
- Nombre.
- Rol.
- Ciudad, cuando corresponda.
- Preferencias del comprador.
- Estado de onboarding.
- Fecha de creación.
- Fecha de actualización.

No guardes contraseñas en Firestore.

El rol debe ser estable y no poder modificarse arbitrariamente desde el cliente después del registro.

## `sellerProfiles/{uid}`

Perfil público del vendedor:

- UID del propietario.
- Nombre de marca.
- Finca principal.
- Descripción.
- Historia.
- Ubicación.
- Departamento.
- Municipio.
- Datos de producción.
- Rutas o referencias de fotografías.
- Fecha de creación y actualización.

No inventes certificaciones, estadísticas de ventas o verificaciones.

## `coffeeLots/{lotId}`

Información de cada lote de café:

- ID.
- `sellerId`.
- Nombre.
- Variedades.
- Proceso.
- Tipo de café.
- Altitud.
- Puntaje de taza, cuando exista.
- Cosecha.
- Perfil sensorial.
- Descripción.
- Precio en COP.
- Unidad de venta.
- Cantidad disponible.
- Pedido mínimo.
- Disponibilidad.
- Certificaciones.
- Rutas de fotografías.
- Estado del lote.
- Fecha de publicación.

Cada lote debe pertenecer a un vendedor.

Un vendedor puede tener varios lotes.

Los lotes en borrador no deben aparecer en el catálogo público.

## `interestRequests/{requestId}`

Solicitudes comerciales:

- ID.
- Comprador.
- Vendedor.
- Lote.
- Mensaje opcional.
- Estado.
- Fecha de creación.
- Fecha de actualización.

Solo debe establecerse una conexión comercial cuando el vendedor acepte la solicitud.

## Favoritos

Utiliza una estructura sencilla que permita que cada comprador gestione sus propios favoritos.

Por ejemplo:

`users/{uid}/favorites/{favoriteId}`

Cada favorito debe identificar si corresponde a un vendedor o un lote.

Evita duplicados.

## `chats/{connectionId}`

Una conversación debe corresponder a una conexión comercial autorizada.

Los mensajes pueden almacenarse en:

`chats/{connectionId}/messages/{messageId}`

Cada mensaje debe guardar el remitente, el contenido y la fecha.

Solo los participantes autorizados pueden consultar o enviar mensajes.

## `quotes/{quoteId}`

Las solicitudes de cotización y sus ofertas deben persistirse en una colección propia.

El modelo debe permitir que la solicitud inicial y la respuesta comercial queden registradas en un mismo documento coherente, sin perder información.

Incluye al menos:

- ID.
- ID de la conexión comercial.
- ID del comprador.
- ID del vendedor.
- ID del lote.
- Cantidad solicitada.
- Unidad.
- Lugar de entrega.
- Comentario del comprador.
- Estado de la cotización.
- Fecha de creación y actualización.
- Datos de la oferta del vendedor cuando exista.
- Historial o registro de los cambios importantes, si resulta razonable.

Si modificas los modelos existentes, conserva la coherencia con las pantallas y documenta la migración.

---

# 8. REGISTRO CON FIREBASE AUTHENTICATION

El formulario actual de registro debe utilizar cuentas reales.

Flujo esperado:

Registro
→ Validación
→ Crear cuenta en Firebase Authentication
→ Crear documento del usuario en Firestore
→ Configurar el perfil inicial
→ Mostrar onboarding
→ Acceder a la experiencia correspondiente al rol.

El registro debe conservar las dos opciones:

- Comprar café.
- Vender café.

El usuario registrado debe recibir un UID de Firebase Authentication que se utilice como identidad de su perfil.

No guardes las contraseñas dentro del documento del usuario.

Gestiona mensajes comprensibles para errores como:

- Correo ya registrado.
- Correo inválido.
- Contraseña demasiado débil.
- Credenciales incorrectas.
- Falta de conexión.
- Error al crear el perfil después de registrar la cuenta.

Si Authentication crea una cuenta pero falla la escritura de su documento en Firestore, maneja la inconsistencia de forma recuperable. No crees cuentas duplicadas silenciosamente.

Implementa recuperación de contraseña mediante Firebase Authentication.

La verificación del correo electrónico puede incorporarse con un flujo claro, sin bloquear indefinidamente al usuario ni perder su sesión.

---

# 9. SESIÓN PERSISTENTE Y NAVEGACIÓN POR ROL

Revisa `SessionProvider`, `HomeShell` y la inicialización de la app.

El estado de sesión no debe mantenerse únicamente en una variable en memoria.

Utiliza el estado de autenticación de Firebase para determinar si existe una sesión válida.

Flujo:

Aplicación abierta
→ Revisar estado de autenticación
→ Si no existe sesión, LoginScreen.
→ Si existe sesión, cargar el documento del usuario.
→ Abrir la pantalla correspondiente al rol.

No mostrar la pantalla de inicio de sesión durante unos instantes si el usuario ya tiene una sesión válida.

Maneja el caso en que exista una sesión de Authentication, pero todavía no exista el documento del usuario o esté incompleto.

El usuario podrá cerrar sesión desde su perfil.

Al cerrar sesión:

- Ejecutar `signOut()` de Firebase.
- Limpiar el estado privado en memoria.
- Regresar a LoginScreen.
- Impedir que aparezca información del usuario anterior.

Los compradores no deben acceder a las herramientas exclusivas de los vendedores y viceversa.

---

# 10. FLUJO INICIAL SIN DATOS DE PRUEBA

El primer usuario real puede ser un comprador y no existir todavía ningún café publicado.

La aplicación debe manejar correctamente este escenario.

## Comprador nuevo

Después del registro:

1. Configurar datos básicos.
2. Elegir el tipo de comprador si corresponde.
3. Configurar preferencias opcionales.
4. Llegar a Descubrir.
5. Ver el estado vacío cuando aún no existen lotes publicados.

## Vendedor nuevo

Después del registro:

1. Crear la cuenta.
2. Completar el perfil comercial.
3. Registrar la información básica de su finca o marca.
4. Publicar el primer lote.
5. Ver el estado del catálogo.

El vendedor debe poder guardar su perfil progresivamente sin tener que completar campos opcionales innecesarios.

Las validaciones de publicación deben seguir diferenciando los campos obligatorios de los opcionales.

No obligues a inventar una galería, certificaciones, calificaciones o puntajes de taza para continuar.

---

# 11. PERSISTENCIA DE PERFILES Y LOTES

Conecta los formularios actuales a los repositorios reales:

- `SellerProfileEditScreen`
- `CoffeeLotEditScreen`
- `MyCoffeeLotsScreen`
- `MyProfileScreen`
- `SellerDetailScreen`
- `CoffeeLotDetailScreen`

Cuando un vendedor cree un lote:

- Asigna el UID autenticado como propietario.
- Guarda los datos en Firestore.
- Maneja borradores y publicación.
- Refresca el catálogo.
- Muestra el resultado solamente si la operación tiene éxito.

Cuando edite su perfil o un lote, los cambios deben persistir después de cerrar y abrir la aplicación.

No permitas que un vendedor edite lotes pertenecientes a otro usuario.

Los compradores deben consultar los perfiles públicos y únicamente los lotes publicados.

---

# 12. SUBIDA DE FOTOGRAFÍAS A CLOUD STORAGE

Actualmente los modelos utilizan algunas rutas de archivos locales.

Esto no es suficiente para un marketplace real: una ruta local del teléfono de un vendedor no es accesible desde los dispositivos de los compradores.

Implementa un servicio de imágenes para Cloud Storage.

Requisitos:

- Seleccionar imágenes desde el dispositivo.
- Previsualizar antes de subir.
- Subir a una ruta asociada al UID y al perfil o lote.
- Guardar en Firestore la referencia necesaria para recuperar la imagen.
- Cargar las imágenes desde la red.
- Mantener el visor de imágenes existente.
- Mostrar progreso, error y opción de reintentar.
- Permitir eliminar una imagen propia.
- Evitar borrar imágenes pertenecientes a otros usuarios.
- Gestionar la sustitución de la imagen principal.
- Evitar subir varias veces el mismo archivo innecesariamente.

Actualiza `AppImage` y las utilidades de fuente de imágenes para que soporten correctamente las imágenes remotas.

No guardes los bytes de una fotografía dentro del documento de Firestore.

Si Cloud Storage no está configurado, informa claramente del requisito pendiente y no finjas que las imágenes se han publicado.

Documenta que Cloud Storage for Firebase requiere actualmente el plan Blaze de pago por uso, según la guía oficial. No habilites facturación automáticamente ni realices acciones económicas sin mi intervención. La configuración de Storage debe realizarse conscientemente. 

---

# 13. COMPLETAR LAS COTIZACIONES COMERCIALES

ESTA ES UNA DE LAS PRIORIDADES PRINCIPALES.

Actualmente `QuoteRequestScreen` permite solicitar una cotización desde una conexión comercial, pero el proceso no está terminado.

Quiero implementar un flujo comercial real y coherente.

La cotización debe dejar de ser solamente un formulario que guarda una cantidad y un comentario.

Debe permitir que el comprador solicite condiciones comerciales y que el vendedor responda con una oferta concreta.

## 13.1. Revisar el modelo actual

Analiza `lib/models/quote_request.dart`.

Actualmente contiene campos como:

- `interestRequestId`
- `compradorId`
- `sellerId`
- `coffeeLotId`
- `cantidad`
- `unidad`
- `comentario`
- `lugarEntrega`
- `estado`
- `fecha`

Conserva los campos útiles, pero amplía el modelo para representar correctamente el ciclo completo.

No te limites a agregar botones que cambien un texto.

## 13.2. Estados de la cotización

Diseña un conjunto de estados explícitos.

Como mínimo, contempla:

- Solicitud pendiente de respuesta del vendedor.
- Oferta enviada por el vendedor.
- Revisión solicitada por el comprador.
- Oferta aceptada por el comprador.
- Oferta rechazada por el comprador.
- Solicitud rechazada por el vendedor.
- Solicitud cancelada, cuando corresponda.
- Oferta vencida, si se implementa su vigencia.

Evita usar un solo estado ambiguo como `aceptada` sin indicar quién realizó la acción.

Utiliza enums consistentes y un método centralizado para validar transiciones.

No permitas que cualquier usuario cambie el estado a voluntad.

## 13.3. El comprador solicita una cotización

Desde una conexión comercial aceptada, el comprador debe poder abrir «Solicitar cotización».

El formulario debe incluir:

- Café relacionado.
- Cantidad requerida.
- Unidad.
- Lugar de entrega opcional.
- Comentario opcional.

Validaciones:

- Cantidad mayor que cero.
- Unidad permitida.
- Lugar de entrega con longitud razonable.
- Comentarios con límite de longitud.
- Conexión comercial válida.
- No permitir una solicitud para un lote que no corresponde a esa conexión.
- No permitir duplicados accidentales al pulsar varias veces el botón de envío.

Al enviar:

1. Guardar en Firestore.
2. Mostrar confirmación.
3. Mostrar el estado de la solicitud.
4. Dejar visible el acceso al detalle de la cotización.
5. Mostrar un error y permitir reintentar si falla la operación.

No marques como enviada una cotización hasta que se confirme que se guardó correctamente.

## 13.4. El vendedor recibe la cotización

Actualmente falta un flujo claro para que el vendedor responda.

Créalo.

El vendedor debe disponer de una sección donde pueda revisar las solicitudes de cotización que le han enviado.

Puede ser una pantalla como:

`ReceivedQuotesScreen`

o el nombre que mejor encaje en la navegación existente.

Cada tarjeta debe mostrar:

- Comprador.
- Café.
- Cantidad y unidad solicitadas.
- Lugar de entrega, si existe.
- Fecha.
- Comentario.
- Estado.

Debe existir una acción:

«Ver solicitud».

El vendedor debe poder abrir el detalle y responder.

No mezcles las solicitudes comerciales de conexión con las solicitudes de cotización de forma que resulte imposible distinguirlas.

La interfaz debe explicar con claridad en qué fase se encuentra cada operación.

## 13.5. El vendedor prepara una oferta

El vendedor debe poder enviar una respuesta comercial concreta.

Como mínimo, incluir:

- Precio unitario cotizado en COP.
- Unidad a la que corresponde el precio.
- Costo de envío, cuando corresponda.
- Total estimado.
- Tiempo estimado de entrega.
- Vigencia de la oferta, si se establece.
- Condiciones comerciales.
- Mensaje opcional del vendedor.

Ejemplo ilustrativo:

Cantidad solicitada: 50 kg.

Precio cotizado: $35.000 por kg.

Subtotal: $1.750.000.

Envío: $80.000.

Total estimado: $1.830.000 COP.

Estos valores son solamente un ejemplo de cálculo. No los uses como cotización real ni los incorpores como registros precargados.

Los totales deben calcularse con una lógica centralizada y validarse antes de guardar.

Al enviar la oferta:

- Guardar los datos en Firestore.
- Cambiar el estado a «Oferta enviada».
- Registrar la fecha.
- Mostrar al comprador la respuesta.
- Permitir al vendedor consultar el historial de sus cotizaciones.

El vendedor no debe poder responder una cotización de otro vendedor.

## 13.6. El comprador revisa la oferta

Crea una pantalla de detalle de la cotización que presente claramente:

- Café.
- Vendedor.
- Cantidad.
- Precio por unidad.
- Subtotal.
- Envío.
- Total.
- Entrega estimada.
- Condiciones.
- Vigencia.
- Mensaje del vendedor.
- Estado.

Si el vendedor todavía no ha respondido, mostrar:

«Esperando respuesta del vendedor».

No muestres importes en blanco como si fueran cero.

Si el precio todavía no está definido, debe quedar claro que se encuentra pendiente.

## 13.7. El comprador responde a la oferta

El comprador debe poder:

- Aceptar oferta.
- Rechazar oferta.
- Solicitar un ajuste o una nueva propuesta, cuando corresponda.

Antes de aceptar o rechazar, pide una confirmación sencilla.

Si acepta, registra el evento y muestra:

«Has aceptado la cotización».

Si rechaza, registra el resultado sin borrar el historial.

Si pide un ajuste, cambia el estado de manera coherente para que el vendedor sepa que debe revisar la solicitud.

No implementes todavía pedidos ni pagos. Aceptar una cotización no debe simular que se efectuó una compra o que se transfirió dinero.

## 13.8. Validar quién puede hacer cada acción

El comprador puede:

- Crear su solicitud.
- Consultar sus propias cotizaciones.
- Aceptar, rechazar o pedir ajustes sobre ofertas dirigidas a él.

El vendedor puede:

- Consultar cotizaciones dirigidas a él.
- Enviar una oferta sobre una solicitud válida.
- Rechazar una solicitud recibida.
- Responder una petición de ajuste cuando corresponda.

Ningún usuario debe poder cambiar su rol desde la interfaz para saltarse estas restricciones.

## 13.9. Historial y actualizaciones

El detalle de la cotización debe mostrar el estado actual y los eventos importantes.

Al menos:

- Solicitud creada.
- Oferta enviada.
- Oferta aceptada o rechazada.
- Solicitud de ajuste, si existió.

Utiliza timestamps coherentes.

No permitas que se cambien silenciosamente precios de ofertas que ya fueron aceptadas.

Si necesitas conservar propuestas anteriores, añade un historial simple de versiones.

No construyas un sistema de negociación complejo si basta con una propuesta y una posible revisión para el MVP.

## 13.10. Acceso a cotizaciones

Tanto comprador como vendedor deben poder encontrar fácilmente sus cotizaciones.

Para el comprador:

- Desde la conexión comercial.
- Desde el chat.
- Desde «Mis solicitudes» o una sección de cotizaciones.

Para el vendedor:

- Desde sus solicitudes recibidas.
- Desde su área de gestión comercial.
- Desde el detalle del comprador cuando corresponda.

Evita saturar la navegación inferior con demasiadas pestañas.

Puedes incluir accesos dentro de las secciones existentes siempre que resulten claros.

---

# 14. CHAT COMERCIAL

Conserva el chat actual, pero intégralo con la nueva arquitectura de Firebase.

Cada conversación debe vincularse a una conexión comercial aceptada.

Los mensajes deben persistir en Firestore.

El chat debe mostrar:

- Nombre del interlocutor.
- Café relacionado.
- Acceso a ver el lote.
- Acceso a solicitar cotización.
- Últimos mensajes.
- Fecha de los mensajes.
- Estado de carga.
- Estado sin mensajes.
- Error de envío y opción de reintentar.

No permitas enviar mensajes a un chat ajeno.

No permitas crear una conversación comercial nueva sin la conexión requerida por las reglas de negocio.

No es necesario implementar notificaciones push en esta fase, pero deja la estructura preparada para ellas.

---

# 15. REGLAS DE SEGURIDAD DE FIRESTORE

Crea reglas de seguridad específicas y restrictivas.

Entrega un archivo:

`firestore.rules`

Las reglas deben comprobar, como mínimo:

- Un usuario solamente puede modificar su propio documento privado.
- El rol no puede cambiarse arbitrariamente después del registro.
- Un vendedor solo puede modificar su propio perfil.
- Un vendedor solo puede crear, editar o retirar sus propios lotes.
- Los compradores solo pueden crear solicitudes para sí mismos.
- Un vendedor solo puede aceptar o rechazar solicitudes dirigidas a él.
- Solo los participantes autorizados pueden acceder a una solicitud.
- Solo los participantes de una conexión autorizada pueden leer sus chats.
- Solo los participantes correspondientes pueden enviar mensajes.
- Solo el comprador y el vendedor correspondientes pueden acceder a una cotización.
- Las modificaciones de una cotización dependen del rol y del estado válido.
- Los favoritos pertenecen al comprador autenticado.

Evita reglas como:

`allow read, write: if true;`

No basta con proteger la interfaz. Las reglas deben impedir las acciones no autorizadas aunque alguien intente acceder a Firestore desde otro cliente.

Revisa también `storage.rules` para asegurar que cada usuario únicamente pueda subir, modificar o eliminar sus propias imágenes.

Crea `firestore.indexes.json` con los índices que realmente requieran las consultas de la aplicación.

Si todavía no existe una conexión de Firebase, entrega los archivos listos y explica cómo publicarlos. No afirmes haber desplegado las reglas si no lo hiciste.

---

# 16. MEJORAS DE USABILIDAD DE ESTA FASE

Quiero mejorar la facilidad de uso, pero sin añadir muchas pantallas innecesarias.

## Inicio de sesión

- Eliminar el acceso demo.
- Botón para mostrar u ocultar la contraseña.
- Validación de campos.
- Recuperación de contraseña.
- Errores en español.
- Indicador de carga al iniciar sesión.
- Deshabilitar el botón mientras se procesa una solicitud.

## Registro

- Mantener una elección clara: «Comprar café» o «Vender café».
- Validar el correo.
- Confirmar los requisitos de contraseña.
- Mostrar errores de Firebase de manera comprensible.
- Evitar crear cuentas duplicadas.
- Restaurar la navegación correcta según el rol.

## Catálogo

- Mantener búsqueda, filtros y ordenamiento.
- Los filtros deben consultar los datos reales.
- Mostrar estados de carga y error.
- No confundir ausencia de resultados con errores de conexión.
- No cargar lotes en borrador.
- Mantener una experiencia razonable cuando existan muchos lotes.

## Formularios

En todos los formularios de edición:

- Mostrar guardado en curso.
- Evitar envíos repetidos.
- Mostrar errores junto al campo correspondiente.
- Confirmar cuando el guardado se complete.
- Mantener los datos si falla una operación.
- Evitar que cerrar una pantalla borre cambios sin confirmación cuando sean importantes.

## Experiencia del vendedor

El vendedor debe poder identificar fácilmente:

- Si ya completó su perfil.
- Cuántos lotes tiene publicados.
- Si tiene lotes en borrador.
- Cuántas solicitudes comerciales tiene pendientes.
- Cuántas cotizaciones necesitan su respuesta.

No inventes contadores. Los indicadores deben calcularse desde los datos reales.

## Experiencia del comprador

El comprador debe poder distinguir:

- Solicitudes comerciales enviadas.
- Conexiones aceptadas.
- Cotizaciones pendientes.
- Ofertas recibidas.
- Cotizaciones aceptadas o rechazadas.

Los estados vacíos deben incluir una explicación y, cuando resulte apropiado, una acción para continuar.

## Errores y conexión

No dejes pantallas blancas.

No conviertas una excepción de Firebase en una lista vacía.

No muestres «Guardado con éxito» si Firestore ha rechazado la operación.

Distingue entre:

- Cargando.
- Sin resultados.
- Sin conexión.
- Sin permisos.
- Error recuperable.
- Configuración pendiente.

---

# 17. CONSULTAS, COSTOS Y RENDIMIENTO

Las consultas deben ser eficientes.

Evita descargar toda la colección de lotes y filtrar indiscriminadamente en el cliente.

Utiliza consultas por campos, límites, ordenamiento y paginación cuando sean necesarios.

Revisa las consultas de:

- Lotes publicados.
- Perfil del vendedor.
- Solicitudes recibidas.
- Solicitudes enviadas.
- Favoritos.
- Chats.
- Mensajes.
- Cotizaciones recibidas.
- Cotizaciones enviadas.

Asegúrate de que los índices requeridos estén documentados.

No crees listeners en tiempo real para pantallas que no los necesitan.

Libera las suscripciones cuando una pantalla deja de utilizarlas.

Evita duplicar lecturas y reconstrucciones innecesarias.

No actives funciones pagas adicionales sin justificar su necesidad.

Documenta cualquier servicio que requiera un plan de facturación específico.

---

# 18. MANTENER EL ESTADO DE LA APLICACIÓN CONSISTENTE

La persistencia real implica que los cambios deben mantenerse después de cerrar y abrir la aplicación.

Comprueba que:

- Un lote publicado continúe visible.
- Un lote editado refleje su última versión.
- Un favorito no desaparezca.
- Una solicitud enviada continúe en su estado correcto.
- Una solicitud aceptada mantenga la conexión.
- Un mensaje enviado continúe disponible.
- Una cotización tenga el mismo estado para comprador y vendedor.
- La oferta enviada por el vendedor aparezca al comprador correcto.
- Una cotización aceptada no vuelva a aparecer como pendiente.

Revisa cualquier estado que actualmente solo viva en `ChangeNotifier` o en memoria.

Si es estado remoto, su fuente de verdad debe ser Firebase.

---

# 19. NO IMPLEMENTAR TODAVÍA

No implementes en esta ronda:

- Pagos reales.
- Pasarelas de pago.
- Transferencias de dinero.
- Pedidos reales.
- Seguimiento real de envíos.
- Facturación.
- Comisiones automáticas.
- Inteligencia artificial.
- Panel administrativo avanzado.
- Notificaciones push complejas.

La cuarta fase debe concentrarse en identidad, autenticación, persistencia y cotización.

El flujo objetivo es:

Descubrir café
→ Consultar perfil y lote
→ Enviar solicitud comercial
→ Establecer conexión
→ Conversar
→ Solicitar cotización
→ El vendedor envía oferta
→ El comprador acepta, rechaza o pide revisión.

La aceptación de una cotización NO debe simular un pago ni una compra ejecutada.

---

# 20. DOCUMENTACIÓN Y CONFIGURACIÓN ENTREGABLE

Actualiza el `README.md` para reflejar que la aplicación se llama Lotea Café.

Incluye:

- Arquitectura general.
- Versión de Flutter y Dart requerida, según el proyecto.
- Dependencias.
- Estructura de carpetas.
- Configuración de Firebase.
- Modelo de colecciones.
- Configuración de reglas e índices.
- Gestión de imágenes.
- Flujo de autenticación.
- Flujo de cotización.
- Limitaciones conocidas.

Crea, cuando corresponda:

- `FIREBASE_SETUP.md`
- `firestore.rules`
- `storage.rules`
- `firestore.indexes.json`

No incluyas credenciales privadas, claves de cuentas de servicio ni contraseñas en el repositorio.

El archivo generado por FlutterFire puede contener configuración de cliente, pero no debe confundirse con una credencial administrativa.

---

# 21. PRUEBAS OBLIGATORIAS

Ejecuta las comprobaciones que permita el entorno.

Al menos:

`flutter pub get`

`flutter analyze`

Y las pruebas automatizadas disponibles.

Añade pruebas para los casos críticos:

### Autenticación

- Registro correcto.
- Correo duplicado.
- Contraseña incorrecta.
- Cierre de sesión.
- Restauración de sesión.

### Lotes

- Un vendedor crea un lote.
- Un vendedor edita su lote.
- Otro usuario no puede modificarlo.
- Un lote en borrador no aparece públicamente.
- Un lote publicado permanece después de reiniciar la aplicación.

### Solicitudes

- El comprador crea una solicitud propia.
- No puede duplicar una solicitud activa equivalente.
- Un vendedor no puede alterar una solicitud que pertenece a otro vendedor.
- Solo una solicitud aceptada habilita la conexión.

### Cotizaciones

- El comprador crea una solicitud de cotización válida.
- El vendedor destinatario recibe la solicitud.
- El vendedor prepara una oferta.
- El precio y el total se calculan correctamente.
- El comprador ve la oferta.
- El comprador puede aceptarla.
- El comprador puede rechazarla.
- El comprador puede solicitar una revisión.
- Un usuario no autorizado no puede modificar la cotización.
- La cotización conserva su estado tras reiniciar la aplicación.
- Ninguna acción simula pagos o pedidos reales.

Si no tienes Firebase configurado o el entorno no permite conectarse, utiliza pruebas unitarias o emuladores cuando sea posible y explica con precisión qué se probó y qué sigue pendiente.

No afirmes que se ha verificado una conexión real a Firebase si todavía no existe el proyecto o la configuración.

---

# 22. RESULTADO FINAL ESPERADO

Quiero que Lotea Café deje de ser una aplicación de demostración con datos en memoria y evolucione hacia un marketplace móvil con una base técnica real.

La versión resultante debe tener:

- Marca Lotea Café aplicada en la interfaz.
- Acceso demo eliminado.
- Datos demo eliminados del flujo normal.
- Registro e inicio de sesión con Firebase Authentication.
- Sesión persistente.
- Datos guardados en Cloud Firestore.
- Arquitectura preparada para Storage y fotografías remotas.
- Perfiles reales de compradores y vendedores.
- Lotes persistentes.
- Favoritos persistentes.
- Solicitudes comerciales persistentes.
- Chats persistentes y protegidos.
- Flujo de cotización completo.
- El vendedor puede enviar ofertas concretas.
- El comprador puede revisar y responder ofertas.
- Reglas de seguridad e índices preparados.
- Estados vacíos bien diseñados.
- Manejo de errores y carga.
- Documentación de configuración de Firebase.

Al terminar, entrégame un informe concreto con:

1. Archivos modificados.
2. Archivos nuevos.
3. Dependencias añadidas.
4. Colecciones de Firestore.
5. Reglas de seguridad creadas.
6. Cambios en Authentication.
7. Cambios en los modelos.
8. Cómo funciona ahora el flujo de cotización.
9. Cómo configurar Firebase desde mi equipo.
10. Qué configuraciones debo completar manualmente.
11. Qué pruebas ejecutaste realmente.
12. Qué queda pendiente.

Empieza revisando el código completo, planifica la migración y luego implementa los cambios. No te limites a escribir un plan: realiza la modificación del proyecto, dentro de las posibilidades del entorno.

Si una parte requiere mi intervención —por ejemplo, crear el proyecto en Firebase, iniciar sesión en las herramientas o habilitar facturación—, déjala claramente identificada y dame los pasos exactos. No inventes configuraciones ni ocultes limitaciones.