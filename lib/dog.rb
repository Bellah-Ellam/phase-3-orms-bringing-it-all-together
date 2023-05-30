class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
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
      sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
    end
  
    def save
      if self.id
        update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
  
    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    end
  
    def self.new_from_db(row)
      id, name, breed = row
      Dog.new(id: id, name: name, breed: breed)
    end
  
    def self.all
      sql = "SELECT * FROM dogs"
      DB[:conn].execute(sql).map do |row|
        new_from_db(row)
      end
    end
  
    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
      row = DB[:conn].execute(sql, name).first
      row ? new_from_db(row) : nil
    end
  
    def self.find(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      row = DB[:conn].execute(sql, id).first
      row ? new_from_db(row) : nil
    end
  
    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  
    # Optional Bonus Methods
  
    def self.find_or_create_by(name:, breed:)
      dog = find_by_name(name)
      dog ||= create(name: name, breed: breed)
    end
  end
  