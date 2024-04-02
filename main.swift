import Foundation
import FoundationNetworking 

// Define the URL for the WeatherAPI endpoint
let apiKey = "7fff6efa57dd493ebb191917240204" // Replace with your WeatherAPI API key

print("Enter city: ")
guard let city = readLine() else {
    print("No input entered.")
    exit(1)
}

let apiUrlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city.replacingOccurrences(of: " ", with: "_"))"

// Create a URL object from the apiUrlString
guard let apiUrl = URL(string: apiUrlString) else {
    print("Invalid URL")
    exit(1)
}

// Create a URLSession object
let session = URLSession.shared

// Create a semaphore to wait for the task to complete
let semaphore = DispatchSemaphore(value: 0)

// Create a URLSessionDataTask object with the given URL
let task = session.dataTask(with: apiUrl) { data, response, error in
    defer {
        // Signal the semaphore to indicate that the task has completed
        semaphore.signal()
    }

    // Check for any errors
    if let error = error {
        print("Error: \(error)")
        return
    }
    
    // Check for a successful HTTP response
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        print("Error: Invalid HTTP response")
        return
    }
    
    // Check if data is available
    guard let data = data else {
        print("Error: No data received")
        return
    }
    
    // Parse the JSON data
    do {
        // Decode the JSON data into a Swift dictionary
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // Access the weather data from the dictionary
            if let current = json["current"] as? [String: Any],
               let tempC = current["temp_c"] as? Double,
               let condition = current["condition"] as? [String: Any],
               let text = condition["text"] as? String {
                print("Current temperature in \(city): \(tempC)°C")
                print("Condition: \(text)")
            } else {
                print("Error: Unable to parse weather data")
            }
        } else {
            print("Error: Unable to decode JSON data")
        }
    } catch {
        print("Error: \(error)")
    }
}

// Start the URLSessionDataTask
task.resume()

// Wait for the task to complete
semaphore.wait()
