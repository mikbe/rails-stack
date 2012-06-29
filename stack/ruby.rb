package :ruby do
  description "Ruby (RVM)"

  requires :ruby_core, :rvm, :rvm_ruby_19, :bundler
end

package :ruby_core do
  requires :ruby_dependencies

  apt 'ruby-full rubygems'

  verify do
    has_executable 'ruby'
    has_executable 'irb'
    has_executable 'rdoc'
    has_executable 'ri'
    has_executable 'gem'
  end
end

package :ruby_dependencies do
  requires :build_essential
  apt 'build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev autoconf'
end

# == RVM: References
#   - http://blog.ninjahideout.com/posts/a-guide-to-a-nginx-passenger-and-rvm-server
#   - http://blog.ninjahideout.com/posts/the-path-to-better-rvm-and-passenger-integration
#   - http://rvm.beginrescueend.com/integration/passenger
#   - http://rvm.beginrescueend.com/deployment/best-practices/
#   - http://rvm.beginrescueend.com/workflow/scripting

package :rvm do
  description "RVM - Ruby Version Manager"

  requires :ruby_core, :git

  apt 'ruby-full' do
    # Install RVM.
    post :install, 'curl -s https://rvm.beginrescueend.com/install/rvm -o rvm-installer'
    post :install, 'chmod +x rvm-installer'
    post :install, './rvm-installer --version latest'
    post :install, 'rvm reload'

    # Add user to rvm group (root added already by RVM installer).
    post :install, %Q{adduser rails rvm}
  end

  verify do
    # Ensure RVM binary was setup properly: should be a function, not a executable.
    has_file '/usr/local/bin/rvm'

    # Ensure RVM is sourced in ~/.profile.
    ['/etc/skel', '/root', "/home/rails"].each do |path|
      has_file "#{path}/.profile"
    end
  end
end

package :rvm_ruby_19 do
  description "Ruby 1.9.3"
  version '1.9.3-p194'

  requires :rvm

  noop do
    # Install Ruby 1.9.
    pre :install, 'rvm install 1.9.3-p194'
    post :install, 'rvm default 1.9.3-p194'
  end

  verify do
    has_executable '/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/ruby'
  end
end


package :rvm_rubygems do
  description "Rubygems for Ruby 1.9.3"

  requires :rvm_ruby_19

  noop do
    pre :install, 'rvm rubygems latest'
  end

  verify do
    has_executable '/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/gem'
  end
end

package :bundler do
  description "Bundler - Ruby dependency manager"
  requires :rvm_rubygems
  noop { pre :install, 'rvm gem install bundler' }
  verify { has_executable '/usr/local/rvm/gems/ruby-1.9.3-p194/bin/bundle' }
end

