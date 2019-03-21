---
layout: post
title: "Relationship Between n-Dimensional Planck Length and Gravity in String Theory"
---

{% raw %}

( Note that the following post is a re-upload of one that I wrote for the blog on my old personal website back in 2016 )

String theories have always been interesting to me. The notion that the world's fundamental particles are actually vibration modes in incredibly small objects called "strings" has a rather deep and satisfying appeal. It brings fourth a sort of harmony among all things in the universe (that is, until we begin to talk about branes). However string theory does have many [criticisms and challenges](https://en.wikipedia.org/wiki/String_theory#Criticism). Personally, I find string theory in general to be too young and problematic to parade around as a ToE candidate. Of course I am still only in my undergraduate studies, and expect my stance on the theory to evolve in time. Nonetheless, it is still incredibly interesting and worthy of a post.

# The Planck Unit System

The [Planck length](https://en.wikipedia.org/wiki/Planck_length) $$l_p$$ is commonly considered to be the shortest measurable unit of length for a universe with four ordinary dimensions of spacetime due its value being on many orders of magnitude smaller than length scales that are currently approached by particle accelerators. It is also the length scale at which strings exist in string theory. It forms the basic unit of length in the [Planck Unit System](https://en.wikipedia.org/wiki/Planck_units). Such units are derived from fundamental physical constants. It is easy to derive Planck length $$l_p$$, time $$t_p$$, and mass $$m_p$$ from the fundamental constants $$G$$ (the Newtonian gravitational constant), $$c$$ (the speed of light), and $$\hbar$$ (the reduced Planck constant) whose values are shown below:

$$G \approx 6.67 \times 10^{−11}    (m^3 / kg \cdot s^2)$$

$$c \approx 3 \times 10^8    (m/s)$$

$$\hbar \approx 1.06 \times 10^{−34}    (kg \cdot m^2 / s)$$

Here are the corresponding dimensional analysis equations for the above constants, where $$L$$ is a unit of length, $$T$$ is a unit of time, and $$M$$ is a unit of mass:

$$[G] = \frac{L^3}{M \cdot T^2}$$

$$[c] = \frac{L}{T}$$

$$[\hbar] = \frac{M \cdot L^2}{T}$$

If we wish to create a base system of units based on the fundamental constants, then we can set up the following series of equations relating $$G$$, $$c$$, and $$\hbar$$ to $$l_p$$, $$t_p$$, and $$m_p$$:

$$G = 1 \times \frac{(l_p)^3}{m_p (t_p)^2}$$

$$c = 1 \times \frac{l_p}{t_p}$$

$$\hbar = 1 \times \frac{m_p (l_p)^2}{t_p}$$

By solving the above equations, we find that:

$$l_p \approx 1.61 \times 10^{−35}    (m)$$

$$t_p \approx 5.4 \times 10^{-44}    (s)$$

$$m_p \approx 2.17 \times 10^{-8}    (kg)$$

The solutions for $$l_p$$ and $$t_p$$ seem to make sense, however $$m_p$$ appears to be abnormally large. In fact, it is roughly $$10^19$$ times larger than the mass of a proton! This number turns out to hold its significance as the largest value a point mass with an elementary charge can hold without collapsing into a black hole!

# Beyond 4-Dimensional Spacetime

The calculations above seem to be straightforward, but this definition of Planck length is not accurate for beyond three ordinary spacial dimensions. In fact, for a Newtonian gravitational system of spacetime dimensionality $$D$$, and spacial dimensionality $$d = D − 1$$, the relationship between the force of gravity and the distance $$r$$ from a point mass is:

$$F_g \propto \frac{1}{r^{d - 1}}$$

If we talk about ordinary 4-dimensional spacetime it is clear to see how this compares to Newton's classic inverse-square relation:

$$(D = 4) \implies F_g \propto \frac{1}{r^{3 - 1}} = \frac{1}{r^2}$$

Therefore, the gravitational constant must have different unit-dimensionality depending on the number of spacial dimensions. If we truly want to define the appropriate Planck length for any number of spacial dimensions, we will need to relate it to a generic gravity constant term $$G(D)$$, which is representative of the gravity constant in a particular spacetime dimensionality $$D$$. I will leave that up to the reader to derive ;)

# Sources

* Barton Zwiebach - A First Course in String Theory (Section 1.2 & Sections 3.6 - 3.8)

{% endraw %}
