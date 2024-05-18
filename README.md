# rdeadman

`rdeadman` is a network monitoring tool for monitoring the availability of multiple hosts. This gem periodically pings specified hosts and displays the results in real-time.

## Installation

First, install the `rdeadman` gem.

```sh
gem install rdeadman
```

## Usage
### Basic Usage
1. Create a configuration file (e.g., hosts.conf) with the hosts you want to monitor.
```
# hosts.conf
google.com
example.com
8.8.8.8
```

2. Run the command to start monitoring the hosts.
```sh
rdeadman hosts.conf
```

3. To specify the interval (in seconds) between checks, provide it as the second argument.
```sh
rdeadman hosts.conf 10
```

### Configuration File Example
List the hosts you want to monitor, one per line. You can add comments using the # symbol.
```
# hosts.conf
# Comments: Monitoring the following hosts
google.com
example.com
8.8.8.8
```

## Development
To contribute to this project, follow these steps:
1. Fork the repository.
2. Clone your forked repository locally.
```sh
git clone https://github.com/takuan517/rdeadman.git
```
3. Install the dependencies.
```sh
bundle install
```
4. Create a new branch for your changes.
```sh
git checkout -b my-feature-branch
```
5. Commit your changes and push them to your forked repository.
```sh
git commit -m "Add my new feature"
git push origin my-feature-branch
```
6. Create a pull request.

## Testing
Run the tests using RSpec.
```sh
bundle exec rspec
```

## License
This project is licensed under the MIT License. See the LICENSE file for details.
