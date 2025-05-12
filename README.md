# Dagraph

Dagraph is a gem which allows you to represent DAG hierarchy using your ActiveRecord models.
With a directed acyclic graph, you can represent hierarchical data where children may have multiple parents.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add dagraph

To add a DAG to a model, you can use the generator:

```
bin/rails generate dagraph:model {MODEL_NAME}
```

It will add the required line to your model, create the file for the edges model and the required migration.

## Usage

After setting up a DAG in one of your model, the following methods are available to use the DAG:

| Method name | Description |
| ----------- | ----------- |
| Model.roots | Get all objects without a parent |
| Model.leaves | Get all objects without a child |
| Model#parents | Get all parents (direct or not) attached to your object |
| Model#children | Get all children (direct or not) attached to your object |
| Model#parent\_edges | Get all parent edges attached to your object, this method return instances from your edge class |
| Model#child\_edges | Get all children edges attached to your object, this method return instances from your edge class |
| Model#direct\_parents | Get all direct parents attached to your object |
| Model#direct\_children | Get all direct children attached to your object |
| Model#direct\_parent\_edges | Get all direct parent edges attached to your object, this method return instances from your edge class |
| Model#direct\_child\_edges | Get all direct children edges attached to your object, this method return instances from your edge class |
| Model#parent\_of?(node) | Check if your object is a parent of the node |
| Model#child\_of?(node) | Check if your object is a child of the node |
| Model#direct\_parent\_of?(node) | Check if your object is a direct parent of the node |
| Model#direct\_child\_of?(node) | Check if your object is a direct child of the node |
| Model#childdren\_at\_depth(depth) | Get all children of your object at a specific depth |
| Model#root? | Check if your object is at the root of your tree (it has no parent) |
| Model#child? | Check if your object is not at the root of your tree (it has one or more parents) |
| Model#leaf? | Check if your object is a leaf in your tree (it has no child) |

You can add parents or children to your objects by using the `direct_parents` and `direct_children` associations:
```ruby
# Define all parents for your model
model.direct_parents = [node]

# Add one parent to your model
model.direct_parents << node

# Remove one parent for your model
model.direct_parents.destroy(node)

# Define all children for your model
model.direct_children = [node]

# Add one parent to your model
model.direct_children << node

# Remove one child for your model
model.direct_children.destroy(node)

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Useful links about DAG

https://www.codeproject.com/Articles/22824/A-Model-to-Represent-Directed-Acyclic-Graphs-DAG-o#Figure2
https://arxiv.org/pdf/2211.11159
https://www.baeldung.com/cs/dag-applications

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gdott9/dagraph.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
