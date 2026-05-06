#import "@preview/touying:0.7.3": *
#import themes.simple: *

#import "@preview/presentate:0.2.5"

#show: simple-theme.with(aspect-ratio: "16-9", header: [])
#show link: it => underline(text(fill: blue, it))
#show strong: it => text(fill: black, weight: "bold")[#it]
// changing the text size
#set text(size: 20pt)
#set par(leading: 0.6em)

#let todo(body) = box(
  fill: rgb("#ff6666"),
  stroke: rgb("#cc4444"),
  inset: (x: 6pt, y: 4pt),
  [*TODO:* #body],
)

// left aligned display block
#let d(padding: false, body) = block(
  width: 100%,
  spacing: 1em,
  {
    let pad-amount = if padding == false { 
      0pt 
    } else if padding == true { 
      2em 
    } else { 
      padding 
    }

    show math.equation.where(block: true): it => align(left, pad(left: pad-amount, it))
    align(left, body)
  }
)



#title-slide[
  #v(-2em)
  #image("pb_spread.jpg", width: 30%)
  #v(-1em)
  #heading(level: 1, outlined: false)[Spread Constraint]
  Gordon Chen, Juan Diego Wu Lin, Kevin Chen
]



== Outline
#outline()



== Paper
- Bound-consistent spread constraint

- Authors: Pierre Schaus and Jean-Charles Regin

- #link("https://link.springer.com/article/10.1007/s13675-013-0018-8") \ \

Cites #box(baseline: 25%)[#image("darthvaderldm.png", height:3em)]
#image("citingldm.png")



== Notation 
- $bold(X) = (X_1, X_2, ..., X_n)$ 
  - example: $bold(X) = ([1..2], [2..3], ..., [n..n+1])$
  
- $bold(x)$ is a tuple assignment of values assigned to each domain
  - example: $bold(x) = (1, 2, ..., n)$
  
- $bold(x)[i]$ is the value assigned to $X_i$ in $bold(x)$

- $X_i^("min")$ is the minimum of $X_i$, likewise $X_i^("max")$ is the maximum of $X_i$

- $I_D^QQ (X_i) = [X_i^"min", X_i^"max"] subset.eq QQ$ is the rational interval domain of $X_i$

- $I_D^ZZ (X_i) = [X_i^"min", X_i^"max"] subset.eq ZZ$ is the integer interval domain of $X_i$



#pagebreak()
- $underline(X_i)^QQ$ is the tightest consistent lower bound for $X_i$ over $QQ$, likewise, $overline(X_i)^QQ$ is the tightest consistent upper bound for $X_i$ over $QQ$ 

- $underline(X_i)^ZZ$ is the tightest consistent lower bound for $X_i$ over $ZZ$, likewise, $overline(X_i)^ZZ$ is the tightest consistent upper bound for $X_i$ over $ZZ$ 

- $underline(Delta)^QQ$ is the minimum achievable $sum_i bold(x)[i]^2$ over rational domains

- $underline(Delta)^ZZ$ is the minimum achievable $sum_i bold(x)[i]^2$ over integer domains $(>= underline(Delta)^QQ)$



== Motivation
- Nurses have to take care of infants

- Total work must be done: sum constraint

- Total work for infants must be split *fairly* among nurses: minimize variance \ \

- Schaus et al. (2006) gave an efficient $QQ$-bound algorithm for spread

- But our variables $in ZZ$, an optimal assignment $in QQ$, may assign variables to non-integers which aren't achievable. 

- A $ZZ$-bound consistent algorithm culls more of the search space
  - e.g. 10 variables in $[1..2]$ with $s=15$. $QQ$ optimum assigns all to $1.5$, resulting in $underline(Delta)^QQ$ = 22.5, but the best assignment $in ZZ$ results in $underline(Delta)^ZZ$ = 25, killing more of the search space.


  
== Setting up Spread
- Sum constraint: $sum_i X_i = s$

- Minimize variance: $sum_i (X_i - s / n)^2$

