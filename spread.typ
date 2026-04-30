$ sum_i (X_i - s / n)^2 $

$ sum_i X_i = s $

$
"Var"[X] &= EE[X^2] - EE[X]^2 \ 

sum_i (X_i - s / n)^2 &= sum_i (X_i^2 - 2 X_i s/n + (s / n)^2) \

&= sum_i X_i^2 - 2 s/n sum_i X_i + n (s / n)^2 \

&= sum_i X_i^2 - 2 s^2/n + n (s / n)^2 \

&= sum_i X_i^2 - s^2/n
$


$ sum_i X_i^2 <= Delta $

$ "Spread"(bold(X), s, Delta) $

$ Delta_"min" $

$ X_i $

$ v-QQ "centered assignment" $


$
bold(x^*) in "argmin"_bold(x)[sum_i bold(x)[i]^2 "s.t." sum_i bold(x)[i] = s "and" forall i: bold(x)[i] in I(X_i)]

<==>

exists.not i != j: bold(x)[i] < X_i^"max", bold(x)[j] > X_j^"min", "and" bold(x)[i] < bold(x)[j]
$

$
bold(x)[i] = cases(
  X_i^max "if" v > X_i^max,
  X_i^min "if" v < X_i^min,
  v "otherwise"
)
$

$ bold(x)[i] = "clamp"(v, X_i^min, X_i^max) $

$ "Filtering" Delta_"min" $

$ "Computing" v $

$ sum_(i in L(v)) X_i^"max" + sum_(i in R(v)) X_i^"min" + m(v) dot v = s $

$ L(v) = {i: X_i^"max" < v}, R(v) = {i: X_i^"min" > v},  m(v) = |{i: v in I(X_i)}| $

$ "es"(v) = sum_(i in L(v)) X_i^"max" + sum_(i in R(v)) X_i^"min" $

$ "es" + m v = s $

$ "This holds for intervals where" X_i^"min" "and" X_i^"max" "are at the boundaries too!" $

$ forall v in I: "es and" m "are the same." $


$ "Computing" Delta_"min" $

$ "si"(I) = ["es"(I) + m(I) dot min(I), med "es"(I) + m(I) dot max(I)] $
