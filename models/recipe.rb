require 'pry'

class Recipe

  attr_reader :id, :name, :instructions, :description

  def initialize(recipe)
    @id = recipe["id"]
    @name = recipe["name"]
    @instructions = recipe["instructions"]
    @description = recipe["description"]
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    db_recipe_hashes = db_connection do |conn|
      conn.exec("
        SELECT *
        FROM recipes
      ")
    end

    db_recipe_hashes.map do |recipe|
      Recipe.new(recipe)
    end
  end

  def self.find(id)
    selected_recipe = nil
    all.each do |recipe|
      if recipe.id == id
        selected_recipe = recipe
      end
    end
    selected_recipe
  end

  def ingredients
    db_ingredients = db_connection do |conn|
      conn.exec("
          SELECT ingredients.name
          FROM ingredients
          JOIN recipes
          ON ingredients.recipe_id = recipes.id
          WHERE recipes.id = #{id}
        ")
    end
    recipe_ingredients = db_ingredients.map do |ingredient|
      Ingredient.new(ingredient["name"])
    end
    recipe_ingredients
  end

end