- $"Var"[X] &= EE[X^2] - EE[X]^2$

  #rect(stroke:red, inset:0.67em)[$sum_i (X_i - s / n)^2 = sum_i X_i^2 - s^2/n$]

- For fixed $s$: minimizing variance = minimizing sum of squares $sum_i X_i^2$



#pagebreak()
- Sum constraint: $sum_i X_i = s$

- Minimize variance: $sum_i (X_i - s / n)^2$

- $"Var"[X] &= EE[X^2] - EE[X]^2$

  #rect(stroke:red, inset:0.67em)[$sum_i (X_i - s / n)^2 = sum_i X_i^2 - s^2/n$]

- For fixed $s$: minimizing variance = minimizing sum of squares $sum_i X_i^2$

#d(padding:true)[
  #text(fill:red)[
    $
      sum_i (X_i - s/n)^2 &= sum_i (X_i^2 - 2 X_i dot s/n + (s/n)^2) = sum_i X_i^2 - 2 s/n sum_i X_i + n(s / n)^2 \
      &= sum_i X_i^2 - 2 s^2/n + n (s/n)^2 = sum_i X_i^2 - s^2/n
    $
  ]
]



== Spread$(bold(X), s, Delta)$
- Sum constraint: $sum_i X_i = s$

- Sum of squares constraint: $sum_i X_i^2 <= Delta$

- Filtering on $X_i$ and $Delta$ bounds \ \

- Search for solution with smallest sum of squares



== $v-QQ$ centered assignment
*Idea*: if two values can be moved closer to each other, the $L 2$ decreases
- take $x[i] < x[j]$ and move them closer by $x[j]-x[i] > delta>0$.

- the sum will be preserved since $x[i] + delta + x[j] - delta = x[i] + x[j]$
- but look at what happens to the $L 2$
- $L 2_"new" = (x[i]+delta)^2 + (x[j]-delta^2) wide L 2_"old" = x[i]^2 + x[j]^2$
- $Delta_"L2" = L 2_"new" - L 2_"old"$

  #image("newL2.png", width:85%)


  
#pagebreak()
  #d(padding: true)[
    $
    Delta_"L2" &= L 2_"new" - L 2_"old" \
    
    &= (x[i] + delta)^2 + (x[j] - delta)^2 - x[i]^2 - x[j]^2 \
    $
  ]

  

#pagebreak()
  #d(padding: true)[
    $
    Delta_"L2" &= L 2_"new" - L 2_"old" \
    
    &= (x[i] + delta)^2 + (x[j] - delta)^2 - x[i]^2 - x[j]^2 \

    & = (x[i]^2 + 2 delta x[i] + delta^2) + (x[j]^2 - 2 delta x[j] + delta^2) - x[i]^2 - x[j]^2 \

    &= cancel(x[i]^2 - x[i]^2) + cancel(x[j]^2 - x[j]^2) + 2 delta x[i] - 2 delta x[j] + delta^2 + delta^2 \

    &= 2delta^2 + 2 delta x[i] - 2 delta x[j] \

    &= underbrace(2 delta, >0)( underbrace(delta + x[i] - x[j], <0)) < 0 "(cost decreased)"
    $
  ]

#pagebreak()
We want to characterize what an optimal assignment in $QQ$ would like,

- $bold(x^*) in "argmin"_bold(x)[sum_i bold(x)[i]^2 "s.t." sum_i bold(x)[i] = s "and" forall i: bold(x)[i] in I(X_i)]\

  <==> \
  
  exists.not i != j: bold(x)[i] < X_i^max, bold(x)[j] > X_j^min, "and" bold(x)[i] < bold(x)[j]
  $

- Assignment optimality: cannot move 2 values closer to each other






== $v - QQ$ centered assignment visualization
#align(left)[
  #image("clamp1.png", height: 70%)
  $X_i in [10..50], X_j in [20..80], s = 90$
]



#pagebreak()
#align(left)[
  #image("clamp2.png", height: 70%)
  $X_i in [10..50], X_j in [20..80], s = 90$
]



