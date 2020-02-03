# XCResult

[![Twitter: @joshdholtz](https://img.shields.io/badge/contact-@joshdholtz-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/trainer/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/xcresult.svg?style=flat)](http://rubygems.org/gems/trainer)

Ruby interface for inspecting data and exporting data from Xcode 11 `.xcresult` files

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xcresult'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xcresult

## Roadmap

- [x] Allow for easy querying of test plan summaires
- [x] Allow for easy exporting of `.xccovreport` files
- [ ] Allow for exporting of screenshots
- [ ] Add full documentation on all classes and methods
- [ ] Add more and better explain examples
- [ ] Add tests and improved code coverage

## Usage

### Export .xccovreport files from .xcresult

```rb
parser = XCResult::Parser.new(path: 'YourProject.xcresult')
export_xccovreport_paths = parser.export_xccovreports(destination: './outputs')
```

### Get test plan summaries from .xcresult

```rb
parser = XCResult::Parser.new(path: 'YourProject.xcresult')
summaries = parser.action_test_plan_summaries
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/xcresult.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
