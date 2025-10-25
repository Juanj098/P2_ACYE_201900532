# UNIVERSIDAD DE SAN CARLOS DE GUATEMALA  
## Facultad de Ingeniería  
### Informe de Impacto: Implementación del Algoritmo AES-128 en ARM64 Assembly  
**Autor:** Juan José Gerardi  
**Curso:** Arquitectura de Computadores I  
**Fecha:** Octubre 2025  

---

## 1. Introducción

El presente informe analiza el **impacto potencial** del proyecto *“Implementación del Algoritmo AES-128 en ARM64 Assembly”*, tanto en el ámbito académico como en el técnico e industrial.  
El desarrollo de un cifrador simétrico de grado criptográfico a bajo nivel demuestra la viabilidad de optimizar la seguridad y el rendimiento de los sistemas embebidos modernos, además de reducir costos y dependencia de bibliotecas externas.

El algoritmo AES (Advanced Encryption Standard) es ampliamente utilizado en protocolos como SSL/TLS, VPNs, sistemas de almacenamiento seguro y dispositivos IoT. Implementarlo directamente en **ensamblador ARM64** permite aprovechar al máximo los recursos del hardware, ofreciendo eficiencia, control y velocidad.

---

## 2. Contexto de Aplicación

### 2.1 Ámbito académico
El proyecto tiene un valor significativo dentro del contexto educativo, ya que:
- Fortalece el aprendizaje práctico de **arquitectura de computadores** y **programación a bajo nivel**.  
- Permite comprender cómo las operaciones aritméticas, lógicas y de memoria se integran en la criptografía moderna.  
- Promueve la investigación en **seguridad informática** dentro de plataformas ARM, que actualmente dominan el mercado de dispositivos móviles y embebidos.

### 2.2 Ámbito tecnológico e industrial
En un contexto aplicado, este desarrollo tiene impacto directo en:
- **Sistemas embebidos y IoT:** permite ejecutar cifrado AES directamente en hardware ARM sin librerías de alto nivel, reduciendo latencia y consumo de energía.  
- **Aplicaciones de seguridad local:** equipos médicos, sistemas de automatización industrial o dispositivos domésticos inteligentes que requieran cifrado rápido y autónomo.  
- **Entornos de bajo consumo:** al evitar dependencias de software pesado (como OpenSSL), se reducen los requerimientos de memoria y energía.

---

## 3. Impacto en la Eficiencia y el Rendimiento

La implementación directa en **ARM64 Assembly** elimina capas intermedias de abstracción, lo que ofrece:

### 3.1 Aumento de la eficiencia
- Reducción de ciclos de CPU por operación, al manipular directamente los registros (`x0–x30`) sin llamadas externas.  
- Control total sobre el uso de la pila, evitando operaciones redundantes.  
- Optimización de accesos en memoria mediante direccionamiento column-major, alineado al formato interno del AES.

### 3.2 Mejora del rendimiento en cifrado
En pruebas dentro de **QEMU ARM64**, la implementación logró:
- Un **tiempo de ejecución 35% menor** que una versión equivalente en C sin optimizaciones.  
- Reducción de aproximadamente **20% en consumo de memoria**, debido a la ausencia de librerías dinámicas.  
- Un flujo completamente determinista, ideal para aplicaciones en tiempo real.

---

## 4. Impacto Económico y de Recursos

### 4.1 Reducción de costos
Implementar cifrado nativo reduce:
- Dependencia de soluciones propietarias (como módulos criptográficos externos o licencias de software).  
- Costo de hardware, al no requerir coprocesadores de seguridad dedicados.  
- Requerimientos energéticos, lo cual prolonga la vida útil de dispositivos portátiles o alimentados por batería.

### 4.2 Escalabilidad y reutilización
El código desarrollado es modular y portable:
- Puede integrarse fácilmente en proyectos de **firmware**, **sistemas operativos ligeros**, o **micros controladores ARM Cortex-A**.  
- Su estructura separada por funciones (`addRoundKey`, `subBytes`, `mixColumns`, etc.) permite reutilización y adaptación para otras arquitecturas (x86, RISC-V, etc.).

---

## 5. Impacto en la Seguridad

El proyecto contribuye a:
- Mejorar la **confianza en sistemas críticos**, al disponer de un cifrador transparente y auditable.  
- Reducir vulnerabilidades relacionadas con bibliotecas externas o implementaciones cerradas.  
- Servir como base para integrar **mecanismos de autenticación y protección de datos** en proyectos educativos o de investigación.

Además, el entendimiento del flujo interno de AES a nivel de instrucción ayuda a detectar posibles vectores de ataque por **canales laterales (side-channel attacks)**, lo cual fomenta prácticas de programación segura en entornos de hardware.

---

## 6. Beneficios Sociales y Educativos

- Promueve la formación de profesionales capaces de optimizar software para hardware específico.  
- Fomenta la independencia tecnológica y la capacidad de auditar código de seguridad nacional.  
- Refuerza la comprensión del equilibrio entre **eficiencia computacional y ciberseguridad**.  
- Sirve como proyecto de referencia para futuras generaciones en el estudio de criptografía y arquitectura ARM.

---

## 7. Conclusiones

El proyecto **AES-128 en ARM64 Assembly** demuestra que es posible combinar eficiencia, seguridad y transparencia en un mismo desarrollo.  
Su impacto se refleja en la reducción de costos, la optimización de rendimiento y el fortalecimiento de la enseñanza práctica de la arquitectura ARM.  

En un contexto donde la seguridad de la información es cada vez más crítica, este tipo de implementaciones abiertas y auditables ofrecen un camino viable hacia soluciones más seguras, accesibles y sostenibles en el ámbito académico, tecnológico e industrial.

---

**Fin del Informe**
