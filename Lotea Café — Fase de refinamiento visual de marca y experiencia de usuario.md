# Lotea Café — Fase de refinamiento visual de marca y experiencia de usuario

Quiero realizar una fase de correcciones visuales sobre el proyecto Flutter + Dart existente de **Lotea Café**.

Esta NO es una nueva ronda de funcionalidades comerciales. La prioridad es corregir el icono de la aplicación, el logotipo, la alineación de las pantallas iniciales y algunos detalles del registro.

Adjunto capturas de la APK instalada en mi Samsung A32 para mostrar los problemas visuales actuales.

## REGLAS IMPORTANTES

- Trabaja sobre el proyecto actual, no lo rehagas desde cero.
- Conserva Firebase Authentication, Cloud Firestore y todos los repositorios existentes.
- No modifiques las reglas de seguridad, los modelos comerciales ni los flujos de cotización.
- No elimines ninguna funcionalidad que ya esté funcionando.
- No cambies el identificador de la aplicación Android: `com.loteacafe.lotea_cafe`.
- No cambies el ID del proyecto Firebase: `lotea-cafe`.
- Conserva `lib/firebase_options.dart` y cualquier configuración Firebase existente.
- Conserva `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`, `storage.rules` y `FIREBASE_SETUP.md`.
- No reactives datos demo ni alteres los datos persistentes.
- No cambies el nombre técnico del paquete Flutter por el mero hecho de cambiar el nombre visible de la aplicación.
- No te limites a indicarme qué debo hacer: realiza los cambios en los archivos y recursos del proyecto.
- No afirmes que has ejecutado comandos o pruebas que no hayas podido ejecutar realmente.

Antes de empezar, inspecciona `pubspec.yaml`, las carpetas de recursos de marca, la configuración nativa de Android y las pantallas de inicio, registro y onboarding.

# 1. CORREGIR EL ICONO DE LA APLICACIÓN ANDROID

## Problema observado

En el menú de aplicaciones del teléfono aparece el icono azul predeterminado de Flutter y el nombre `lotea_cafe`.

Esto debe cambiarse.

## Resultado esperado

El icono debe representar la marca Lotea Café, utilizando el símbolo del grano de café con la hoja verde.

El icono debe ser sencillo, reconocible y legible cuando tenga un tamaño pequeño.

No debe contener el logotipo completo con texto diminuto. Utiliza únicamente el símbolo gráfico.

### Requisitos del icono

- Archivo cuadrado de alta resolución, preferiblemente 1024 × 1024.
- PNG con transparencia real en la capa frontal.
- Símbolo centrado.
- Márgenes de seguridad suficientes para que Android no recorte el grano.
- Colores de la marca.
- Fondo adaptativo en crema `#FBF3E7`.
- Sin el logotipo escrito dentro del icono.
- Sin marcas de agua.
- Sin bordes blancos o rectángulos accidentales dentro de la ilustración.

Si el proyecto ya contiene una versión adecuada del símbolo, reutilízala. Si no tiene un recurso limpio, crea una versión apropiada a partir de los recursos existentes.

No uses una captura de pantalla completa del logotipo como icono.

## Configuración técnica

Revisa las imágenes nativas que se generaron al crear el proyecto Flutter:

- `android/app/src/main/res/mipmap-mdpi/`
- `android/app/src/main/res/mipmap-hdpi/`
- `android/app/src/main/res/mipmap-xhdpi/`
- `android/app/src/main/res/mipmap-xxhdpi/`
- `android/app/src/main/res/mipmap-xxxhdpi/`

Comprueba también los recursos de iconos adaptativos, como `mipmap-anydpi-v26`, si existen.

Utiliza una herramienta apropiada, como `flutter_launcher_icons`, para generar los recursos nativos a partir de los archivos de marca. La herramienta permite configurar un primer plano transparente y un fondo adaptativo para Android.

No basta con cambiar un widget de Flutter: es necesario generar los iconos nativos que utiliza el sistema operativo.

