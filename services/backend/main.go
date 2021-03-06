package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	//	"time"
)

var count = 1

func index(w http.ResponseWriter, r *http.Request) {

	//	duration := time.Duration(500)*time.Millisecond
	//	time.Sleep(duration)

	fmt.Printf("Handling %+v\n", r)

	host, err := os.Hostname()

	if err != nil {
		http.Error(w, fmt.Sprintf("Error retrieving hostname: %v", err), 500)
		return
	}

	msg := fmt.Sprintf("Host: %s\nSuccessful requests: %d", host, count)
	if !strings.Contains(r.URL.Path, "favicon.ico") {
		count++
	}

	io.WriteString(w, msg)
}

func main() {
	http.HandleFunc("/", index)
	port := ":8000"
	fmt.Printf("Starting to service on port %s\n", port)
	http.ListenAndServe(port, nil)
}
