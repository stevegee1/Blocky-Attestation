package main

// Import the necessary libraries and run `go mod tidy` to generate `go.sum`
// and update our dependencies.
//
// - encoding/json: for JSON decoding
// - math/rand: used to generate pseudo-random numbers (note: Go's rand is not cryptographically secure)
// - github.com/blocky/basm-go-sdk/basm: Blocky's Attestation SDK for Go
import (
	"encoding/json"
	"fmt"
	"math/rand"

	"github.com/blocky/basm-go-sdk/basm"
)

// Args defines the structure of the input expected from the host.
// RandomSpace indicates the number of NFT variations the user can receive.
// If RandomSpace is 3, the range will be [0, 2].
type Args struct {
	RandomSpace int `json:"random_length"`
}

//export randomNFT
func randomNFT(inputPtr uint64, secretPtr uint64) uint64 {
	var input Args

	// Read the input JSON data from the host memory using the BASM SDK
	inputData := basm.ReadFromHost(inputPtr)

	// Decode the JSON input into the Args struct
	err := json.Unmarshal(inputData, &input)
	if err != nil {
		outErr := fmt.Errorf("could not unmarshal input args: %w", err)
		return WriteError(outErr)
	}

	// Ensure we have at least two NFT variations
	if input.RandomSpace <= 1 {
		outErr := fmt.Errorf("NFT must have more than one variation")
		return WriteError(outErr)
	}

	// Generate a random NFT rarity value in the range [0, RandomSpace - 1]
	//
	// Note: Although Go's math/rand is not cryptographically secure, in the
	// Blocky runtime, the underlying randomness is seeded using high-entropy
	// values from the AWS Nitro Enclave. This allows trusted and secure
	// random number generation.
	pick := rand.Intn(input.RandomSpace)

	// Return the result to the host
	return WriteOutput(pick)
}

func main() {}
