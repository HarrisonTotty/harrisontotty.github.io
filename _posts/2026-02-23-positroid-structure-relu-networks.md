---
layout: post
title: "Positroid Structure in ReLU Networks"
---
{% raw %}

A single-hidden-layer ReLU network with $$H$$ hidden units and $$d$$-dimensional input partitions $$\mathbb{R}^d$$ into activation regions via $$H$$ affine hyperplanes. These hyperplanes define an _affine matroid_ of rank $$d+1$$ on the ground set $$[H]$$, encoding the combinatorial structure of the decision boundary. I've been asking: when the weight matrix is constrained to be _totally positive_ (all minors nonnegative), is the resulting matroid always a _positroid_?

This question sits at the intersection of two literatures that, as far as I can tell, have not been connected before: the combinatorics of positroids and the totally nonnegative Grassmannian (Postnikov, Knutson-Lam-Speyer, Lam) on one side, and the geometry of neural network activation regions (Hanin-Rolnick, Balestriero-Baraniuk) on the other.

Totally positive (TP) matrices arise naturally in neural networks through kernel parameterizations like $$W_{ij} = \exp(a_i \cdot b_j)$$ or $$W_{ij} = 1/(a_i + b_j)$$, both of which produce TP matrices by classical results. Positroids — matroids realizable by points in the totally nonnegative Grassmannian — are characterized by elegant combinatorial structures: Grassmann necklaces, decorated permutations, and plabic graphs.

The question, then: does total positivity of the weights propagate through the affine hyperplane arrangement to constrain the activation matroid to be a positroid?

The answer turned out to be more interesting than a simple yes or no.

{% endraw %}
![TP-weight ReLU network on two-moons]({{site.url}}/images/positroid-fig1-hyperplanes.png)

_**Figure 1.** A TP-weight ReLU network trained on the two-moons dataset. The 8 lines are the hyperplanes $$\{x : w_i^T x + b_i = 0\}$$ from the first hidden layer. Together they define an affine matroid of rank 3 on the ground set $$[8]$$. In this case the matroid is uniform (all 56 triples are bases), so it is vacuously a positroid._
{% raw %}


# 800 Trials: The Conjecture

I trained single-hidden-layer ReLU networks with TP-constrained weights across a range of configurations: two-moons, concentric circles, spirals, XOR, and PCA-reduced digits datasets; exponential and Cauchy kernel parameterizations; hidden dimensions $$H \in \{4, 6, 8, 12, 16\}$$; input dimensions $$d \in \{2, 3, 5\}$$.

Over 800 trials, every affine matroid produced by a TP-weight network was a positroid. Zero counterexamples. The conjecture appeared robust.

There was a catch, though. Most trials produced _uniform_ matroids — matroids where every $$k$$-subset is a basis — which are vacuously positroids regardless of weight structure. Non-uniform positroids only appeared in one configuration: exponential kernel on two-moons with $$d=2$$. There, up to 50% of trials at $$H=16$$ produced non-trivial positroids with rich structure (hundreds of bases, consistent decorated permutation patterns).

The 1-parameter degeneracy of both kernel families (hyperplane normals confined to a curve in $$\mathbb{R}^d$$) and the low rank ($$d=2$$ gives rank-3 matroids) left the conjecture plausible but weakly tested. So rather than run more training experiments, I decided to attack the conjecture directly.


# 12,642 Counterexamples: The Conjecture is False

The mechanism for constructing counterexamples is simple. For a TP weight matrix $$W \in \mathbb{R}^{H \times d}$$, the affine matroid of $$[W \mid b]$$ has rank $$d+1$$. A $$(d+1)$$-tuple $$S$$ is a non-basis if and only if the dependency coefficients $$c_S$$ (from the left null space of $$W_S$$) satisfy $$c_S \cdot b_S = 0$$. This is _one linear equation_ on the bias entries indexed by $$S$$, leaving all other biases free.

TP structure constrains the weights but places no constraint on the biases. For $$d=2$$, the dependency coefficients of any triple $$(i,j,k)$$ from a TP matrix have sign pattern $$(+, -, +)$$. Choosing biases to make a _spread_ triple like $$\{0, 2, 4\}$$ a non-basis (elements non-contiguous in cyclic order) is always satisfiable, and the resulting matroid is not a positroid.

I ran 16,820 targeted trials across configurations with $$d=2$$ and $$H \in \{5, 6, 8\}$$, producing **12,642 counterexamples**. The construction works for every TP matrix tested. The smallest counterexample is $$d=2$$, $$H=5$$: _any_ TP matrix $$W \in \mathbb{R}^{5 \times 2}$$ with biases chosen to make $$\{0,2,4\}$$ a non-basis gives a non-positroid (9 out of 10 bases, fails the Grassmann necklace test).

The counterexamples cluster by construction strategy. _Crossing pairs_ (two interleaving non-bases) succeed at ~89%. _Single spread non-bases_ succeed at ~73%. But _contiguous_ non-bases — sets of the form $$\{j, j+1, \ldots, j+k-1\} \bmod n$$ — produce positroids in every case. Not a single contiguous non-basis pattern yielded a non-positroid matroid.


