---
layout: post
title: "The Hidden Geometry of ReLU Networks"
---
{% raw %}

Every [ReLU](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)) neural network secretly draws lines through space. A single-hidden-layer network with $$H$$ hidden neurons and $$d$$-dimensional input creates $$H$$ hyperplanes — flat boundaries that slice the input space into regions. On each side of a hyperplane, a neuron is either "on" (positive) or "off" (clipped to zero). The network's decision boundary is built from these cuts.

I've been studying the combinatorial structure of these [hyperplane arrangements](https://en.wikipedia.org/wiki/Arrangement_of_hyperplanes) — specifically, which subsets of hyperplanes are in "general position" and which aren't. The results were surprising: a natural conjecture held across 800+ training runs, was shattered by deliberate construction, and the failure revealed a clean mathematical pattern that I was able to prove as a theorem.

{% endraw %}
This post tells that story. For the full technical details including proofs, see the [companion post]({{site.url}}/p/positroid-structure-relu-networks).
{% raw %}


# Lines, Planes, and Independence

Think about drawing lines in 2D. Two random lines will cross at a single point — they're _independent_. But two lines that happen to be parallel, or two copies of the same line, are _dependent_ — they don't carry as much geometric information as you'd expect from two lines.

Now consider three lines. If they all pass through the same point, they're dependent in a specific way — any two of them are fine, but the triple has a coincidence. If no three meet at a point, all triples are independent.

