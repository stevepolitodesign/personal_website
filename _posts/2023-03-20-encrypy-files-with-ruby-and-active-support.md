---
title: "How to encrypt files with Ruby and Active Support"
excerpt: "
  Password managers aren't the only way to store and share sensitive
  information. Learn how to create a simple CLI for encrypting files.
  "
categories: ["Ruby"]
tags: ["Security", "Command Line"]
---

In this tutorial, we will create a Ruby binstub that allows you to encrypt and
decrypt files using Active Support's [EncryptedFile][1] module. This script is
particularly useful for those who need to protect sensitive information within
their files.

**Use Cases**

- Encrypt text files in open source projects so that they can be committed to
  your repository without exposing sensitive information.
- Storing credentials in an encrypted file, similar to [Rails Custom
  Credentials][2].
- Taking secure personal notes.

## Required Libraries

The script starts with the following lines, which load the required libraries
and set up the command line argument handling.

```ruby
#!/usr/bin/env ruby
require "active_support/encrypted_file"
require "securerandom"
```

These lines import the necessary Ruby modules:
[active_support/encrypted_file][1] for encryption and decryption, and
[securerandom][3] for key generation

## Parsing Arguments

The script expects one of three commands as the first argument: `setup`,
`write`, or `read`. If no command is provided, the script will print an error
message and exit.

```ruby
command = ARGV.shift

if command.nil?
  puts "Please pass 'setup', 'write [FILE]', or 'read [FILE]'"
  exit 1
end
```

## Helper Methods

The following `build_encrypted_file` method creates an instance of
`ActiveSupport::EncryptedFile` with the necessary configuration options.

```ruby
def build_encrypted_file(file)
  ActiveSupport::EncryptedFile.new(
    content_path: file,
    key_path: "invisible_ink.key",
    env_key: "INVISIBLE_INK_KEY",
    raise_if_missing_key: true
  )
end
```

Next, we have two helper methods: `handle_missing_key` and
`handle_missing_file_argument`. These methods print error messages and exit the
script if a key or a file is missing, respectively.

## Executing the Commands

The `case` statement is the main part of the script, handling the three possible
commands: `write`, `read`, and `setup`.

### Encrypting a File

For the `write` command, the script ensures that a file argument is provided
and that a system editor is available to open the file. It then creates a new
encrypted file if it does not exist and opens the file in the system editor for
editing. When the editor is closed, the encrypted file is saved with the new
content.

```ruby
when "write"
  file = ARGV.shift
  handle_missing_file_argument if file.nil?
  if ENV["EDITOR"].to_s.empty?
    puts "No $EDITOR to open file in"
    exit 1
  end
  begin
    encrypted_file = build_encrypted_file(file)
    encrypted_file.write(nil) unless File.exist?(file)
    encrypted_file.change do |tmp_path|
      system(ENV["EDITOR"], tmp_path.to_s)
    rescue Interrupt
      puts "File not saved"
    end
  rescue ActiveSupport::EncryptedFile::MissingKeyError => error
    handle_missing_key(error)
  end
```

### Decrypting a File

For the `read` command, the script ensures that a file argument is provided and
then attempts to read the encrypted file, printing the decrypted contents to the
standard output.

```ruby
when "read"
  begin
    file = ARGV.shift
    handle_missing_file_argument if file.nil?
    encrypted_file = build_encrypted_file(file)
    puts encrypted_file.read
  rescue ActiveSupport::EncryptedFile::MissingKeyError => error
    handle_missing_key(error)
  end
```

### The Setup Script

Finally, the `setup` command generates a new encryption key and saves it to a
file named `invisible_ink.key`. It also adds the key file to the `.gitignore`
file to prevent it from being accidentally committed to a version control
system.

```ruby
when "setup"
  if File.exist?("invisible_ink.key")
    puts "ERROR: invisible_ink.key already exists"
    exit 1
  else
    File.open(".gitignore", "a") { |file| file.puts("invisible_ink.key") }
    key = ActiveSupport::EncryptedFile.generate_key
    File.write("invisible_ink.key", key)
    puts "invisible_ink.key generated"
  end
```