# The Dichotomy

The disproof revealed a clean split. Non-basis patterns fall into two classes: _cyclic intervals_ (contiguous arcs on $$[n]$$ arranged in a circle) and _non-intervals_ (spread or crossing patterns). The first class always gives positroids; the second class often does not.

Gradient descent on TP-weight networks, across all 800+ training trials, produces _only_ contiguous non-basis patterns. It never generates spread or crossing patterns. The original conjecture held for trained networks not because of any algebraic property of TP matrices, but because of the implicit bias of gradient-based optimization.

This shifts the conjecture from a static algebraic claim to a dynamical one. The revised conjecture: _for TP-weight networks trained by gradient descent on binary classification, the affine matroid of the learned hyperplane arrangement is always a positroid._ This is a statement about the interaction between TP structure and training dynamics, connecting positroid combinatorics to the implicit bias literature in deep learning theory.

{% endraw %}
![Non-basis patterns on the circle]({{site.url}}/images/positroid-fig2-intervals.png)

_**Figure 2.** The two types of non-basis on $$[6]$$. Left: $$\{2,3,4\}$$ is a cyclic interval — its elements form a contiguous arc on the circle. Removing it from the uniform matroid always gives a positroid. Right: $$\{0,2,4\}$$ is a non-interval — its elements are spread with gaps. Removing it can break the positroid property._

![Counterexample dichotomy]({{site.url}}/images/positroid-fig3-dichotomy.png)

_**Figure 3.** Results from 2,793 TP network trials, classified by non-basis structure. When all non-bases are cyclic intervals: 433 positroids, zero non-positroids — the zero is the theorem in action. When any non-basis is a non-interval: 58 positroids, 747 non-positroids._
{% raw %}

But the zero in the left column of Figure 3 demands explanation. Why should contiguous non-bases _always_ give positroids? Is this just a pattern, or is there a structural reason?


# The Contiguous-Implies-Positroid Theorem

It is a theorem.

**Theorem.** _Let $$M$$ be a matroid of rank $$k$$ on $$[n] = \{0, 1, \ldots, n-1\}$$. If every non-basis of $$M$$ is a cyclic interval — a set of the form $$\{j, j+1, \ldots, j+k-1\} \bmod n$$ — then $$M$$ is a positroid._

The proof uses the Grassmann necklace / Gale reconstruction characterization: a matroid is a positroid if and only if its basis set $$\mathcal{B}$$ equals the Gale reconstruction set $$\mathcal{R}$$ from its Grassmann necklace.

The standard direction $$\mathcal{B} \subseteq \mathcal{R}$$ follows from the matroid greedy algorithm. The key observation for $$\mathcal{R} \subseteq \mathcal{B}$$ is that a cyclic interval $$\{j, j+1, \ldots, j+k-1\}$$ is the _Gale-minimum_ $$k$$-subset in the cyclic order $$\leq_j$$ starting at $$j$$ — it consists of the first $$k$$ elements. If this interval is a non-basis, the Grassmann necklace entry $$I_j$$ (the lex-min basis in $$\leq_j$$) must be different from it, and since $$I_j$$ is a $$k$$-subset it Gale-dominates the interval. So the interval fails the Gale condition $$S \geq_j I_j$$ at position $$j$$ and is excluded from $$\mathcal{R}$$.

Since every non-basis is a cyclic interval, every non-basis is excluded from $$\mathcal{R}$$, giving $$\mathcal{R} \subseteq \mathcal{B}$$. Combined with $$\mathcal{B} \subseteq \mathcal{R}$$, we get $$\mathcal{B} = \mathcal{R}$$, so $$M$$ is a positroid. $$\square$$

## The Corollary

There's also a clean if-and-only-if for single removals.

**Corollary.** _For $$2 \leq k \leq n-2$$, the matroid $$U(k,n) \setminus \{S\}$$ (uniform matroid with one basis removed) is a positroid if and only if $$S$$ is a cyclic interval._

The forward direction is the theorem. The backward direction: if $$S$$ is not a cyclic interval, then every cyclic interval $$\{j, \ldots, j+k-1\}$$ is still a basis, so the Grassmann necklace satisfies $$I_j = \{j, \ldots, j+k-1\}$$ for all $$j$$. Since every $$k$$-subset Gale-dominates the Gale-minimum, $$S$$ passes all $$n$$ Gale conditions and $$S \in \mathcal{R}$$. But $$S \notin \mathcal{B}$$, so $$\mathcal{R} \neq \mathcal{B}$$ and the matroid is not a positroid.

The corollary is a complete characterization for single-removal matroids. The converse of the main theorem is false for multi-removal: I found 58 positroids with non-interval non-bases out of 2,793 trials.

{% endraw %}
![Single-removal dichotomy on U(3,6)]({{site.url}}/images/positroid-fig4-corollary.png)

