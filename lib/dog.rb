class Dog
attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
end

def self.create_table
    sql = "CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );"
        DB[:conn].execute(sql)
end

def self.drop_table
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
end

def save
    if self.id
        self.update
    else
        sql = "INSERT INTO dogs(name, breed) VALUES (?, ?);"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
end

def self.create(hash)
    new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
    hash.each do |key, value|
        new_dog.class.attr_accessor key
        new_dog.send("#{key}=", value)
    end
    new_dog.save
end

def self.new_from_db(row)
    new_dog = self.new(id: row[0],name: row[1], breed: row[2])
end

def self.find_by_id(id) 
    sql = "SELECT * FROM dogs WHERE dogs.id = ?;"
    array = DB[:conn].execute(sql, id)[0]
    Dog.new(id: array[0], name: array[1], breed: array[2])
end

def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"

    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
        dog = self.create(name: name, breed: breed)
    end
    dog
end

def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE dogs.name = ?;"
    array = DB[:conn].execute(sql, name)[0]
    Dog.new(id: array[0], name: array[1], breed: array[2])
end

def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end