#pagebreak()
#align(left)[
  #image("clamp3.png", height: 60%)
  $X_i in [10..40], X_j in [20..80], s = 90$
  
  What happens when we are limited by one of the bounds?
]



#pagebreak()
$bold(x)[i] = cases(
    X_i^max "if" v > X_i^max,
    X_i^min "if" v < X_i^min,
    v "otherwise"
  )
  = "clamp"(v, X_i^min, X_i^max)$ \ \

- At optimality, every variable should be at its boundary or at $nu$

- The rational lower bound $underline(Delta)^QQ$ is the minimum achievable $sum_i bold(x)[i]^2$ over rational domains




#pagebreak()
#align(left)[
  #image("clamp4.png", height: 60%)
  $x[i] = "clamp"(50, 10, 40) = 40$
  
  $x[j] = "clamp"(50, 20, 80) = 50$
]


  
== Computing $v$
- $sum_(i in L(v)) X_i^max + sum_(i in R(v)) X_i^min + m(v) dot v = s$ \ \

- $L(v) = {i: X_i^max < v}$

  $R(v) = {i: X_i^min > v}$

  $m(v) = |{i: v in I(X_i)}|$

- $"es"(v) = sum_(i in L(v)) X_i^max + sum_(i in R(v)) X_i^min$ 

- $"es"^((2))(v) = sum_(i in L(v)) (X_i^max)^2 + sum_(i in R(v)) (X_i^min)^2$

- $"es" + m v = s$



== Computing $v$ on Intervals
$"es"$ and $m$ only change at variable bounds. Between consecutive bounds they are *constant*.


So within each interval $I_k$, the sum is a simple linear function of $v$: 

$"es" + m v = s$

#d(padding: true)[
  $"es"(I_k) + m(I_k) dot v = s quad => quad "si"(I_k) = ["es" + m dot min(I_k), "es" + m dot max(I_k)]$
]

*Intuition for $"si"(I_k)$ (Sum Interval)* represents the minimum and maximum possible total sum we can achieve if $v$ is placed within this specific interval. If our target sum $s$ isn't in this range, $v$ cannot possibly live here!

*Algorithm* scan intervals until $s in "si"(I_k)$, then solve $v = (s - "es")/m$.





#pagebreak()
#d[
*Step 1 --- Constructing $cal(I)(X)$* \
+ First, take the minimum and maximum bounds for each $X_i in X$ (removing any duplicates), and then sort it in non-descending order,
  $
    quad B(X) = [1,2,3,6,9]
  $

+ We can construct $cal(I)(X)$ with the intervals formed by  pairing consecutive elements of $B(X)$,
  $
    quad cal(I)(X) 
    &= {I_1, I_2, I_3, I_4} \
    &= {[1,2], [2,3], [3,6], [6,9]}
  $
]



#pagebreak()
#d[
After we have $cal(I)(X)$, we can find $v$!

*Step 2 --- Finding $v$*
+ For each $I_k$, recall that $"es"(I_k) + m(I_k) dot v = s.$
+ We can construct the sum interval $"si"(I_k)$ as
  $
    quad "si"(I_k) = ["es"(I_k) + m(I_k) dot min(I_k), "es"(I_k) + m(I_k) dot max(I_k)]
  $
+ For each of these intervals, we want to find one where $s in "si"(I_k)$
]

#pagebreak()
#grid(
  columns: (45%, 50%),
  column-gutter: 1em,
  align: horizon,
  image("table1.png", width: 100%), 
  [
    *Step 1: Check $I_1$*
    #d[
      $I_1 = [1, 2]$ \
      $L(I_1) = emptyset, quad R(I_1) = {X_2, X_3}$ \
      $M(I_1) = {X_1} => m = 1$ \
      $"es"(I_1) = X_2^min + X_3^min = 5$ \
      $"si"(I_1) = [5 + 1(1), 5 + 1(2)] = [6, 7]$ \
    ]
    *Intuition:* If $v in I_1$, our total sum must fall between 6 and 7. \
    $s = 10 in.not [6, 7] quad =>$ *Continue*
  ]
)