Si incorporas una dependencia nueva, comprueba su compatibilidad con el proyecto existente y documenta el comando para generar los iconos.

Al terminar, el icono predeterminado de Flutter debe estar sustituido por el de Lotea Café.

# 2. CAMBIAR EL NOMBRE VISIBLE DE LA APLICACIÓN

Actualmente el teléfono muestra `lotea_cafe` debajo del icono.

Quiero que muestre:

**Lotea Café**

Revisa la configuración Android, especialmente:

`android/app/src/main/AndroidManifest.xml`

Si el nombre se obtiene desde recursos XML, actualiza el recurso correspondiente en lugar de duplicar el texto.

El nombre visible de la aplicación debe actualizarse en el menú de aplicaciones y en las ubicaciones donde Android lo muestre.

IMPORTANTE:

Mantén el `applicationId` actual, `com.loteacafe.lotea_cafe`, porque ya registramos esta aplicación en Firebase.

No cambies el identificador de paquete para solucionar el nombre visible.

# 3. ELIMINAR LOS FONDOS ACCIDENTALES DE LAS IMÁGENES DE MARCA

## Problema observado

En la pantalla de inicio de sesión se ve el logotipo horizontal de Lotea Café con un rectángulo ligeramente más claro detrás.

En el onboarding aparece el símbolo del grano dentro de una especie de recuadro crema.

Quiero que las imágenes de marca se integren naturalmente con el fondo de cada pantalla, sin rectángulos involuntarios.

### Inspeccionar los recursos existentes

Primero encuentra qué archivos se están utilizando para mostrar el logo y el símbolo.

Comprueba si el fondo está incorporado directamente en la imagen PNG o si lo está agregando el contenedor Flutter.

Hay dos posibles causas y debes solucionar la que corresponda:

1. Si el fondo está dibujado dentro de la imagen, reemplaza el recurso por uno con transparencia real.
2. Si el fondo se genera desde un `Container`, una tarjeta o una decoración, elimina el fondo innecesario.

No basta con cambiar `BoxFit`, reducir el tamaño de la imagen o hacer que el rectángulo tenga un color parecido al de la pantalla. Quiero que el fondo accidental desaparezca realmente.

## Recursos de marca

Organiza de forma clara los archivos necesarios, por ejemplo:

- `assets/branding/lotea_cafe_logo.png`
- `assets/branding/lotea_cafe_symbol.png`
- `assets/branding/lotea_cafe_icon_foreground.png`

Puedes conservar los nombres actuales si están bien organizados. No dupliques archivos innecesariamente.

El logotipo completo debe conservar el nombre «Lotea Café» y el eslogan:

«Descubre. Compara. Conecta.»

La versión del símbolo no debe incluir texto.

Si el logotipo horizontal existente tiene un fondo incrustado y no puede corregirse limpiamente, puedes componer el encabezado con el símbolo transparente y textos de Flutter. Esto permitiría que el nombre y el eslogan se adapten al tamaño de pantalla sin utilizar una imagen de fondo rectangular.

No distorsiones el grano ni estires el logotipo para encajarlo en un espacio.

# 4. CORREGIR LA PANTALLA DE INICIO DE SESIÓN

## Problema observado

En la captura, la composición aparece demasiado arriba: el logo, el texto descriptivo, los campos y los botones ocupan la zona superior y dejan demasiado espacio vacío debajo.

Quiero un diseño más equilibrado verticalmente.

### Cambios solicitados

- Centrar horizontalmente el bloque del logotipo.
- Mejorar la separación entre marca, descripción, campos y acciones.
- Distribuir el contenido de manera más equilibrada según la altura disponible.
- Mantener los campos de correo y contraseña.
- Mantener el botón de inicio de sesión.
- Mantener el botón de crear cuenta.
- Mantener la recuperación de contraseña.
- Conservar los colores de Lotea Café.
- Evitar que el diseño se sienta excesivamente pegado a la parte superior.

No quiero centrar todo de forma rígida si eso provoca desbordamientos en teléfonos pequeños.

