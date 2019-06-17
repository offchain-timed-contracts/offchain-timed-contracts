include "../node_modules/circomlib/circuits/eddsamimc.circom";
include "../node_modules/circomlib/circuits/mimc.circom";

// d = depth of tree
// t = number of times a prover needed to provide a PoR
template GetMerkleRoots(d, t){
    // k is depth of tree

    signal input leaf[t];
    signal input paths2_root[t][d];
    signal input paths2_root_pos[t][d];

    signal input root;

    // hash of first two entries in por Merkle proof
    component merkle_root[t][d];
    for (var i = 0; i < t; i++) {
	    merkle_root[i][0] = MultiMiMC7(2,91);
	    merkle_root[i][0].in[0] <== leaf[i] - paths2_root_pos[i][0]* (leaf[i] - paths2_root[i][0]);
	    merkle_root[i][0].in[1] <== paths2_root[i][0] - paths2_root_pos[i][0]* (paths2_root[i][0] - leaf[i]);
	    merkle_root[i][0].k <== 0;

	    // hash of all other entries in por Merkle proof
	    for (var v = 1; v < d; v++){
		merkle_root[i][v] = MultiMiMC7(2,91);
		merkle_root[i][v].in[0] <== merkle_root[i][v-1].out - paths2_root_pos[i][v]* (merkle_root[i][v-1].out - paths2_root[i][v]);
		merkle_root[i][v].in[1] <== paths2_root[i][v] - paths2_root_pos[i][v]* (paths2_root[i][v] - merkle_root[i][v-1].out);
		merkle_root[i][v].k <== 0;
	    }
           // equality constraint: input tx root === computed tx root
           root === merkle_root[i][d-1].out; 
    }
}

