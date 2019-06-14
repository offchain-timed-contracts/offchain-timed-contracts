template sloth (iter) {
  signal input in;
  signal input x;
  signal input k;

  signal c <-- in;

  for (var i = 0; i < iter; i++) {
    signal c2;
    signal c4;
    signal c5;

    c2 <== c * c;
    c4 <== c2 * c2;
    c5 <== c4 * c;

    c <-- c5 - k;
  }

  x === c;

}

component main = sloth(1)
