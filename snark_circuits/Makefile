build:
	circom por.circom -o circuit.json && \
		snarkjs setup

proof:
	node ../merkleproof/merkleproof.js && \
		snarkjs calculatewitness && \
		snarkjs proof

verify:
	snarkjs verify
