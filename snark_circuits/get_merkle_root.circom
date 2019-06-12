include "../node_modules/circomlib/circuits/eddsamimc.circom";
include "../node_modules/circomlib/circuits/mimc.circom";

// k is the depth of the tree
template GetMerkleRoot(k) {
  signal input leaf;
  signal input paths_2_root[k];
  signal input paths_2_root_position[k];

  signal output isInTree;

  // hash of the first 2 entries in a PoR Merkle proof
  // Note: Can defined components on-the-fly like a variable
  component merkle_root[k];
  merkle_root[0] = MultiMiMC7(2, 91);
  merkle_root[0].in[0] <== leaf - paths_2_root_position[0] * (leaf - paths_2_root[0]);
  merkle_root[0].in[1] <== paths_2_root[0] - paths_2_root_position[0] * (paths_2_root[0] - leaf);

  // hash of all other entries in PoR merkle proof
  for (var v = 1; v < k; v++) {
    merkle_root[v] = MultiMiMC(2, 91);
    merkle_root[v].in[0] <== merkle_root[v-1].out - paths_2_root_position[v] * (merkle_root[v-1].out - paths_2_root[v]);
    merkle_root[v].in[1] <== paths_2_root[v] - paths_2_root_position[v] * (path_2_root[v] - merkle_root[v-1].out);
  }

  // equality contraint: inputed PoR root === computer PoR root
  isInTree  <== merkle_root[k-1].out;

}

template Main(k) {

  // Merkle root of PoR tree
  signal input por_root;

  // Merkle proof for file portion in PoR tree
  signal private input paths_2_por_root[2**k, k];

  // binary vector indicating whether node in por proof is left or right
  signal private input paths_2_por_root_position[2**k, k];

  signal private input file_portion[2**k]; // file portion that we want to make sure is in the tree

  signal output out;

  component merkle_root[2**k - 1];

  for (var i = 0; i < 2**k - 1; i++) {
      merkle_root[i] = GetMerkleRoot(k);
      merkle_root.leaf = 
  }

}

component main = Main(k);