#pagebreak()
#grid(
  columns: (45%, 50%),
  column-gutter: 1em,
  align: horizon,
  image("table2.png", width: 100%), 
  [
    *Step 2: Check $I_2$*
    #d[
      $I_2 = [2, 3]$ \
      $L(I_2) = emptyset, quad R(I_2) = {X_3}$ \
      $M(I_2) = {X_1, X_2} => m = 2$ \
      $"es"(I_2) = X_3^min = 3$ \
      $"si"(I_2) = [3 + 2(2), 3 + 2(3)] = [7, 9]$ \
    ]
    *Intuition:* If $v in I_2$, our total sum must fall between 7 and 9. \
    $s = 10 in.not [7, 9] quad =>$ *Continue*
  ]
)

#pagebreak()
#grid(
  columns: (45%, 50%),
  column-gutter: 1em,
  align: horizon,
  image("table3.png", width: 100%), 
  [
    *Step 3: Check $I_3$*
    #d[
      $I_3 = [3, 6]$ \
      $L(I_3) = {X_1}, quad R(I_3) = emptyset$ \
      $M(I_3) = {X_2, X_3} => m = 2$ \
      $"es"(I_3) = X_1^max = 3$ \
      $"si"(I_3) = [3 + 2(3), 3 + 2(6)] = [9, 15]$ \
    ]
    *Intuition:* If $v in I_3$, our total sum must fall between 9 and 15. \
    $s = 10 in [9, 15] quad =>$ *Stop!*

    #d(padding: true)[
      $v = (s - "es") / m = (10 - 3) / 2 = 3.5$
    ]
  ]
)






== Computing $underline(Delta)^QQ$
From the previous slide we have that $s in "si"(I_3)$, so $v=3.5$, \

With $v$, we can find $underline(Delta)^QQ$,
#d(padding:true)[
  $
    underline(Delta)^QQ 
    &= "es"^((2))(I_3) + m(I_3) dot v^2 \
    &= 9 + 2 dot 3.5^2 \
    &= 33.5
  $
We can then tighten the bound,
  $
    underline(Delta) <-- max{underline(Delta)^QQ, underline(Delta)}
  $
]



== $underline(Delta)^QQ$ runtime?
#pagebreak()
#text(fill:red)[$O(n^2)$] since we loop through $2n-1 --> O(n)$ possible intervals, and for each interval we compute es which takes linear time $--> O(n)$, totals out to $O(n^2)$.

Can we do better?
#pagebreak()

#text(fill:red)[$O(n^2)$] since we loop through $2n-1 --> O(n)$ possible intervals, and for each interval we compute es which takes linear time $--> O(n)$, totals out to $O(n^2)$.


*Lemma:* $"es"(I_(k+1)) = "es"(I_k) + (p_(k+1) - q_(k+1)) dot max(I_k)$ \
where $p_(k+1) = l(I_(k+1)) - l(I_k), quad q_(k+1) = r(I_k) - r(I_(k+1))$

- moving up to the next interval: gain $p_(k+1)$ lefts, lose $q_(k+1)$ rights

which makes the calculation of $"es"(I_k)$ constant
- What is the runtime now?

#pagebreak()

#text(fill:red)[$O(n^2)$] since we loop through $2n-1 --> O(n)$ possible intervals, and for each interval we compute es which takes linear time $--> O(n)$, totals out to $O(n^2)$.


*Lemma:* $"es"(I_(k+1)) = "es"(I_k) + (p_(k+1) - q_(k+1)) dot max(I_k)$ \
where $p_(k+1) = l(I_(k+1)) - l(I_k), quad q_(k+1) = r(I_k) - r(I_(k+1))$

- moving up to the next interval: gain $p_(k+1)$ lefts, lose $q_(k+1)$ rights

which makes the calculation of $"es"(I_k)$ constant

- We still have to sort the intervals for this.
#rect[#text(fill:blue)[$O(n log n)$]]



== Restricting Domains to $ZZ$
- The optimal value for $v = (s - "es")/m$ is fractional quite often. ($v = 3.5$ in the earlier example). 

