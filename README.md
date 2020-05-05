# Proyecto 2 bis: actividad alternativa para BLE

#### PROGRAMACIÓN OPTIMIZADA PARA DISPOSITIVOS MÓVILES

<br>

_Autores: **Julia García Martínez y Pablo López Iborra**_


---

<br>

### Descripción general del proyecto

Este proyecto implementa un mando en un dispositivo **iOS**  para poder manejar la mirilla de un juego tipo _shooter_ para **MacOS**. El tipo de control es mediante un _trackpad_, deslizando la mirilla por la pantalla del _iPhone_.

La aplicación se comunica mediante **BLE** haciendo uso de **Core Bluetooth**.

<br>

### Estructura del proyecto

Para este trabajo han sido necesarios dos proyectos:

- El que implementa la parte **MacOS**, al que hemos denominado _InvadersScreen_.
- El que implementa la parte **iOS**, al que hemos denominado _InvadersControlShooter_.

<br>

#### Invaders Screen

Se compone del _controller_ `ScreenViewController` donde se implementa la puesta en escena y la lógica del juego.

Por otro lado, hemos creado la clase _extension_ de `ScreenViewController` llamada `ExtensionsScreenViewController`. Aquí implementamos la parte **central** y **peripherical** de BLE. Además, también se monta el servicio _SHOOT_ con su correspondiente característica.

<br>

#### Invaders Control Shooter

Se compone del _controller_ `ControlViewController` donde se implementan los gestos correspondientes para el control de la mirilla.

Primero, tenemos el gesto `Pan Gesture Recognizer` para poder _deslizar_ la mirilla por la pantalla.

Segundo, contamos con el gesto `Tap Gesture Recognizer` para que al hacer _tap_ sobre la mirilla se realice el disparo.

Además, en el _controller_ realizamos la normalización de las posiciones para cada coordenada X e Y. De esta manera podemos desplazar la mirilla independientemente del tamaño de la pantalla.

Por otro lado, hemos creado la clase _extension_ de `ControlViewController` llamada `ExtensionsControlViewController`. Aquí implementamos la parte **central** y **peripherical** de BLE. Además, también se monta el servicio _XY_ con su correspondientes características para cada coordenada.

<br>

#### Struct BLE - Constantes

En ambos proyectos se ha incluído un _struct_ llamado **BLE** con el nombre de los servicios, características, propiedades y permisos, así como el nombre de cada _device_.

<br>

### Dificultades encontradas

En general, terminar de asentar los conocimientos teóricos y prácticos del funcionamiento de BLE ha sido una de las principales dificultades que hemos encontrado a la hora de realizar el trabajo. Además, también debíamos entender en su totalidad la forma en que gestiona **Core Bluetooth** los distintos elementos que participan en la comunicación.


Por otro lado, la conexión que había entre el macOS y la parte periférica de la parte iOS era una **suscripción**. Por tanto, debíamos asegurarnos de que cada vez que las coordenadas de la mirilla cambiaran al deslizarla por la pantalla del dispositivo iOS, se actualizara de forma inmediata en el Mac.

Aquí nos encontramos con el problema de actualizar dos características a la vez, puesto que hacíamos dos llamadas seguidas a la función **updateValue()** de _CBPeripheralManagerDelegate_. Esto provocaba que la segunda llamada nos devolviera _false_, ya que la cola de tareas del _PeripheralManager_ se saturaba.

Como solución, implementamos la función **peripheralManagerIsReady(toUpdateSubscribers)** que se ejecutaba cuando dicha cola quedaba libre, garantizando la correcta actualización de las características.