---
layout: post
title: "Machine Learning With Boolean Networks and the Wolfram Summer School"
---
{% raw %}
In June of 2016 I got the chance to attend the [Wolfram Summer School](https://education.wolfram.com/summer/school/) program held at Bently University in Boston, where I spent three weeks working on a project implementing [machine learning via Boolean networks](https://education.wolfram.com/summer/school/alumni/2016/totty/). It was breath of fresh air from the "less-technical" environment I was used to in Florida, and a _lot_ of fun. I met some of the smartest people I've ever had the pleasure of working with. This article will be one-part my experience at the Wolfram Summer school and one-part delving into the technical details of my final project.


# Application

I was originally encouraged by my Differential Equations professor to apply to the summer school program back in 2015. I was actually in the middle of writing [my own computer algebra system](https://github.com/HarrisonTotty/Simplex.Math) at the time (a project that was ultimately abandoned) - from an inspiration to write the _C#_ equivalent to [sympy](https://www.sympy.org/en/index.html) and [Mathematica](https://www.wolfram.com/mathematica/). So I sent in my resume, filled out a questionnaire, sat in on an interview, and was eventually given a copy of Mathematica and a set of practice questions. Here's an example practice question:

> Use `GalaxyData` and machine learning to produce a classification function for galactic shape based on apparent magnitudes and redshift.

I remember stressing over them quite a bit, with the assumption that not completing all of them would put me "behind the curve" compared to the other students. I was the only one from a "community college", so I figured completing all of the questions would be the best way to "prove myself". Yet irony has a funny way of shattering expectations - it turned out that I was the only student who completed all 34 questions (they were just _practice_ questions after all, not some "competition") - not to say that the other students weren't _able_ to complete the other questions, but they just figured a dozen or so questions was enough "practice".


# Machine Learning with Boolean Networks

## Network Architecture

When I spoke with Stephen Wolfram about my project, we ended-up deciding that I should "implement machine learning and classification using only networks of elementary Boolean functions". What that statement _actually meant_ however, was up to me. I went through several different iterations of the overall architecture but eventually decided on emulating a flat, feed-forward neural network where each layer is composed of Boolean functions for neurons. The outputs of each Boolean function are passed to the next layer via a sort-of "cross hatch" pattern with wrapped boundary conditions.

Let's look at an example network which accepts a one-dimensional Boolean vector of length $$n = 8$$ and contains $$l = 4$$ internal layers:

![figure 1](https://education.wolfram.com/summer/assets/alumni/2016/harrison-totty-fig1.png)

In the above figure we can see how the individual components of the input are passed into the first layer. Note that the number of neurons in each layer alternate between $$n - 1$$ and $$n$$ - a decision that was entirely empirical based on the results of earlier networks.

## Accuracy Determination

The accuracy of a particular class of elements is defined to be the fraction of the inputs of a particular class which produce the same output over the total number of training examples within that class. Similarly, the overall accuracy of the network is determined by partitioning the test data into collections of the same class and evaluating the accuracy of each class separately.

## Training

The process of training the network involves a Monte-Carlo approach by randomly selecting a neuron in the network and replacing its Boolean function with a new random Boolean function of two inputs. Again, empirical analysis of earlier iterations of the project suggested that the middle layers of the network are the most important to the training process. To capitalize on this, the network selects neurons based on a truncated normal distribution with mean centered at $$l/2$$ and a default standard deviation of $$l/4$$.

At each iteration of training, the network randomizes a particular number of neurons (usually just one) and then performs and accuracy check of the new network against the provided set of training data. If the mean accuracy of this new network is larger than the initial network _whilst maintaining a discrete output count greater than or equal to the number of training classes_, the previous network is replaced with the new iteration. This process is repeated for a specified maximum iteration count _or when the mean accuracy of the network meets or exceeds some given goal_.

## Basic Example

Returning to our example from the _Network Architecture_ section, let's say that we aim to create a network to classify a series of binary-valued vectors of length $$n = 8$$ into three possible classifications _A_, _B_, and _C_, based on whether the occurrence of "true" values in a particular vector are on the "left" half of the vector, the "right" half of the vector, or distributed between both halves of the vector. Let's start by defining some training data and some test data:

```
training = {
{1,1,0,0,0,0,0,0} -> "A", {1,1,1,0,0,0,0,0} -> "A", {0,1,0,0,0,0,0,0} -> "A", {1,1,1,0,0,0,0,0} -> "A",
{0,1,1,1,0,0,0,0} -> "A", {1,1,1,1,0,0,0,0} -> "A", {1,1,0,1,0,0,0,0} -> "A", {0,1,0,1,0,0,0,0} -> "A",
{1,0,0,0,0,0,0,0} -> "A", {0,0,0,1,0,0,0,0} -> "A", {0,0,0,0,0,0,0,1} -> "B", {0,0,0,0,0,1,1,0} -> "B",
{0,0,0,0,0,0,1,0} -> "B", {0,0,0,0,0,1,1,1} -> "B", {0,0,0,0,1,0,1,0} -> "B", {0,0,0,0,0,1,0,0} -> "B",
{0,0,0,0,0,0,1,1} -> "B", {0,0,0,0,1,1,1,0} -> "B", {0,0,0,0,0,0,1,1} -> "B", {0,0,0,0,1,1,1,1} -> "B",
{1,0,0,0,0,0,0,1} -> "C", {1,0,1,0,0,1,1,0} -> "C", {1,0,0,1,0,0,1,0} -> "C", {0,1,1,0,0,1,1,1} -> "C",
{1,1,1,1,1,0,1,0} -> "C", {0,1,1,0,0,1,0,0} -> "C", {0,0,0,1,0,0,1,1} -> "C", {0,1,0,0,1,1,1,0} -> "C",
{1,0,0,1,0,0,1,1} -> "C", {0,0,1,0,1,1,1,1} -> "C", {1,1,1,1,1,1,1,1} -> "C", {1,0,1,0,1,0,1,0} -> "C"
};

test = Table[RandomInteger[1, 8], 10];
```

Now lets create a new network of $$l = 4$$ which expects an input vector of length $$n = 8$$:

```
net = BooleanNetwork[8, 4];
```

Let's looks at how accurate the network is initially:

```
AccuracyInfo[net, training]
```

(output):

```
Mean Accuracy               : 0.3167
Accuracy Standard Deviation : 0.0764
Number Of Classes           : 3
Distinct Output Count       : 3
Class Accuracies            : {A -> 0.4000, B -> 0.3000, C -> 0.2500}
Output Classifications      : {{0,1,1,1,0,0,0,0} -> A, {0,0,0,0,1,1,1,0} -> B, {1,1,1,1,1,1,1,1} -> C}
```

That's actually not that bad for a random starting point! Now let's train the network and re-test our accuracy:

```
{net, changed} = Train[net, training];

AccuracyInfo[net, training]
```

(output):

```
Mean Accuracy               : 1.0000
Accuracy Standard Deviation : 0.0000
Number Of Classes           : 3
Distinct Output Count       : 3
Class Accuracies            : {A -> 1.0000, B -> 1.0000, C -> 1.0000}
Output Classifications      : {{0,1,0,0,1,1,0,0} -> A, {1,0,0,0,1,1,1,1} -> B, {1,1,0,0,1,1,1,1} -> C}
```

Note that content of the _actual vector_ returned as an output from an iteration is _not important_. The only thing that matters is that there are only 3 unique outputs. Also note that `changed` contains information about how often each neuron was modified during the training process. Using this data, we can create a "heat map" over the network, which might look something like this:

![figure 2](https://education.wolfram.com/summer/assets/alumni/2016/harrison-totty-fig2.png)

In the above figure, we can see that the neurons at locations `{1,4}`, `{2,1}`, `{2,7}`, and `{3,4}` were changed the most.

Let's try re-classifying all of the training data (note that the `Classify` function here replaces the built-in one):

```
Table[
    Classify[net, training[[i, 1]]],
    {i, Length[training[[All, 1]]]}
]
```

(output):

```
{"A","A","A","A","A","A","A","A","A","A","B","B","B","B","B","B","B","B","B","B","C","C","C","C","C","C","C","C","C","C","C","C"}
```

Finally, let's test the network against some new data:

```
Table[
    test[[i]] -> Classify[net,test[[i]]],
    {i, Length[test]}
]
```

(output):

```
{
{1,1,1,1,0,1,1,1} -> "C",
{0,1,1,0,0,1,0,0} -> "C",
{0,1,1,0,0,1,0,1} -> "C",
{1,1,0,1,1,0,0,0} -> Undefined,
{1,1,1,0,1,1,1,1} -> "C",
{0,1,0,1,0,1,0,1} -> "C",
{1,0,1,0,0,1,1,0} -> "C",
{1,0,0,1,1,0,0,1} -> "C",
{1,0,1,1,0,0,0,0} -> "A",
{0,1,0,0,1,1,0,1} -> "C"
}
```

Here we can see that it chose most of the input vectors to be mapped to _C_, however the network had difficulty classifying `{1,1,0,1,1,0,0,0}`, which should have also classified as _C_. Other than that unknown classification, the ones which were "known" are correct given the original classification goal.

The final neat thing to show is that since our network is actually just a set of repeated Boolean function operations over the input, we can actually "collapse" the entire network into a single pure function expression like so:

```
Simplify[
    EvaluateNetwork[
        net,
        Table[in[i], {i, 8}],
    ]
]
```

(output - replacing `in[i]` with `#i` and converting it into a pure function):

```
netfn = {
    #6 || #7 || #8, 
    #1 || #2 || #3 || #4,
    0,
    0,
    1, 
    ! #5 || #6 || #7 || #8, 
    #6 || #7 || #8,
    #6 || #7 || #8
} &
```

As I concluded in my report:

> It appears as though even relatively small boolean networks can be trained for machine learning applications using simple Monte Carlo techniques. However, the practicality of such architectures is currently unclear given the slow pace of training such networks. For this reason, it is also currently unclear how such networks scale in accuracy with respect to larger input vectors. It could be questioned whether such networks are theoretically capable of learning any input that may be converted to a binary representation. A critical question is whether such networks are capable of training on any data that can be converted to a binary representation. Is the apparent learning only a response to the spatial distribution of features in the input vector? It is also still quite unclear how well boolean networks are capable of accurately training to larger input vectors. Perhaps such networks are only capable of training on small vector spaces and lose accuracy on larger and larger input vectors. Such questions should be addressed upon the formation of improved training techniques ...


# Overall Experience

Like I stated above, overall the program was a lot of fun. Each day I had the opportunity go to several classes of my choosing on everything from machine learning, to physics, to "pure" mathematics. I even ended-up participating in a Wikipedia meetup event at MIT, where I wrote the article on [Privacy Impact Assessments](https://en.wikipedia.org/wiki/Privacy_Impact_Assessment).

{% endraw %}