- Variables must be $in ZZ$, so we cannot assign them to $v$. 

- So we can distribute the $m$ variables assigned to $v$ across the floor and ceil, $floor(v), ceil(v)$.

- We need to preserve the sum, so we calculate how many variables go to each bound, let
  - $v^+$ be the number of variables assigned to $ceil(v)$
  - $v^-$ be the number of variables assigned to $floor(v)$

$v^+$ and $v^-$ are quite easy to calculate! We can just use integer division,
- $v^+ = (s - "es"(I)) mod m(I)$
- $v^- = m(I) - v^+$

Giving us, 
#d(padding: true)[
  $
    underline(Delta)^ZZ = "es"^((2))(I) + v^+ dot ceil(v)^2 + v^- dot floor(v)^2
  $
]



#pagebreak()
Why is the optimal assignment $ceil(v)$ and $floor(v)$? 

*Theorem:* $bold(x) in "argmin"_bold(y) {sum_i y[i]^2 "s.t." sum_i y[i] = s "and" forall i : y[i] in I_(D)^(ZZ)(X_i)}$\
$<==>$
$sum_i x[i] = s "and" exists.not (i,j) "s.t." i != j, x[i] < X_i^("max"), x[j] > X_j^"max" "and" x[i] + 1 < x[j]$

*Proof:* uses the same idea as the rational case, but take $delta = 1$. 



// TODO: this needs to be motivated by saying that we are trying to start from delta q min
// and increase the value of x until it violates delta q max
== Quadratic Evolution of $underline(Delta)^QQ$ with $d$
- Assume that $X_i in R(I)$, so $x[i] = X^("min")_i$

- Let $d = x_i - x[i]$ be the distance from $x_i$ to its v-$QQ$ centered value

- if $d > s - min("si"(I))$: forces $v'$ outside of interval

*Lemma:* if $d <= s - min("si"(I))$ then,
#d(padding: true)[
$
  "es"'(I) = "es"(I) + d \
  "es"'^((2)) = "es"^((2))(I) + d^2 + 2d dot X_i^("min") \
  "then," v' = v - d/m \
  underline(Delta)^(QQ') = underline(Delta)^QQ + ( d^2 + 2 d dot X_i^("min") + d^2/m - 2 d dot v)
$ 
] 




#pagebreak()
- $underline(Delta)^QQ$ increases quadratically with $d$!

- We can find the largest $d$ such that $underline(Delta)^QQ' <= Delta^"max"$,
  #d(padding: true)[
    $
      underline(Delta)^QQ' = Delta^"max" \
      
      underline(Delta)^QQ + d^2 + 2 d dot X_i^("min") + d^2/m - 2 d dot v = Delta^"max" \

      // underbrace(d^2 + d^2/m, a d^2=(1 + 1/m) dot d^2) 
      // + underbrace(2d dot X_i^("min") - 2d dot v, 2b d=2(X^"min"_i - v) dot d)
      // + underbrace(underline(Delta)^QQ - Delta^"max", c < 0) = 0 \

      (1 + 1/m)d^2 + 2(X_i^("min") - v) d + (underline(Delta)^QQ - Delta^"max") = 0
    $
  ]


  
#pagebreak()
Apply the quadratic formula to find $d^*$,
#d(padding: true)[
  $
    d^* 
    &= (-b + sqrt(b^2 - 4 a c)) / (2a) \
  $ 
  We get that $overline(X_i)^QQ = x[i] + d^*$ where,
  
  - $d^*$ is the maximum we can increase $X_i$ before $underline(Delta)^QQ'$ exceeds $Delta^"max"$

  - $overline(X_i)^QQ$ is the tightest upper bound (consistent) for $X_i$
]



== Computing $overline(X_i)^QQ$ example
#d[
  $
    X_1, X_2 in [1..5], quad X_3 in [7..9], quad s=13, quad overline(Delta) = 80
  $
]

