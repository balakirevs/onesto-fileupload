# Onesto::Fileupload

Library for handling file uploads with json only apis.

## Installation

```ruby
gem 'onesto-fileupload'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onesto-fileupload

## Usage

Create a controller that includes Onesto::Fileupload::Controller module and add
create and destroy routes for the controller.

In controllers that need those uploaded files, add
```ruby
include Onesto::Fileupload::UploadedFiles
```

and retrieve uploaded files by using
```ruby
uploaded_file({id: <uploaded_file_id>})
```