Utiliza una composición adaptable con `SafeArea`, restricciones de tamaño y desplazamiento cuando sea necesario.

Cuando el teclado esté abierto, debe poder accederse a los campos y botones sin que aparezcan errores de desbordamiento.

El objetivo es que el contenido se sienta equilibrado, no que quede forzado al centro de la pantalla en cualquier circunstancia.

# 5. CORREGIR LA PANTALLA DE REGISTRO

Este es otro cambio importante.

## Problema A: las tarjetas de rol tienen tamaños diferentes

Actualmente aparecen las tarjetas:

- Vender café.
- Comprar café.

En la captura una tarjeta parece más grande que la otra, lo que produce una composición irregular.

Quiero que ambas tengan exactamente la misma anchura y altura.

### Requisitos

- Igual altura.
- Igual anchura.
- Alineación superior e inferior.
- Espaciado idéntico.
- Márgenes y padding coherentes.
- Iconos con tamaños consistentes.
- Textos centrados de forma uniforme.
- Comportamiento adaptable a pantallas pequeñas.

La selección del rol puede cambiar:

- Color de fondo.
- Borde.
- Color del texto.
- Indicador de selección.

Pero NO debe modificar el tamaño de la tarjeta.

Utiliza una estructura estable basada en el espacio disponible, como `Expanded`, restricciones de tamaño o una solución equivalente.

No fijes dimensiones arbitrarias que provoquen desbordamiento en otros dispositivos.

### Apariencia deseada

[ VENDER CAFÉ ]     [ COMPRAR CAFÉ ]

Ambas tarjetas deben compartir el mismo sistema visual, independientemente de cuál esté seleccionada.

# 6. CAMBIAR EL CAMPO DE NOMBRE SEGÚN EL ROL

## Problema observado

Actualmente, tanto si se selecciona «Vender café» como «Comprar café», el campo muestra:

«Nombre o nombre de finca/marca».

Ese texto es apropiado para un vendedor, pero confunde al comprador.

Quiero que el texto cambie dinámicamente según el rol seleccionado.

### Si selecciona COMPRAR CAFÉ

Etiqueta:

**Nombre completo**

Campo de ejemplo:

`Ej. María Rodríguez`

### Si selecciona VENDER CAFÉ

Etiqueta:

**Nombre del productor o finca/marca**

Texto de ayuda opcional:

`Puedes usar tu nombre, el de tu finca o tu marca comercial.`

El campo debe conservar el mismo estilo visual en ambas variantes.

No quiero que cambies arbitrariamente la estructura de Firestore.

Adapta las etiquetas y textos de ayuda al modelo existente. Si ambos roles usan el campo `nombre`, conserva esa estructura para esta mejora; no crees campos nuevos si no son necesarios para solucionar el problema.

### Cambio de rol durante el registro

Si el usuario selecciona primero «Vender café» y después «Comprar café», la etiqueta del nombre debe actualizarse inmediatamente.

Si el usuario vuelve a cambiar de rol, debe actualizarse nuevamente.

No pierdas el resto de los campos que ya haya rellenado.

# 7. CORREGIR EL LOGOTIPO EN EL ONBOARDING

## Problema observado

En la pantalla que contiene el botón «Empezar a descubrir», el símbolo del grano aparece desplazado hacia la izquierda y dentro de una superficie color crema.

Quiero que el bloque de marca esté centrado horizontalmente y que la imagen tenga transparencia real.

### Cambios

- Centrar horizontalmente el bloque de marca.
- Eliminar el recuadro accidental detrás del símbolo.
- Reutilizar los recursos de marca comunes con la pantalla de inicio de sesión.
- Mantener el fondo oscuro de la pantalla si forma parte del tema actual.
- Conservar el texto introductorio.
- Conservar los elementos «Descubre cafés», «Conoce productores», «Explora su origen», «Conecta directamente» y «Solicita cotizaciones».
- Mantener el botón «Empezar a descubrir».

