import java.util.ArrayList;
import java.util.List;

// Dominio: solo datos y negocio, sin persistencia.
class Libro {
    private final String titulo;
    private final String autor;

    public Libro(String titulo, String autor) {
        this.titulo = titulo;
        this.autor = autor;
    }

    public String getTitulo() {
        return titulo;
    }

    public String getAutor() {
        return autor;
    }

    public void mostrar() {
        System.out.println(
            "Titulo: " + titulo + " | Autor: " + autor
        );
    }
}

// Dominio: agregado por alcance, sin persistencia.
class Biblioteca {
    private final String nombre;
    private final List<Libro> libros;

    public Biblioteca(String nombre) {
        this.nombre = nombre;
        this.libros = new ArrayList<>();
    }

    public String getNombre() {
        return nombre;
    }

    public List<Libro> getLibros() {
        return libros;
    }

    public void agregarLibro(Libro libro) {
        libros.add(libro);
    }

    public void mostrar() {
        System.out.println("\nBiblioteca: " + nombre);

        for (Libro libro : libros) {
            libro.mostrar();
        }
    }
}

// Capa de persistencia: patron Repositorio.
// Serializa por alcance y solo muestra por pantalla en guardar.
class BibliotecaRepository {

    public List<String> serializar(Biblioteca biblioteca) {
        List<String> lineas = new ArrayList<>();

        lineas.add("BIBLIOTECA\t" + biblioteca.getNombre());

        for (Libro libro : biblioteca.getLibros()) {
            lineas.add(
                "LIBRO\t" + libro.getTitulo() + "\t" + libro.getAutor()
            );
        }

        return lineas;
    }

    public void guardar(Biblioteca biblioteca) {
        for (String linea : serializar(biblioteca)) {
            System.out.println(linea);
        }
    }

    public Biblioteca cargar(List<String> lineas) {
        if (lineas.isEmpty()) {
            throw new IllegalArgumentException(
                "Archivo vacio"
            );
        }

        String[] cabecera = lineas.get(0).split("\t", -1);

        if (cabecera.length != 2 ||
            !cabecera[0].equals("BIBLIOTECA") ||
            cabecera[1].isEmpty()) {
            throw new IllegalArgumentException(
                "Registro de biblioteca invalido"
            );
        }

        Biblioteca biblioteca =
            new Biblioteca(cabecera[1]);

        for (int i = 1; i < lineas.size(); i++) {
            if (lineas.get(i).isEmpty()) {
                continue;
            }

            biblioteca.agregarLibro(deserializarLibro(lineas.get(i)));
        }

        return biblioteca;
    }

    private Libro deserializarLibro(String linea) {
        String[] campos = linea.split("\t", -1);

        if (campos.length != 3 ||
            !campos[0].equals("LIBRO") ||
            campos[1].isEmpty() ||
            campos[2].isEmpty()) {
            throw new IllegalArgumentException(
                "Registro de libro invalido"
            );
        }

        return new Libro(campos[1], campos[2]);
    }
}

class Main {
    public static void main(String[] args) {
        try {
            Biblioteca biblioteca =
                new Biblioteca("Biblioteca Popular");

            biblioteca.agregarLibro(new Libro(
                "El Aleph", "Jorge Luis Borges"
            ));

            biblioteca.agregarLibro(new Libro(
                "Rayuela", "Julio Cortazar"
            ));

            BibliotecaRepository repositorio =
                new BibliotecaRepository();

            System.out.println("ESTRUCTURA ORIGINAL");
            biblioteca.mostrar();

            System.out.println("\nSERIALIZACION (guardar)");
            repositorio.guardar(biblioteca);

            // Round-trip en memoria: sin archivos.
            Biblioteca recuperada = repositorio.cargar(
                repositorio.serializar(biblioteca)
            );

            System.out.println("\nESTRUCTURA RECUPERADA");
            recuperada.mostrar();

        } catch (IllegalArgumentException error) {
            System.err.println("Error: " + error.getMessage());
        }
    }
}
