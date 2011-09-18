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

Instead of:

    user.logged_in && user.admin 
      
Write it more fluently and DRY:

    user.is.logged_in.admin?

###:values

    class Product
      include FluentConditions

      attr_accessor :color

      fluent :color, :values => [:red, :green, :blue]
    end

    product.is.red.or.green?

###:if

    class Product
      include FluentConditions

      attr_accessor :price

      fluent :price, :as => :cheap, :if => lambda {|price| price < 100}
    end

    product.is.cheap?

