include "../node_modules/circomlib/circuits/eddsamimc.circom";
include "../node_modules/circomlib/circuits/mimc.circom";
include "./sloth.circom";

template GetMerkleRoot (d, t) {
  // k is depth of tree

  signal input root;
  signal input leaf[t];
  signal input paths2_root[t][d];
  signal input paths2_root_pos[t][d];

  component merkle_root[t][d];
  for (var i = 0; i < t; i++) {
    merkle_root[i][0] = MultiMiMC7(2,91);
    merkle_root[i][0].in[0] <== leaf[i] - paths2_root_pos[i][0]* (leaf[i] - paths2_root[i][0]);
    merkle_root[i][0].in[1] <== paths2_root[i][0] - paths2_root_pos[i][0]* (paths2_root[i][0] - leaf[i]);
    merkle_root[i][0].k <== 0;

    for (var v = 1; v < d; v++){
      merkle_root[i][v] = MultiMiMC7(2,91);
      merkle_root[i][v].in[0] <== merkle_root[i][v-1].out - paths2_root_pos[i][v]* (merkle_root[i][v-1].out - paths2_root[i][v]);
      merkle_root[i][v].in[1] <== paths2_root[i][v] - paths2_root_pos[i][v]* (paths2_root[i][v] - merkle_root[i][v-1].out);
      merkle_root[i][v].k <== 0;
    }

    root === merkle_root[i][d-1].out;
  }
}

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
  component porMerkleRoot = GetMerkleRoot(d,t);
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
