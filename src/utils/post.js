const {bigInt} = require('snarkjs')
const snarkjs = require('snarkjs')
const fs = require('fs')
const {generateMerkleTree, merkleProof} = require('./merkleproof')
const {sloth_encode} = require('./vdf')

const SLOTH_ITER = 10

function post (data, t, k, seed) {
  const [root, layers] = generateMerkleTree(data)

  const proofs = []
  proofs.push(merkleProof(layers, seed))
  const vdfs = []
  for (let i = 1; i < t; i++) {
    const leaf = proofs[i - 1][2]
    const c = sloth_encode(leaf, k, SLOTH_ITER)
    // note + '' converts a bigInt into a JS number
    const challenge = c.mod(bigInt(data.length)) + ''
    proofs.push(merkleProof(layers, challenge))
    vdfs.push(c)
  }

  return {
    // public
    por_root: root,
    k: k,
    por_seed_pos: proofs[0][0],
    // Private
    por_leaves: proofs.map(d => d[2]),
    paths2por_root: proofs.map(d => d[1]),
    paths2por_root_pos: proofs.map(d => d[0]).slice(1),
    in: vdfs
  }
}

function writeProof (proofs) {
  var toStr = snarkjs.stringifyBigInts
  // create JSON input structure
  Object.keys(proofs).forEach(d => proofs[d] = toStr(proofs[d]))
  var json = JSON.stringify(proofs)
  fs.writeFile('input.json', json, 'utf8', (err) => { if (err != null) { console.log(err) } })
}

const data = [...Array(4)].map((_, i) => bigInt(i))
const proof = post(data, 2, bigInt(1), 0)
console.log(proof)
writeProof(proof)