This notion of "which subsets are independent?" is exactly what a [**matroid**](https://en.wikipedia.org/wiki/Matroid) captures. A matroid is a combinatorial structure that records which subsets of a collection are independent, subject to some natural axioms (if a set is independent, so are all its subsets; if you have two independent sets of different sizes, you can extend the smaller one). Matroids show up all over mathematics — in linear algebra, graph theory, and geometry — because they abstract the common pattern underlying all of these.

For a ReLU network, the "collection" is the set of $$H$$ hyperplanes from the hidden layer. The matroid records which subsets of hyperplanes are in general position (independent) and which have unexpected coincidences (dependent). The **rank** of the matroid is $$d + 1$$ for a $$d$$-dimensional input — the maximum number of hyperplanes that can be mutually independent.

A subset of $$d + 1$$ hyperplanes is called a **basis** if those hyperplanes are in general position. If they have a coincidence — if they all share a common point — that subset is a **non-basis**. The set of all bases completely determines the matroid.

{% endraw %}
![Independence vs dependence]({{site.url}}/images/positroid-fig-independence.png)

_**Figure 1.** Three lines in 2D. Left: general position — the lines form a triangle, with each pair meeting at a different point. Every triple is a basis. Right: all three lines pass through the same point (red dot) — a coincidence. This triple is a non-basis._
{% raw %}


# Positroids: Matroids with Circular Symmetry

Not all matroids are created equal. Some have extra structure that makes them especially well-behaved.

Imagine placing the $$H$$ hyperplane labels $$\{0, 1, \ldots, H-1\}$$ around a circle, like hours on a clock. A [**positroid**](https://arxiv.org/abs/math/0609764) is a matroid whose combinatorial structure is compatible with this circular ordering in a precise sense. Positroids were discovered by [Alexander Postnikov](https://math.mit.edu/~apost/) in his study of the [_totally nonnegative Grassmannian_](https://en.wikipedia.org/wiki/Grassmannian), a beautiful geometric object from algebraic geometry, and they turn out to have remarkably clean combinatorial descriptions.

The key property for us is that positroids are exactly the matroids that arise from [**totally positive (TP) matrices**](https://en.wikipedia.org/wiki/Totally_positive_matrix) — matrices where every square submatrix has nonnegative determinant. TP matrices show up naturally in neural networks when you parameterize the weight matrix using kernels like:

$$W_{ij} = \exp(a_i \cdot b_j) \qquad \text{or} \qquad W_{ij} = \frac{1}{a_i + b_j}$$

Both of these produce TP matrices by classical results. So the question becomes: if a ReLU network's weight matrix is totally positive, does the resulting hyperplane arrangement always have positroid structure?


# 800 Trials: The Conjecture

I trained single-hidden-layer ReLU networks with TP-constrained weights across a range of configurations: multiple datasets, both kernel types, hidden dimensions from 4 to 16, and input dimensions from 2 to 5.

Over **800 trials, every matroid was a positroid**. Zero counterexamples.

There was a caveat, though. Most trials produced _uniform_ matroids — matroids where every subset of the right size is a basis, meaning all hyperplane subsets are in general position. A uniform matroid is automatically a positroid (there are no non-bases to violate anything), so most trials didn't really test the conjecture.

Non-trivial positroids — ones with actual non-bases — appeared mainly with 2D input and the exponential kernel. There, up to half the trials produced matroids with rich structure: hundreds of bases, non-trivial dependency patterns. And every one was a positroid.

{% endraw %}
![TP-weight ReLU network on two-moons]({{site.url}}/images/positroid-fig1-hyperplanes.png)

_**Figure 2.** A TP-weight ReLU network trained on the two-moons dataset. The 8 lines are the hyperplanes from the hidden layer. Together they define a matroid of rank 3 on 8 elements. In this case every triple of lines is in general position (the matroid is uniform), so it's trivially a positroid._
{% raw %}


# Breaking the Conjecture

Rather than run more training experiments, I decided to attack the conjecture directly.

The key insight is that a ReLU network's hyperplane arrangement depends on both the **weights** (which determine the directions of the hyperplanes) and the **biases** (which determine their positions). Total positivity constrains the weights, but places _no constraint on the biases_. The biases are free parameters.

Making a specific subset of hyperplanes dependent requires satisfying just one linear equation on the biases for that subset. This is easy to do by construction.

{% endraw %}
![Bias shift creates dependency]({{site.url}}/images/positroid-fig-bias-shift.png)

_**Figure 3.** How biases create dependencies. Left: three lines in general position — all triples are bases. Right: the same line directions (same weights), but line 2 shifted upward (bias changed) so all three meet at one point (red dot). One linear equation on the biases is all it takes._
{% raw %}

I ran 16,820 targeted trials: pick a TP weight matrix, then deliberately choose biases to create specific dependency patterns. The result: **12,642 counterexamples**. The conjecture is false.

The smallest counterexample has just 5 hyperplanes in 2D. Pick _any_ TP weight matrix and choose biases so that hyperplanes $$\{0, 2, 4\}$$ — the 1st, 3rd, and 5th — are dependent. The resulting matroid (9 out of 10 possible bases) is not a positroid.

But the counterexamples had a pattern. Every one involved making a **spread** subset dependent — a subset whose elements have gaps when arranged around the circle. When I tried making **contiguous** subsets dependent — subsets that form an unbroken arc on the circle — the matroid was always a positroid.


# Contiguous vs Spread: The Pattern

This is the crucial distinction. Arrange the hyperplane labels $$\{0, 1, \ldots, H-1\}$$ around a circle. A subset is a **cyclic interval** if its elements form a contiguous arc — like $$\{2, 3, 4\}$$ on a clock. A subset is **spread** if there are gaps — like $$\{0, 2, 4\}$$.

{% endraw %}
![Non-basis patterns on the circle]({{site.url}}/images/positroid-fig2-intervals.png)

_**Figure 4.** The two types of non-basis on a circle of 6 elements. Left: $$\{2,3,4\}$$ is a cyclic interval — contiguous on the circle. Making it a non-basis preserves the positroid property. Right: $$\{0,2,4\}$$ is spread — gaps between the elements. Making it a non-basis can break the positroid property._

![Counterexample dichotomy]({{site.url}}/images/positroid-fig3-dichotomy.png)

_**Figure 5.** Results from 2,793 TP network trials, classified by non-basis structure. Left: when all non-bases are cyclic intervals, the matroid is always a positroid (433 out of 433). Right: when any non-basis is spread, the matroid is usually not a positroid (747 out of 805)._
{% raw %}

The dichotomy is sharp. Across 2,793 trials:

- **All non-bases are cyclic intervals**: 433 positroids, 0 non-positroids.
- **Some non-basis is spread**: 58 positroids, 747 non-positroids.

And here's the punchline: across all 800+ _training_ trials, [gradient descent](https://en.wikipedia.org/wiki/Gradient_descent) only ever produced cyclic-interval non-basis patterns. It never created a spread dependency. The original conjecture held for trained networks — not because of any algebraic property of TP matrices, but because training dynamics avoid the "bad" patterns.


# The Theorem

The zero in the left column of Figure 5 isn't a coincidence. It's a theorem.

**Theorem.** _If every non-basis of a matroid is a cyclic interval, then the matroid is a positroid._

The intuition is this: a cyclic interval like $$\{j, j+1, \ldots, j+k-1\}$$ is, in a precise sense, the "first $$k$$ elements" when you start counting from position $$j$$ around the circle. Positroids are characterized by a reconstruction procedure that builds the matroid by looking at the first basis in each of $$n$$ cyclic orderings. When a non-basis is a cyclic interval, it's exactly the set that this reconstruction procedure checks first at one of its starting positions — and because it's not a basis, the procedure correctly excludes it. But when a non-basis is spread, it can slip through the reconstruction filter at every starting position, creating an inconsistency that breaks the positroid property.

{% endraw %}
(The full proof uses the _Grassmann necklace_ characterization of positroids. See the [technical post]({{site.url}}/p/positroid-structure-relu-networks) for details.)
{% raw %}

There's also a clean if-and-only-if for the simplest case:

**Corollary.** _Start with the uniform matroid (every subset is a basis) and remove a single subset. The result is a positroid if and only if that subset is a cyclic interval._

This was verified exhaustively for all parameters up to $$n = 9$$.

{% endraw %}
![Single-removal dichotomy on U(3,6)]({{site.url}}/images/positroid-fig4-corollary.png)

_**Figure 6.** All 20 three-element subsets of $$[6]$$, each shown as a mini-circle. Green: cyclic intervals — removing them from the uniform matroid gives a positroid. Red: non-intervals — removing them gives a non-positroid. The corollary says this split is exact._
{% raw %}


# What This Means

The original conjecture — TP weights imply positroid structure — is false. But something more interesting is true: **training dynamics on TP-weight networks only produce positroid matroids**, and the theorem explains why. The non-basis patterns that would break positroid structure (spread dependencies) are precisely the ones that gradient descent never creates.

This shifts the question from algebra to dynamics. The revised conjecture is:

> _For TP-weight networks trained by gradient descent on binary classification, the affine matroid is always a positroid — because training only produces cyclic-interval non-basis patterns._

If true, this connects positroid combinatorics to the _implicit bias_ of gradient descent, a central topic in deep learning theory. Gradient descent is known to favor certain solutions over others (low-rank matrices, max-margin classifiers). The claim here is that it also favors solutions with clean combinatorial geometry.


# Open Questions

**Does TP structure matter?** If unconstrained (non-TP) trained networks also produce only positroids, then the phenomenon is entirely about training dynamics. If unconstrained networks sometimes produce non-positroids, then TP structure and training dynamics are jointly responsible — the most interesting case.

**Why does training avoid spread patterns?** There should be a geometric reason why gradient flow on the TP manifold only creates contiguous dependency patterns. Understanding this could reveal new structural properties of trained networks.

**What happens with deeper networks?** All experiments used single-hidden-layer networks. Multi-layer networks compose multiple hyperplane arrangements, and the interaction between layers could produce richer matroid structure.

---

All experiment code is available at [github.com/HarrisonTotty/positroid-structure-relu-networks](https://github.com/HarrisonTotty/positroid-structure-relu-networks).

{% endraw %}