*Step 1 --- initial $v$ assignment*
#d[
  From the previous algorithm, we know how to find $v$. 

  $
    e s(I) = underline(X_3) = 7, quad m(v) = |{X_1, X_2}| = 2\
    v = (13- 7) /2 = 3
  $

  so our initial assignment of $bold(x) = (x[1],x[2],x[3]) =(3,3,7)$

  $
    underline(Delta)^QQ = 7^2 + 2 dot 9 = 49
  $

  We want to push $X_3$ as high as possible $(X_3 + d)$ before $underline(Delta)^QQ' > overline(Delta) =80$
]



#pagebreak()
*Step 2 --- Increase $X_3$ by $d$, and track how $underline(Delta)^QQ$ changes*

Each time we increase $X_3$ by $d$, the medium variables $X_1,X_2$ must come down to keep the $sum = 13 = s$. So we assign a new value to $v$, $v'= 3 - d/2$

#table(
  columns: (auto, auto, auto, auto),
  align: center,
  inset: 9pt,
  table.header[$d$][$bold(x)$][$v'$][$underline(Delta)^(QQ')$],
  [0], [(3, 3, 7)], [3], [#text(fill:green)[67]],
  [1], [(2.5, 2.5, 8)], [2.5], [#text(fill:green)[76.5]],
  [2], [(2, 2, 9)], [2], [#text(fill:red)[89] > $overline(Delta)$],
)

So the answer is somewhere between $d = 1$ and $d = 2$. We can solve for it exactly using the formula from the previous slide.



#pagebreak()
*Step 3 --- solve for $d^*$*
#d[  
+ Set $underline(Delta)^QQ' = overline(Delta)$
  #d(padding:true)[
    $
      67 + 3/2 d^2 + 8d = 80 \
      3d^2 + 16d - 26 = 0
    $
  ]

+ Apply the quadratic formula, $a = 3/2, quad b = X_3 -v=4, quad c = 67-80=-13$
  #d(padding:true)[
    $
      d^* = (-b + sqrt(a^2-a c)) / a = (-4 + sqrt(16 + 39/2))/(3/2) approx 1.3
    $
  ]

  So we can update $overline(X_3)^QQ = 7 + 1.3 = 8.3$\
  $X_3 = [7 med .. med 9] --> X_3 = [7 med .. med 8.3] !$
]



== Filtering $X_i^max$: Outline
- Find $X_i^max$ while not violating spread constraint

- Input: $I$ s.t. $s in "si"(I)$, $X_i in bold(X)$
- Output: $X_i^max$ \ \

Idea
- start from $v-QQ$ centered assignment $bold(x)[i]$

- increase $bold(x)[i]$ maximally without violating the sum of squares constraint

- round $bold(x)[i]$ down (for integrality)

- rounding may violate sum of square constraint, so backtrack

  

== Filtering $X_i^max$
- if $X_i in L(I)$: return $X_i^max$

  $X_i^max = bold(x)[i]$, so $X_i^max$ is consistent, cannot be lowered

- $x_"cur" = bold(x)[i]$

- $X_i in R(I) union M(I)$, to handle $X_i in M(I)$, split intervals

  $m', "es"', "es"'_2 = "getUpdatedValues"(x_"cur", I)$