El bloque de marca debe integrarse visualmente con el resto del onboarding y no parecer una tarjeta independiente.

Puedes mantener el texto explicativo alineado a la izquierda si mejora la legibilidad. Lo prioritario es que el logo se vea correctamente centrado y sin un fondo accidental.

Adapta los espacios verticales para teléfonos altos y bajos, sin desbordamientos.

# 8. REUTILIZAR LOS COMPONENTES DE MARCA

Revisa si la aplicación tiene diferentes implementaciones del logo en cada pantalla.

Quiero evitar que la pantalla de inicio, registro y onboarding terminen utilizando imágenes diferentes o estilos inconsistentes.

Siempre que resulte práctico, crea un componente reutilizable, por ejemplo:

`LoteaBrandHeader`

o utiliza el componente de marca existente.

Este componente debe admitir, según las necesidades de cada pantalla:

- Mostrar o no el eslogan.
- Tamaño del símbolo.
- Tamaño del nombre.
- Alineación.
- Variante de fondo oscuro o claro.
- Espaciado adaptable.

No conviertas el componente en una abstracción innecesariamente compleja.

Su finalidad es mantener el logotipo consistente y evitar repetir código.

# 9. CONSERVAR EL FUNCIONAMIENTO ACTUAL

Las modificaciones deben ser visuales y de identidad.

No alteres:

- Firebase Authentication.
- La persistencia del perfil.
- Cloud Firestore.
- La edición de vendedores.
- La creación de lotes.
- Las solicitudes comerciales.
- El chat.
- Las cotizaciones.
- Las reglas de seguridad.
- La navegación de comprador y vendedor.

No elimines campos de formularios que ya sean funcionales.

No vuelvas a introducir un acceso demo ni datos de prueba.

# 10. PRUEBAS Y GENERACIÓN DEL ICONO

Al finalizar, revisa los archivos modificados y ejecuta las comprobaciones disponibles.

Comandos esperados:

`flutter pub get`

Si incorporaste el generador de iconos:

`dart run flutter_launcher_icons`

Después:

`flutter analyze`

`flutter test`

Si el entorno lo permite:

`flutter build apk --release`

Verifica especialmente:

1. Que el icono nativo ya no sea el de Flutter.
2. Que el nombre visible sea «Lotea Café».
3. Que el logotipo dentro de la app no tenga un rectángulo accidental.
4. Que el onboarding tenga el bloque de marca centrado.
5. Que las tarjetas de rol tengan las mismas dimensiones.
6. Que el campo de nombre cambie correctamente con el rol.
7. Que el teclado no provoque desbordamientos.
8. Que Firebase continúe inicializándose correctamente.
9. Que las pruebas existentes no se rompan.

No afirmes que se ha generado una APK nueva si no has podido ejecutar la compilación.

# 11. ENTREGA DEL PROYECTO COMPLETO

Al terminar, quiero recibir un ZIP actualizado con el proyecto completo.

Incluye:

- Código Dart actualizado.
- Recursos de marca.
- Configuración Android necesaria.
- `pubspec.yaml` actualizado.
- `lib/firebase_options.dart`.
- `firebase.json`.
- `.firebaserc`, si existe.
- `firestore.rules`.
- `firestore.indexes.json`.
- `storage.rules`.
- `FIREBASE_SETUP.md`.
- Documentación actualizada cuando corresponda.

No incluyas las carpetas generadas `build/`, `.dart_tool/` ni las cachés de Gradle, para mantener el ZIP pequeño.

No elimines la configuración local de Firebase ni cambies los identificadores que ya se han registrado.

Al final, resume:

- Archivos modificados.
- Recursos de marca creados o reemplazados.
- Cómo se configuró el icono nativo.
- Qué cambios se hicieron en cada pantalla.
- Comandos ejecutados.
- Pruebas realizadas y sus resultados.
- Pasos necesarios para generar la siguiente APK.

El objetivo es una mejora visual concreta, no una nueva ronda general de funciones.