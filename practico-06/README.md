# Búsqueda Semántica con ChromaDB

Demo de una base de datos vectorial utilizando **ChromaDB** para realizar búsquedas semánticas sobre texto no estructurado.

## Requisitos

- **Python ≥ 3.10**
- Opcional: [Nix](https://nixos.org/download.html) + [direnv](https://direnv.net/)

## Instalación y Ejecución

### Con Nix + direnv (recomendado)

```bash
# Permitir .envrc por única vez
direnv allow

# Ejecutar
python main.py
```

> El entorno se activa automáticamente al entrar al directorio.

### Sin Nix (pip)

```bash
# Crear y activar entorno virtual
python -m venv .venv
source .venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar
python main.py
```

## ¿Qué hace?

1. Inicializa ChromaDB en memoria.
2. Crea una colección (`conceptos_demo`) — el equivalente a una tabla en SQL.
3. Inserta 4 documentos de texto. ChromaDB los convierte automáticamente a vectores (embeddings) usando el modelo `all-MiniLM-L6-v2`.
4. Realiza una consulta semántica: busca documentos relacionados con *"soberanos y palacios"* aunque esas palabras exactas no aparezcan en los textos.
5. Devuelve los 2 documentos más cercanos usando distancia euclidiana (L2).

## Salida esperada

```
✅ Documentos vectorizados y guardados en el espacio latente.

🔍 Tu búsqueda: 'Cuéntame sobre soberanos y palacios'

🏆 Resultados más cercanos (Matemáticamente):
[1] Documento: El rey gobierna desde su castillo junto a la reina.
    Distancia (L2): 0.7448 (Menor es más parecido)
    Metadata: {'categoria': 'realeza'}

[2] Documento: Un monarca toma decisiones importantes para su reino.
    Distancia (L2): 0.8924 (Menor es más parecido)
    Metadata: {'categoria': 'realeza'}
```

> Las distancias pueden variar ligeramente según la versión de ChromaDB.

## Autor

**Carlos Matías Lapenta**  
Tecnicatura Superior en Sistemas — Base de Datos  
Práctico 06 — Bases de Datos Vectoriales
