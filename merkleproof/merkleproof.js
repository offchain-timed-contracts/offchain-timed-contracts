const {mimc7} = require('circomlib')
const snarkjs = require('snarkjs')
const {bigInt} = require('snarkjs')

const values = [1, 2, 3, 4].map(x => bigInt(x))
console.log('values of the merkle tree: ' + values)
const depth = 2
const hash = mimc7.multiHash
const layers = [values]


for (var i = 0; i < depth; i++) {
  var nodes = []
  for (var j = 0; j < layers[i].length; j += 2) {
    var v = layers[i]
    nodes.push(hash([v[j], v[j + 1]]))
  }
  layers.push(nodes)
}

console.log('merkle tree layers:')
layers.forEach((x, i) => {
  console.log(' - layer ' + i + ': ')
  x.forEach(v => console.log('\t' + v))
})

const index = 2

const pos = []
const vals = []
for (let i = 0; i < depth; i++) {
  const tmp = Math.floor(index / Math.pow(2, i))
  pos.push(tmp % 2)
  vals.push(tmp % 2 == 0 ? layers[i][tmp + 1] : layers[i][tmp - 1])
}

// add the root at the end of the proof -> no
var root = layers[layers.length - 1][0]

console.log(' - position vector: ' + pos)
console.log(' - value vector : ')
vals.forEach(v => console.log('\t' + v))

var toStr = snarkjs.stringifyBigInts
// create JSON input structure
var input = {
  leaf: toStr(values[index]),
  root: toStr(root),
  paths2_root_pos: pos,
  paths2_root: toStr(vals)
}
var json = JSON.stringify(input)
var fs = require('fs')
fs.writeFile('input.json', json, 'utf8', (err) => { if (err != null) { console.log(err) } })
