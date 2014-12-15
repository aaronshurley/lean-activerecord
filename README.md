# Lean ActiveRecord

In this project, I have implemented my own lean version of ActiveRecord. My goal for this project is to further my understanding of how ActiveRecord actually functions (i.e. how AR translates to SQL).

## Components

### attr_accessor
This component mimics Ruby's 'attr_accessor' method. A simple implementation that defines the getter and setter methods.

### SQLObject
The SQLObject class interacts with the database. This class will implement the follwing 'ActiveRecord::Base' methods:
* '::all': returns an array of all the records in the DB
* '::find': looks up a single record by primary key
* '#insert': inserts a new row into the table
* '#update': updates the row
* '#save': a convenience method that will call 'insert'/'update' appropriately

### Searchable
A module that extends SQLObject to allow the ability to search using '::where'.

### Associatable
A module that extends SQLObject to define the following associations:
* 'belongs_to'
* 'has_many'
* 'has_one_through'