- Compute updated $v$ center and sum of squares

  $v' = (s - "es"') \/ m'$

  $underline(Delta)^QQ = "es"'_2 + m' dot (v')^2$


  
#pagebreak()
- Compute the largest increase in $x_"cur"$ without violating spread (quadratic)

  $d^2 + 2 (x_"cur" - v')d + (underline(Delta)^QQ - Delta^max) = 0$

- if $d > s - min("si"(I))$: $d$ would push $v'$ outside of interval

  $x_"cur" <- x_"cur" + s - min("si"(I))$

  continue increasing sum in previous (lower) interval

- $d$ is the largest we can increase $x_"cur"$ by

  $x_"cur" <- x_"cur" + d$

- Now we need $x_"cur"$ to be integral



== Filtering $X_i^max$: Integrality
- $x_"cur"$ can be no higher, need integrality, $x_"cur" <- floor(x_"cur")$

- $underline(Delta)^ZZ >= underline(Delta)^QQ = Delta_max$

- compute $underline(Delta)^ZZ$

  $m', "es"', "es"_2 = "getUpdatedValues"(x_"cur", I)$

  $v = (s - "es"') \/ m'$

  $v^+ = (s - "es"') mod m' wide v^- = m' - v^+$

  $underline(Delta)^ZZ = "es"'_2 + v^+ dot ceil(v)^2 + v^- dot floor(v)^2$

#pagebreak()


#grid(
  columns: (1fr, 1fr),
  gutter: 1em,

  [
    - backtrack until $underline(Delta)^ZZ <= Delta_max$

    - while $underline(Delta)^ZZ > Delta_max$
      - $underline(Delta)^ZZ <- underline(Delta)^ZZ + 2(ceil(v) - x_"cur")$
      
      - $x_"cur" <- x_"cur" - 1$ \ \
    
    - max $m$ iterations: worst case all $floor(v) -> ceil(v)$
  ],
  [\ #image("backtrack.png", width: 80%)]
)



#pagebreak()
- $underline(Delta)^ZZ &= "es"'_2 + v^+ dot ceil(v)^2 + v^- dot floor(v)^2$

- $"es"'_2 = c + x_"cur"^2 wide -> wide  "es"'_2 = c + (x_"cur"-1)^2 = c + x_"cur"^2 - 2x_"cur" + 1 = "es"'_2 - 2x_"cur" + 1$

- Sum conservation: $x_"cur" <- x_"cur" - 1 wide -> wide v^+ <- v^+ + 1, v^- <- v^- - 1$ \ \

$
underline(Delta)^ZZ' &= "es"'_2 - 2x_"cur" + 1 + (v^+ + 1) dot ceil(v)^2 + (v^- - 1) dot floor(v)^2 \
  
&= "es"'_2 - 2x_"cur" + 1 + v^+ dot ceil(v)^2 + v^- dot floor(v)^2 + ceil(v)^2 - floor(v)^2 \

&= underline(Delta)^ZZ + 1 - 2x_"cur" + (ceil(v) + floor(v)) dot (ceil(v) - floor(v)) \

&= underline(Delta)^ZZ + 1 - 2x_"cur" + 1 dot (2 ceil(v) - 1) \
  
&= underline(Delta)^ZZ- 2x_"cur" + 2 ceil(v) \

&= underline(Delta)^ZZ + 2(ceil(v) - x_"cur")
$



== Filtering $X_i^max$: Summary
- Summary
  - start from $v-QQ$ centered assignment $bold(x)[i]$
  - increase $bold(x)[i]$ maximally without violating the sum of squares constraint
  - round $bold(x)[i]$ down (for integrality)
  - rounding may violate sum of square constraint, so backtrack
- Worst case time complexity: for every $X_i$, iterate through every $I$:  $O(n^2)$
  - Can be done in $O(n log n)$ binary searching intervals, but authors don't implement this

- Extend to filtering on $X_i^min$
  - Post separate Spread constraint on $sum_i -X_i = -s$
  - Filtering on $-X_i^max$ filters $X_i^min$

- Propagation: $X_i^min$ or $X_i^max$ changes: filter $Delta_min$ and all $bold(X)$, check $Delta_max$ violation



== Summary
Spread$(bold(X), s, Delta)$
- Sum constraint: $sum_i X_i = s$

- Sum of squares (Variance) constraint: $sum_i X_i^2 <= Delta$

- Filtering on $X_i$ and $Delta$ bounds



== Demo
#image("demo.png", height: 85%)


== Sources
- Spread constraint paper: #link("https://link.springer.com/article/10.1007/s13675-013-0018-8")

- OscaR implementation
  - Spread: #link("https://bitbucket.org/oscarlib/oscar/src/dev/oscar-cp/src/main/scala/oscar/cp/constraints/Spread.scala")
  - Nurses: #link("https://bitbucket.org/oscarlib/oscar/src/dev/oscar-cp-examples/src/main/scala/oscar/cp/examples/Nurses.scala")

  
= Thank You!
