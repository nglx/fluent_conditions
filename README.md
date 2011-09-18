#Fluent Conditions
Simplify your conditional expressions.

##Installation
    gem install fluent_conditions

##Examples

###Basic usage with boolean fields

    class User
      include FluentConditions

      attr_accessor :admin, logged_in

      fluent :admin
      fluent :logged_in
    end

    user = User.new
    user.admin = true
    user.logged_in = true

And instead of:

    user.logged_in && user.admin

Write it more fluently and DRY:

    user.is.logged_in.admin? #=> true

User class with FluentConditions module included provides *is* method and *is_not* method as well. It returns negated result of an expression. As an expression methods you may also use negated versions of *admin* and *logged_in* methods - *not_admin*, *not_logged_in*.

*and* method is optional and in fact it does nothing except increasing readability in some cases.

    user.is_not.logged_in.admin? #=> false
    user.is.logged_in.and.not_admin? #=> false

Only last method in expression should be followed by question mark.

###:values

This option defines a set of expression methods. It may be useful for fields with limited set of possible values:

    class Product
      include FluentConditions

      attr_accessor :color

      fluent :color, :values => [:red, :green, :blue]
    end

    product = Product.new
    product.color = :red
    product.is.red? # => true

You can also use *or operator* in expressions:

    product.is.red.or.green? #=> true
    product.is.blue.or.green? #=> false

*or operator* can be placed anywhere between two expression methods and it affects only them.

So in the case below:

    product.is.red.green.or.blue?

Expression will be interpreted like:

    product.color == :red && (product.color == :green || product.color == :blue)

###:if

The :if option allows you to define custom methods checking some conditions:

    class Product
      include FluentConditions

      attr_accessor :price

      fluent :price, :as => :cheap, :if => lambda {|price| price < 100}
    end

    product = Product.new
    product.price = 1000
    product.is.cheap? #=> false

###OR

With *big OR* you can build even more complex expressions. The difference between *OR* and *or* is how expression will be interpreted.

For instance if we had a Fruit class with :name and :color attributes, each having some set of possible values, we could write expression like:

    fruit.is.red.apple.OR.yellow.banana?

This expression would be interpreted like:
    
    (fruit.color == :red && fruit.name == :apple) || (fruit.color == :yellow && fruit.name == :banana)
