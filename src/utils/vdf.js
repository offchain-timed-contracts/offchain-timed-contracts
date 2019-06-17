const {bigInt, stringifyBigInts} = require('snarkjs')
const BN128 = require('snarkjs').bn128
const toStr = stringifyBigInts

// Assum x, k are BigInt
// const SLOTH_P = BN128.r
const SLOTH_P = bigInt('21888242871839275222246405745257275088548364400416034343698204186575808495617')
const SLOTH_V = bigInt('17510594297471420177797124596205820070838691520332827474958563349260646796493')
exports.sloth_encode = (x, k, iter) => {
  for (let i = 0; i < iter; i++) {
    x = x.add(k, SLOTH_P)
    x = x.modPow(SLOTH_V, SLOTH_P)
  }

  return x
}

function sloth_decode (c, k, iter) {
  for (let i = 0; i < iter; i++) {
    c = c.modPow(bigInt(5), SLOTH_P) // c^5
    c = c.sub(k, SLOTH_P)
  }

  return c
}

function witness (c, k, x) {
  // create JSON input structure
  var input = {
    in: toStr(c),
    k: toStr(k),
    x: toStr(x)
  }
  var json = JSON.stringify(input)
  var fs = require('fs')
  fs.writeFile('input.json', json, 'utf8', (err) => { if (err != null) { console.log(err) } })
}

function test () {
  const x = bigInt('12345')
  const k = bigInt('99999')
  const iter = 2

  const c = sloth_encode(x, k, iter)
  const d = sloth_decode(c, k, iter)
  console.log({x, c, k, d}, d.equals(x))
  witness(c, k, x)

  console.log(d, bigInt('7308675771207517694204901600409973816978832943338063742045305545613162457973').modPow(bigInt(5), SLOTH_P).sub(k, SLOTH_P))
}

// test()
