# README

This is an example project created for BizzyCar's interview process.

## Challenge Summary

St Charles Automotive would like to begin taking service reservations over the phone. Their current software does not allow them to capture all of the information in a single step, so would like to build a custom solution.

## Requirements

Construct a simple reservation API, that allows an agent to capture customer information, vehicle information, and secure a time slot. Feel free to use any gems that compliment your solution. Additionally include a readme file in your delivery, should include instructions on how to setup and run your project and unit tests that demonstrate functionality.

You do not need to construct a UI, this is intended to be an assessment of your back end skills. As for time commitment, we will leave that up to you. Please deliver a solution in a zipped folder to us when you finish.
We are leaving the details intentionally vague, curious to see the assumptions you make and how you interpret the requirements.

## Installation

### Getting Ruby

To run this project you'll need to install ruby 2.5.0, a compatible rubygems version and bundler to install all the other dependencies. 

I'd recommend using rvm or rbenv to install ruby and rubygems, since these let you switch between ruby versions for different projects

To get rvm installed, you can use most modern package managers like npm or homebrew to install it for you or you can grab it directly via curl. 

Go to https://rvm.io/rvm/install for more info on rvm.
Or https://github.com/rbenv/rbenv for info on rbenv. 

Assuming you have rvm installed (since I do), run this to install the ruby version you need:

```bash
rvm install 2.5.0 
```

Once you're in the directory for this project you can use this to show currently installed and used ruby versions. 

```bash
rvm list
```

### Installing Gems

With ruby 2.5.0 and rubygems installed you can run grab bundler and then have bundler install the dependencies you need.

```bash
gem install bundler
bundle install
```

### Database Setup

To set up your database after bundler installed your gems, use this:

```bash
rake db:create
rake db:migrate
```

This project uses postgresql for its database, but you should be able to change database.yml and the Gemfile if you want to use something else. 

### Usage

Now you can run the local server to test things via localhost:3000 or run the rspec unit tests to make sure everything is working properly

```bash
rails s #run server
rspec #run tests
```