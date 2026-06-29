import chromadb

# 1. Inicializar el motor vectorial (localmente en memoria)
cliente = chromadb.Client()

# 2. Crear una "Colección"
# Este es el equivalente a una tabla en SQL. 
# Por defecto, ChromaDB utilizará la métrica de Distancia Euclidiana (L2).
coleccion = cliente.create_collection(name="conceptos_demo")

# 3. Preparar los Datos No Estructurados
# Imagina que estos son fragmentos de texto de tus usuarios o documentos.
documentos_texto = [
    "El rey gobierna desde su castillo junto a la reina.",
    "Las manzanas y las peras son frutas muy saludables.",
    "Un monarca toma decisiones importantes para su reino.",
    "Python es un lenguaje de programación muy usado en Inteligencia Artificial."
]

# 4. Inserción y Generación de Embeddings
# Aquí ocurre la magia. No le pasamos vectores numéricos manualmente. 
# ChromaDB, por defecto, descarga un modelo ligero de Machine Learning ('all-MiniLM-L6-v2')
# y convierte estos textos en vectores de alta dimensionalidad antes de guardarlos.
coleccion.add(
    documents=documentos_texto,
    metadatas=[{"categoria": "realeza"}, {"categoria": "comida"}, {"categoria": "realeza"}, {"categoria": "tecnologia"}],
    ids=["doc_1", "doc_2", "doc_3", "doc_4"]
)

print("✅ Documentos vectorizados y guardados en el espacio latente.\n")

# 5. La Búsqueda Semántica (Similarity Search)
# Vamos a buscar algo usando palabras que NO están exactamente en los documentos.
consulta_usuario = "Cuéntame sobre soberanos y palacios"

# Ejecutamos un algoritmo K-Nearest Neighbors (KNN) aproximado
resultados = coleccion.query(
    query_texts=[consulta_usuario],
    n_results=2 # Queremos que nos devuelva los 2 vectores más "cercanos"
)

# 6. Procesar la Respuesta
print(f"🔍 Tu búsqueda: '{consulta_usuario}'\n")
print("🏆 Resultados más cercanos (Matemáticamente):")

# Iteramos sobre los resultados devueltos
for i in range(len(resultados['documents'][0])):
    texto_encontrado = resultados['documents'][0][i]
    distancia = resultados['distances'][0][i]
    metadata = resultados['metadatas'][0][i]
    
    print(f"[{i+1}] Documento: {texto_encontrado}")
    print(f"    Distancia (L2): {distancia:.4f} (Menor es más parecido)")
    print(f"    Metadata: {metadata}\n")