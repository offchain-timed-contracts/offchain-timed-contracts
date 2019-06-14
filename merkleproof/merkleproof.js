const {mimc7} = require('circomlib')
const snarkjs = require('snarkjs')
const {bigInt} = require('snarkjs')
var hash = mimc7.multiHash

function generateMerkleTree (values) {
  var depth = Math.log2(values.length)

  const layers = [...Array(depth)].reduce((acc, _, i) => {
    var nodes = []
    for (var j = 0; j < acc[i].length; j += 2) {
      var v = acc[i]
      nodes.push(hash([v[j], v[j + 1]]))
    }
    return acc.concat([nodes])
  }, [values])

  const root = layers[layers.length - 1][0]

  return [root, layers]
}

function debugMerkleTree (layers) {
  console.log('merkle tree layers:')
  layers.forEach((x, i) => {
    console.log(' - layer ' + i + ': ')
    x.forEach(v => console.log('\t' + v))
  })
}

function merkleProof (layers, index) {
  const depth = layers.length - 1
  const pos = []
  const vals = []
  for (let i = 0; i < depth; i++) {
    const tmp = Math.floor(index / Math.pow(2, i))
    pos.push(tmp % 2)
    vals.push(tmp % 2 == 0 ? layers[i][tmp + 1] : layers[i][tmp - 1])
  }
  const leaf = layers[0][index]
  return [pos, vals, leaf]
}

function debugProof (pos, vals, leaf) {
  console.log(' - position vector: ' + pos)
  console.log(' - value vector : ')
  vals.forEach(v => console.log('\t' + v))
  console.log(` - leaf is ${leaf}`)
}

function writeProof (root, pos, vals, leaf) {
  var toStr = snarkjs.stringifyBigInts
  // create JSON input structure
  var input = {
    leaf: toStr(leaf),
    root: toStr(root),
    paths2_root_pos: pos,
    paths2_root: toStr(vals)
  }
  var json = JSON.stringify(input)
  var fs = require('fs')
  fs.writeFile('input.json', json, 'utf8', (err) => { if (err != null) { console.log(err) } })
}

const values = [1, 2, 3, 4].map(x => bigInt(x))
console.log('values of the merkle tree: ' + values)

const [root, layers] = generateMerkleTree(values)
debugMerkleTree(layers)

const index = 2
const [pos, vals, leaf] = merkleProof(layers, index)

debugProof(pos, vals, leaf)
writeProof(root, pos, vals, leaf)
