template sloth (iter) {
  signal input in;
  signal input x;
  signal input k;

  signal c[iter+1];
  c[0] <-- in;

  signal c2[iter];
  signal c4[iter];

  for (var i = 0; i < iter; i++) {
    c2[i] <== c[i] * c[i];
    c4[i] <==  c2[i] * c2[i];
    c[i+1] <==  c4[i] * c[i] - k ;
  }

  x === c[iter];
}
