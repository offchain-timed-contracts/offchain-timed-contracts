const {vdf} = require("./vdf.js")
const {MP} = require("./merkleproof.js")

const values = [1,2,3,4].map(x => bigInt(x))
const challenges = [0,3]

const [root,layers] = MP.generateMerkleTree(values);

challenges.reduce((acc,_,i) => {
    var v = values[i]  
},[])