_**Figure 4.** All 20 three-element subsets of $$[6]$$, each shown as a mini-circle with the selected elements highlighted. Green subsets are cyclic intervals: removing them from $$U(3,6)$$ gives a positroid. Red subsets are non-intervals: removing them gives a non-positroid. The corollary says this dichotomy is exact._
{% raw %}

## Computational Verification

Each proof step was checked independently for all parameters up to $$n = 9$$:

- **Gale-minimality**: The cyclic interval $$\{j,\ldots,j+k-1\}$$ is verified to be the Gale-minimum $$k$$-subset in order $$\leq_j$$ for all $$(n,k,j)$$ with $$n \leq 8$$.
- **Key lemma**: Every cyclic-interval non-basis is excluded from $$\mathcal{R}$$ by failing the Gale condition at its starting index — verified for 130 cases.
- **Over-inclusion mechanism**: 128 cases found where non-interval non-bases _survive_ Gale reconstruction (are in $$\mathcal{R}$$ but not in $$\mathcal{B}$$), confirming this is how non-positroids arise.
- **Full theorem**: Exhaustively verified for 255 matroids formed by removing all possible subsets of cyclic intervals from $$U(k,n)$$ for $$(n,k)$$ up to $$(9,3)$$ and $$(8,4)$$.
- **Single-removal dichotomy**: Perfect 766/766 for all $$n \leq 9$$, $$k \leq 5$$.

## Worked Examples

To make the proof concrete, here are four cases that illustrate the mechanism.

**$$U(2,4) \setminus \{0,1\}$$ — positroid.** The non-basis $$\{0,1\}$$ is a cyclic interval starting at $$j=0$$. In order $$\leq_0$$, it's the Gale-minimum 2-subset. Since it's not a basis, $$I_0 = \{0,2\} \neq \{0,1\}$$. Check: does $$\{0,1\} \geq_0 \{0,2\}$$? Comparing second elements: $$1 < 2$$. Fails. So $$\{0,1\} \notin \mathcal{R}$$, and the matroid is a positroid.

**$$U(2,4) \setminus \{0,2\}$$ — _not_ a positroid.** The non-basis $$\{0,2\}$$ is _not_ a cyclic interval (gap between 0 and 2). Since $$\{0,2\}$$ isn't any cyclic interval, every interval $$\{j,j+1\}$$ is a basis, so $$I_j = \{j,j+1\}$$ for all $$j$$. Then $$\{0,2\}$$ Gale-dominates all of them, so $$\{0,2\} \in \mathcal{R}$$ but $$\{0,2\} \notin \mathcal{B}$$. Not a positroid.

**$$U(3,5) \setminus \{0,1,2\}$$ — positroid.** The non-basis $$\{0,1,2\}$$ is a cyclic interval starting at $$j=0$$. It's the Gale-minimum 3-subset in $$\leq_0$$, so $$I_0 \neq \{0,1,2\}$$ implies the Gale condition fails. Excluded from $$\mathcal{R}$$, positroid confirmed.

**$$U(3,5) \setminus \{0,2,4\}$$ — _not_ a positroid.** This is the canonical counterexample from the search. $$\{0,2,4\}$$ is spread with gaps, not a cyclic interval. The necklace is $$I_j = \{j,j+1,j+2\}$$ for all $$j$$, and $$\{0,2,4\}$$ Gale-dominates all of them. So $$\{0,2,4\} \in \mathcal{R}$$ but $$\notin \mathcal{B}$$. Not a positroid.


# Open Questions

**The dynamical conjecture.** Does gradient descent on TP-weight networks always produce cyclic-interval non-basis patterns? By the theorem, this is equivalent to asking whether trained TP networks always yield positroid activation matroids. The answer may connect to gradient flow geometry on the TP manifold.

**The non-TP baseline.** Does gradient descent on _unconstrained_ weight networks also produce only positroid matroids? If yes, TP structure is irrelevant and the phenomenon is purely about training dynamics. If no, then TP structure and training dynamics are jointly responsible — the most interesting case.

**Multi-removal characterization.** The theorem gives a sufficient condition (all non-bases are cyclic intervals implies positroid). The 58 positroids with non-interval non-bases show this is not necessary in general, but it _is_ necessary and sufficient for single removal. What is the right characterization for multi-removal?

**Higher rank.** All experiments used $$d=2$$ (rank-3 matroids). Higher-rank regimes may exhibit richer matroid structure. Multi-parameter TP constructions via the Loewner-Whitney factorization would enable testing in $$d \geq 5$$.


# Summary

I conjectured that TP-weight ReLU networks always produce positroid activation matroids, supported the conjecture with 800+ trials, disproved it by constructing 12,642 counterexamples, discovered a clean dichotomy between contiguous and spread non-basis patterns, proved a theorem explaining the dichotomy, and reformulated the conjecture as a statement about the implicit bias of gradient-based training. The revised conjecture — that trained TP networks only visit positroid matroids because gradient descent avoids non-interval non-basis patterns — connects positroid combinatorics to a central question in deep learning theory.

{% endraw %}
