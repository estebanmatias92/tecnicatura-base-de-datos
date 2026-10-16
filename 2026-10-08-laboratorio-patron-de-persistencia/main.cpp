#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <sstream>
#include <stdexcept>

// Dominio: solo datos y negocio, sin persistencia.
class Libro
{
    private:
        std::string titulo;
        std::string autor;

    public:
        Libro(const std::string& titulo, const std::string& autor)
            : titulo(titulo), autor(autor)
        {
        }

        const std::string& getTitulo() const { return titulo; }
        const std::string& getAutor() const { return autor; }

        void mostrar() const
        {
            std::cout << "Titulo: " << titulo
                    << " | Autor: " << autor << '\n';
        }
};

// Dominio: agregado por alcance, sin persistencia.
class Biblioteca
{
    private:
        std::string nombre;
        std::vector<std::shared_ptr<Libro>> libros;

    public:
        explicit Biblioteca(const std::string& nombre)
            : nombre(nombre)
        {
        }

        const std::string& getNombre() const { return nombre; }

        const std::vector<std::shared_ptr<Libro>>& getLibros() const
        {
            return libros;
        }

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

// Capa de persistencia: patron Repositorio.
// Serializa por alcance y solo muestra por pantalla en guardar.
class BibliotecaRepository
{
    public:
        std::vector<std::string> serializar(
            const Biblioteca& biblioteca) const
        {
            std::vector<std::string> lineas;

            lineas.push_back("BIBLIOTECA\t" + biblioteca.getNombre());

            for (const auto& libro : biblioteca.getLibros())
            {
                lineas.push_back("LIBRO\t" + libro->getTitulo()
                    + "\t" + libro->getAutor());
            }

            return lineas;
        }

        void guardar(const Biblioteca& biblioteca) const
        {
            for (const auto& linea : serializar(biblioteca))
            {
                std::cout << linea << '\n';
            }
        }

        std::unique_ptr<Biblioteca> cargar(
            const std::vector<std::string>& lineas) const
        {
            if (lineas.empty())
            {
                throw std::runtime_error("Archivo vacio");
            }

            std::istringstream primeraLinea(lineas[0]);
            std::string tipo;
            std::string nombre;

            std::getline(primeraLinea, tipo, '\t');
            std::getline(primeraLinea, nombre);

            if (tipo != "BIBLIOTECA" || nombre.empty())
            {
                throw std::runtime_error(
                    "Registro de biblioteca invalido");
            }

            auto biblioteca =
                std::make_unique<Biblioteca>(nombre);

            for (std::size_t i = 1; i < lineas.size(); ++i)
            {
                if (lineas[i].empty())
                    continue;

                biblioteca->agregarLibro(
                    deserializarLibro(lineas[i]));
            }

            return biblioteca;
        }

    private:
        static std::shared_ptr<Libro> deserializarLibro(
            const std::string& linea)
        {
            std::istringstream entrada(linea);

            std::string tipo;
            std::string titulo;
            std::string autor;

            std::getline(entrada, tipo, '\t');
            std::getline(entrada, titulo, '\t');
            std::getline(entrada, autor);

            if (tipo != "LIBRO" ||
                titulo.empty() || autor.empty())
            {
                throw std::runtime_error(
                    "Registro de libro invalido");
            }

            return std::make_shared<Libro>(titulo, autor);
        }
};

int main()
{
    try
    {
        Biblioteca biblioteca("Biblioteca Popular");

        biblioteca.agregarLibro(
            std::make_shared<Libro>("El Aleph", "Jorge Luis Borges"));

        biblioteca.agregarLibro(
            std::make_shared<Libro>("Rayuela", "Julio Cortazar"));

        BibliotecaRepository repositorio;

        std::cout << "ESTRUCTURA ORIGINAL\n";
        biblioteca.mostrar();

        std::cout << "\nSERIALIZACION (guardar)\n";
        repositorio.guardar(biblioteca);

        // Round-trip en memoria: sin archivos.
        auto recuperada =
            repositorio.cargar(repositorio.serializar(biblioteca));

        std::cout << "\nESTRUCTURA RECUPERADA\n";
        recuperada->mostrar();
    }
    catch (const std::exception& error)
    {
        std::cerr << "Error: " << error.what() << '\n';
        return 1;
    }

    return 0;
}
