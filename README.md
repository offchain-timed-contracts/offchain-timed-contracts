# Off-chain timed contracts
This is for the 2019 IC3-Ethereum Bootcamp at Cornell University. We built a simple prototype for a storage provider on top of Ethereum. It makes use of zk-SNARKs and verifiable delay functions (VDF) to prove that at certain times a storage provider contains a file segment.

## How to run
```
git clone git@github.com:offchain-timed-contracts/offchain-timed-contracts.git
npm install

// Compile the main circuit
// Note that you can make changes to the circuit depending on how many file segments and number of times a prover needs to prove something. Don't forget to recompile the circuit!
cd snark_circuits
circom main_circuit.circom -o circuit.json

// Compute trusted setup
cd ../src
cd snarkjs setup -c ../snark_circuits/circuit.json

// Compute inputs and calculate witnesses
node utils/post.js
snarkjs calculatewitness -c ../snark_circuits/circuit.json -i input.json

// Calculate proof
snarkjs proof

// Verify proof
// If done correctly, should output OK
snarkjs verify

// To generate a solidity contract
snarkjs generateverifier

// To generate parameters for the contract
snarkjs generatecall
```
