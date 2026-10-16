#include <iostream>
#include <fstream>
#include <memory>
#include <string>
#include <vector>
#include <sstream>
#include <stdexcept>

// ==========================================
// MODELO DE DOMINIO (Solo datos y negocio)
// ==========================================

class Libro
{
    private:
        std::string titulo;
        std::string autor;

    public:
        Libro(std::string titulo, std::string autor)
            : titulo(std::move(titulo)), autor(std::move(autor))
        {
        }

        const std::string& getTitulo() const { return titulo; }
        const std::string& getAutor() const { return autor; }

        void mostrar() const
        {
            std::cout << "Titulo: " << titulo << " | Autor: " << autor << '\n';
        }
};

class Biblioteca
{
    private:
        std::string nombre;
        std::vector<std::shared_ptr<Libro>> libros;

    public:
        explicit Biblioteca(std::string nombre)
            : nombre(std::move(nombre))
        {
        }

        const std::string& getNombre() const { return nombre; }
        const std::vector<std::shared_ptr<Libro>>& getLibros() const { return libros; }

        void agregarLibro(const std::shared_ptr<Libro>& libro)
        {
            libros.push_back(libro);
        }

        void mostrar() const
        {
            std::cout << "\nBiblioteca: " << nombre << '\n';
            for (const auto& libro : libros)
            {
                libro->mostrar();
            }
        }
};

// ==========================================
// CAPA DE PERSISTENCIA (Maneja archivos y alcance)
// ==========================================

class GestorPersistencia
{
    public:
        // Guarda la Biblioteca y recorre por ALCANCE su vector de libros
        static void guardar(const Biblioteca& biblioteca, const std::string& archivo)
        {
            std::ofstream salida(archivo);
            if (!salida)
            {
                throw std::runtime_error("No se pudo abrir el archivo para escribir");
            }

            salida << "BIBLIOTECA\t" << biblioteca.getNombre() << '\n';

            // Persistencia por alcance: recorre los libros contenidos en la biblioteca
            for (const auto& libro : biblioteca.getLibros())
            {
                salida << "LIBRO\t" << libro->getTitulo() << "\t" << libro->getAutor() << '\n';
            }
        }

        // Recupera la Biblioteca y reconstruye todos sus libros
        static std::unique_ptr<Biblioteca> cargar(const std::string& archivo)
        {
            std::ifstream entrada(archivo);
            if (!entrada)
            {
                throw std::runtime_error("No se pudo abrir el archivo para leer");
            }

            std::string linea;
            if (!std::getline(entrada, linea))
            {
                throw std::runtime_error("Archivo vacio");
            }

            // Lectura de la cabecera (Biblioteca)
            std::istringstream primeraLinea(linea);
            std::string tipo, nombre;
            std::getline(primeraLinea, tipo, '\t');
            std::getline(primeraLinea, nombre);

            if (tipo != "BIBLIOTECA" || nombre.empty())
            {
                throw std::runtime_error("Registro de biblioteca invalido");
            }

            auto biblioteca = std::make_unique<Biblioteca>(nombre);

            // Lectura por alcance de cada libro
            while (std::getline(entrada, linea))
            {
                if (linea.empty()) continue;

                std::istringstream streamLinea(linea);
                std::string tipoElem, titulo, autor;

                std::getline(streamLinea, tipoElem, '\t');
                std::getline(streamLinea, titulo, '\t');
                std::getline(streamLinea, autor);

                if (tipoElem == "LIBRO" && !titulo.empty() && !autor.empty())
                {
                    biblioteca->agregarLibro(std::make_shared<Libro>(titulo, autor));
                }