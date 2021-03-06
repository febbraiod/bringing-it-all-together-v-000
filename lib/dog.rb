require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id = nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
        SQL

    DB[:conn].execute(sql)
  end

  def save

    if !self.id
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?,?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      self.update
    end

  end

  def self.create(name:, breed:)

    Dog.new(name: name, breed: breed).tap do |dog|
      dog.save
    end

  end

  def self.new_from_db(row)
    Dog.new(row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = (?)
      SQL

    Dog.new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = (?) and breed = (?)
      SQL

    row = DB[:conn].execute(sql, name, breed)[0]

    if row != nil
      self.find_by_id(row[0])
    else
      self.create(name: name, breed: breed)
    end

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = (?) LIMIT 1
      SQL

    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

end