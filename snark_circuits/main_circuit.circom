include "./sloth.circom";
include "./get_merkle_roots.circom";

// d = depth of PoR merkle tree
// t = number of times prover needed to provide a PoR
template Main (d, t) {
  // Merkle root of por tree
  signal input por_root;

  // Key for Sloth VDF
  signal input k;

  // first challenge
  signal input por_seed_pos[d];

  // PoRs to check
  signal private input por_leaves[t];

  // Merkle proof for por in por tree
  signal private input paths2por_root[t][d];

  // binary vector to indicate whether node is left or right
  signal private input paths2por_root_pos[t-1][d];

  // Private inputs for Sloth VDF
  signal private input in[t-1];

  // Use this to make sure that inputted merkle root is correct
  component porMerkleRoot = GetMerkleRoots(d,t);
  porMerkleRoot.root <-- por_root;
  for (var i = 0; i < t; i++) {
    porMerkleRoot.leaf[i] <-- por_leaves[i];


    for (var j = 0; j < d; j++) {
      porMerkleRoot.paths2_root_pos[i][j] <-- i == 0 ? por_seed_pos[i] : paths2por_root_pos[i-1][j];
      porMerkleRoot.paths2_root[i][j] <-- paths2por_root[i][j];
    }
 }

  // Verify aggregated VDF
  component slothVerification[t-1];
  component bin[t-1];
  for (var i = 0; i < t-1; i++) {
    slothVerification[i] = sloth(10);
    slothVerification[i].in <-- in[i];
    slothVerification[i].x <-- porMerkleRoot.leaf[i] ;
    slothVerification[i].k <-- k;

    bin[i] = Num2Bits(255);
    bin[i].in <-- in[i];

    for (var j = 0; j < d; j++) {
      porMerkleRoot.paths2_root_pos[i+1][j] === bin[i].out[j];
    }
  }
}

component main = Main(2, 2);
