package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		hostname := os.Getenv("HOSTNAME")
		apiKey := os.Getenv("API_KEY")

		// Mask the API key for security (show only first 4 and last 4 chars)
		maskedKey := "not set"
		if apiKey != "" {
			if len(apiKey) > 8 {
				maskedKey = apiKey[:4] + "..." + apiKey[len(apiKey)-4:]
			} else {
				maskedKey = "***"
			}
		}

		fmt.Fprintf(w, "Hello from GKE! (v3 - CI/CD Verified)\nHostname: %s\nAPI Key: %s\n", hostname, maskedKey)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
