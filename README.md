# Aplicación de Autenticación Flutter

Aplicación de autenticación con Clean Architecture y BLoC.

## Version de flutter y android studio donde se probo la app

- Flutter 3.29.0 Puedes descargalo de aqui https://docs.flutter.dev/install/archive
- Android Studio Meerkat | 2024.3.1 Patch 1 Puedes descargarlo de aqui https://developer.android.com/studio/archive

## Qué hace

Sistema de login/registro/logout con estructura apropiada en tres capas:
- Dominio - Lógica de negocio
- Infraestructura - API y almacenamiento
- Presentación - UI y BLoC

## Formas de probar el programa
- Usando el emulador
- Usando un dispositivo fisico

## Para hacer llamadas a json server con dispositivo real
- En la carpeta shared/constants/api_constants.dart el baseUrl debe retornar realDeviceUrl
- Luego realDeviceUrl debe apuntar a la IP de tu máquina local y quedaría así: http://192.168.18.31:3000
- Usa este comando en el terminal de Windows 'ipconfig' y deberías obtener IPv4 Address. . . . . . . . . . . : 192.168.0.105

## Iniciar la aplicación en el siguiente orden

```bash
# Dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar
flutter run
```

## Pruebas

```bash
flutter test --reporter expanded
```

## Credenciales de prueba

- Email: `john@example.com`
- Contraseña: `password123`

## Tecnologías

- BLoC - Manejo de estado
- GoRouter - Navegación
- Dio - Cliente HTTP
- get_it - Inyección de dependencias
- Secure Storage - Almacenamiento de tokens
- Docker - API simulada

## Flujo de la app

Splash → Login → Home → Logout

# Arquitectura

Arquitectura Clean.

1. Dominio primero - Reglas de negocio
2. Infraestructura - Acceso a datos
3. Presentación - UI y BLoC
4. Tests - Validar lógica

## Las Capas

### Dominio (`lib/domain/`)
Lógica de negocio pura. Sin Flutter, sin dependencias externas.

Contiene:
- Entidades - User, AuthToken
- Casos de Uso - Login, Register, Logout
- Interfaces de Repositorio - Contratos abstractos

### Infraestructura (`lib/infrastructure/`)
Acceso a datos y servicios externos.

Contiene:
- DataSource Remoto - Llamadas API
- DataSource Local - Almacenamiento seguro
- Implementación de Repositorio - Implementaciones concretas
- Modelos - Objetos serializables JSON

### Presentación (`lib/presentation/`)
UI y manejo de estado.

Contiene:
- BLoC - Eventos, Estados, Lógica de Negocio
- Páginas - Login, Register, Home, Splash
- Widgets - Componentes UI reutilizables

## Cómo Funciona

```
UI → Evento → BLoC → Caso de Uso → Repositorio → API
                
UI ← Estado ← BLoC ← Caso de Uso ← Repositorio ← API
```

## Patrón BLoC

Eventos (qué pasa):
- `AuthLoginRequested`
- `AuthRegisterRequested`
- `AuthLogoutRequested`

Estados (condición de la app):
- `AuthLoading`
- `AuthAuthenticated`
- `AuthError`
- `AuthUnauthenticated`

## Inyección de Dependencias

Usando get_it + injectable para:
- Responsabilidad única
- Pruebas fáciles
- Bajo acoplamiento

## Estrategia de Testing

- Dominio - Casos de uso con mocks
- BLoC - Transiciones Evento → Estado

## Decisiones

Clean Architecture para separación de preocupaciones.
BLoC fue elegido como patrón de gestión de estado por su enfoque basado en streams y separación clara entre eventos, lógica de negocio y estado.
GoRouter para navegación type-safe, evitando errores como rutas mal escritas.
Dio como cliente HTTP potente y flexible.
SecureStorage para almacenar tokens y otra información importante de forma segura.
Docker para simular la API real durante el desarrollo.

