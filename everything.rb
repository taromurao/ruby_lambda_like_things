def foo
  yield
end

def greet
  puts :hello
end

f = proc { 1 }
g = proc { 2 }

# Experiment
# Can we pass a proc to a method wich takes a block?

foo(proc { 1 })
# methods.rb:1:in `foo': wrong number of arguments (1 for 0) (ArgumentError)

foo(&proc { 1 })
# => 1

# Expeiment
# It seems that the '&' in the method definition has no incluence

# Experiment
# Then how can we pass a proc to a method as a block?

foo(&f)
# => 1

# Experiment
# We declare a method which takes an argument and append '&'

def moo(&f)
  f.call
end

moo(proc { 1 })
# => ArgumentError: wrong number of arguments (1 for 0)

moo(&proc { 1 })
# => 1


# Experiment
# It seems that defining a method with arguments expicitly with '&' has not
# effect. '&' in a method definition is just a signal that the argument is a
# block.

moo(&f)
# => 1


# Experiment
# We should be able to do similar thing with a method

def g; 1; end
foo(&:g)
# => ArgumentError: no receiver given

# Experiment
# What is the class of a proc object?

f.class
# => Proc


# Experiment
# Is a lambda proc?

l = -> { 1 }
l.class
# => Proc
# But it has a trace that this object is a lambda
# #<Proc:0x007f911895a168@(irb):60 (lambda)>


# Experiment
# Can we create a method which accepts two procs as its arguments?

def yoo(f, g)
  f.call
  g.call
end

yoo(f, g)
# => 2


# Experiment
# What is a class of method(:a_method)?

method(:foo).class
# => Method


# Experiment
# Can we 'call' a method?

m = method(:greet)
m.call
# => hello


# Questions
#
# 1. What is this Unary &?
#
# In Ruby, '&' has several usages
# 1. Bitwise AND
# 2. Set Intersection. We can use it also with an array, like so
[1, 2, 3] & [2, 3, 4]
# => [2, 3]
# 3. Boolean AND
# 4. The Unary &
# It is almost the equivalent of calling #to_proc on the object, but not quite.
#
# If we pass a method, Ruby does eager-evaluation.
# If we pass a symbol, Ruby interprets that we passed a symbol object.
# If we pass a symbol object prefixed with '&', Ruby fetches the method/proc
# associated to the symbol.

# 2. What are differences between a block, a lambda, Proc object and a Method object?
Proc.ancestors
# => [Proc, Object, Kernel, BasicObject]
Method.ancestors
# => [Method, Object, Kernel, BasicObject]

method(:foo)  # foo is a method
# => #<Method: Object#foo>

method(:f)    # f is a proc
# NameError: undefined method `f' for class `Object'

# Below is a nice example of '&' on Stack Overflow:
# http://stackoverflow.com/questions/1217088/what-does-mapname-mean-in-ruby
class Array
  def to_proc
    proc { |receiver| receiver.send *self }
  end
end

# And then...

[ 'Hello', 'Goodbye' ].map &[ :+, ' world!' ]
#=> ["Hello world!", "Goodbye world!"]

# Additional comments
#
#   Ampersand & works by sending to_proc message on its operand, which, in the
#   above code, is of Array class. And since I defined #to_proc method on
#   Array, the line becomes [ 'Hello', 'Goodbye' ].map { |receiver|
#   receiver.send( :+, ' world!' ) }. Does this answer your question? –  Boris
#   Stitnicky Jul 10 '13 at 11:47  '
#
# Notice that * is the splat operator, which expands an Array into a list of
# arguments
# Thus following two statements are equal:
# method arg1, arg2, arg3
# method *[arg1, arg2, arg3]
# Reference
# http://stackoverflow.com/questions/918449/what-does-the-unary-operator-do-in-this-ruby-code

# A block created with lambda behaves like a method when you use return and
# simply exits the block, handing control back to the calling method.
#
# A block created with Proc.new behaves like it’s a part of the calling method
# when return is used within it, and returns from both the block itself as well
# as the calling method.
#
# Reference
# http://rubymonk.com/learning/books/4-ruby-primer-ascent/chapters/18-blocks/lessons/64-blocks-procs-lambdas

def return_1(f)
  f.call
  1
end

lam = -> { return 2 }
pr = proc { return 2 }
def return_2; 2; end

return_1(lam)
# => 1

return_1(pr)
# LocalJumpError: unexpected return

def zoo
  proc { return 2 }.call
  return 1
end
# => 2

return_1(method(:return_2))
# => 1
# Method object behaves similar to a lambda in this context.

# Lambda also checks the number of passed arguments, which a Proc object does
# not.

foo
# => LocalJumpError: no block given (yield)

method(:foo)
# => #<Method: Object#foo>

f
# => #<Proc:0x007f911909e280@(irb):16>

# It seems that one of main practical differencees between a method object and
# a lambda object is that Ruby by default tries to eagerly-evaluate a method
# object, whele Ruby does not evaluate a proc object, unless explicitly
# provided #call.


# Are there differences in methods?

lambda {}.methods - proc {}.methods
# => []


methodd(:foo).methods - proc {}.methods
# => [:receiver, :name, :owner, :unbind]

proc {}.methods - method(:foo).methods
# => [:yield, :lambda?, :binding, :curry]


# Difference between lambda and proc according to a Stackoverflow article
# Just like methods, lambdas have strict argument checking, whereas non-lambda
# Procs have loose argument checking, just like blocks.
