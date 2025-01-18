import SwiftUI

struct ContentView: View {
    @State private var quoteData: QuoteData?

    var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .trailing) {
                Spacer()

                // Muestra el nombre del campeón o cualquier otra propiedad
                Text(quoteData?.name ?? "Loading...")
                    .font(.title2)
                
                // Muestra el título del campeón
                Text("- \(quoteData?.title ?? "Unknown Title")")
                    .font(.title2)
                    .padding(.top)

                Spacer()

                // Botón para cargar nuevos datos
                Button(action: loadData) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .multilineTextAlignment(.trailing)
        .padding()
        .onAppear(perform: loadData)
    }

    private func loadData() {
        guard let url = URL(string: "https://ddragon.leagueoflegends.com/cdn/11.18.1/data/en_US/champion.json") else {
            return
        }

        // Realizamos la solicitud a la API
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Verificamos si ocurrió un error
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            // Verificamos si los datos fueron recibidos correctamente
            guard let data = data else {
                print("No data received")
                return
            }

            // Intentamos decodificar los datos
            if let decodedData = try? JSONDecoder().decode(ChampionData.self, from: data) {
                // Seleccionamos el primer campeón de los datos recibidos
                if let firstChampion = decodedData.data.values.first {
                    DispatchQueue.main.async {
                        self.quoteData = QuoteData(id: firstChampion.id, name: firstChampion.name, title: firstChampion.title, stats: "\(firstChampion.stats?.hp ?? 0)")
                    }
                }
            }
        }.resume() // Llamada correcta a .resume()
    }
}

// Estructura para representar los datos de los campeones
struct ChampionData: Decodable {
    var data: [String: Champion]
}

struct Champion: Decodable {
    var id: String
    var name: String
    var title: String
    var stats: ChampionStats?

    enum CodingKeys: String, CodingKey {
        case id, name, title, stats
    }
}

struct ChampionStats: Decodable {
    var hp: Double
}

// Modelo de datos para mostrar la información
struct QuoteData {
    var id: String
    var name: String
    var title: String
    var stats: String
}
