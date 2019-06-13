include "../node_modules/circomlib/circuits/eddsamimc.circom";
include "../node_modules/circomlib/circuits/mimc.circom";

template GetMerkleRoot(k){
    // k is depth of tree

    signal input leaf;
    signal input paths2_root[k];
    signal input paths2_root_pos[k];

    signal output out;

    // hash of first two entries in tx Merkle proof
    component merkle_root[k];
    merkle_root[0] = MultiMiMC7(2,91);
    merkle_root[0].in[0] <== leaf - paths2_root_pos[0]* (leaf - paths2_root[0]);
    merkle_root[0].in[1] <== paths2_root[0] - paths2_root_pos[0]* (paths2_root[0] - leaf);
    merkle_root[0].k <== 0;

    // hash of all other entries in tx Merkle proof
    for (var v = 1; v < k; v++){
        merkle_root[v] = MultiMiMC7(2,91);
        merkle_root[v].in[0] <== merkle_root[v-1].out - paths2_root_pos[v]* (merkle_root[v-1].out - paths2_root[v]);
        merkle_root[v].in[1] <== paths2_root[v] - paths2_root_pos[v]* (paths2_root[v] - merkle_root[v-1].out);
        merkle_root[v].k <== 0;
    }

    // equality constraint: input tx root === computed tx root 
    out <== merkle_root[k-1].out;

}

// checks for existence of leaf in tree of depth k
template LeafExistence(k){
    // k is depth of tree

    signal input leaf; 
    signal input root;
    signal input paths2_root_pos[k];
    signal input paths2_root[k];

    component computed_root = GetMerkleRoot(k);
    computed_root.leaf <== leaf;

    for (var w = 0; w < k; w++){
        computed_root.paths2_root[w] <== paths2_root[w];
        computed_root.paths2_root_pos[w] <== paths2_root_pos[w];
    }

    // equality constraint: input tx root === computed tx root 
    root === computed_root.out;

}

// k is the depth of tree
// t is the number of times to check
template Main(k, t) {
   // Merkle root of por tree
   signal input por_root;

   // PoRs to check
   signal input por_leaves[t];

   // Merkle proof for por in por tree
   signal private input paths2por_root[2**k,k];

   // binary vector to indicate whether node is left or right
   signal private input paths2por_root_pos[2**k,k];
   
   // Use this to make sure that inputted merkle root is correct
   component porExistence[t];

   for (var i = 0; i < t; i++) {
      porExistence[i] = LeafExistence(k);
      porExistence[i].leaf <== por_leaves[i];
      porExistence[i].root <== por_root;
      
      for (var j = 0; j < k; j++) {
         porExistence[i].paths2_root_pos[j] <== paths2por_root_pos[i, j];
         porExistence[i].paths2_root[j] <== paths2por_root[i, j];
      }
   }
}

component main = Main(2,2);