## The Final Script

By using this script, you can protect sensitive information from unauthorized
access and maintain the privacy of your data. With the `setup`, `write`, and
`read` commands, you can easily manage the encryption and decryption process,
making it a useful tool for various applications.

As an alternative, you can also use the [invisible_ink][4] gem, which provides
the same functionality as this script, with the added benefit of being easily
integrated into any Ruby project. This gem offers a more streamlined and
maintainable approach to file encryption and decryption in your Ruby
applications, without the need to implement the entire script yourself.

```ruby
#!/usr/bin/env ruby
require "active_support/encrypted_file"
require "securerandom"

# ℹ️ Set the command from the first argument
command = ARGV.shift

# ℹ️ Return early if no command was passed
if command.nil?
  puts "Please pass 'setup', 'write [FILE]', or 'read [FILE]'"
  exit 1
end

# ℹ️ Create an encrypted file instance.
def build_encrypted_file(file)
  ActiveSupport::EncryptedFile.new(
    content_path: file,
    # ℹ️ The key will be generated during the 'setup' script
    key_path: "invisible_ink.key",
    # ℹ️ Alternatively use an environment variable to store the key
    env_key: "INVISIBLE_INK_KEY",
    raise_if_missing_key: true
  )
end

# ℹ️ Handle case where ActiveSupport::EncryptedFile::MissingKeyError is raised
def handle_missing_key(error)
  puts "ERROR: #{error}"
  puts ""
  puts "Did you run 'setup'?"
  exit 1
end

# ℹ️ Handle case where a file was not passed as an argument
def handle_missing_file_argument
  puts "Please pass a file"
  exit 1
end

case command
when "write"
  # ℹ️ Set the file from the second argument
  file = ARGV.shift
  # ℹ️ Ensure the file was passed as an argument
  handle_missing_file_argument if file.nil?
  # ℹ️ Return early if there is no system editor to edit the file
  if ENV["EDITOR"].to_s.empty?
    puts "No $EDITOR to open file in"
    exit 1
  end
  begin
    encrypted_file = build_encrypted_file(file)
    # ℹ️ Writing a blank file creates the file in cases where it does not yet
    # exist. We need a file before we can write to it.
    encrypted_file.write(nil) unless File.exist?(file)
    # ℹ️ Open the file in the system $EDITOR using a temporary path
    encrypted_file.change do |tmp_path|
      system(ENV["EDITOR"], tmp_path.to_s)
    # ℹ️ Handle case where the $EDITOR is closed before the file was saved
    rescue Interrupt
      puts "File not saved"
    end
  # ℹ️ Print message to user if the key is missing
  rescue ActiveSupport::EncryptedFile::MissingKeyError => error
    handle_missing_key(error)
  end
when "read"
  begin
  # ℹ️ Set the file from the second argument
    file = ARGV.shift
  # ℹ️ Ensure the file was passed as an argument
    handle_missing_file_argument if file.nil?
    encrypted_file = build_encrypted_file(file)
    # ℹ️ Print decrypted file contents to $STDOUT
    puts encrypted_file.read
  # ℹ️ Print message to user if the key is missing
  rescue ActiveSupport::EncryptedFile::MissingKeyError => error
    handle_missing_key(error)
  end
when "setup"
  # ℹ️ Return early if there is already a key
  if File.exist?("invisible_ink.key")
    puts "ERROR: invisible_ink.key already exists"
    exit 1
  else
    # ℹ️ Prevent key from being saved to version control
    File.open(".gitignore", "a") { |file| file.puts("invisible_ink.key") }
    # ℹ️ Generate key
    key = ActiveSupport::EncryptedFile.generate_key
    # ℹ️ Write the key to a file
    File.write("invisible_ink.key", key)
    puts "invisible_ink.key generated"
  end
end
```

[1]: https://github.com/rails/rails/blob/main/activesupport/lib/active_support/encrypted_file.rb
[2]: https://guides.rubyonrails.org/security.html#custom-credentials
[3]: https://rubyapi.org/3.2/o/securerandom
[4]: https://github.com/stevepolitodesign/invisible_ink
