---
title: "Use a Custom Column Name With a belongs_to Association in Rails"
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Options for belongs_to",
      url: "https://guides.rubyonrails.org/association_basics.html#options-for-belongs-to-foreign-key",
    },
  ]
date: 2019-08-12
---

Imagine an application with the following relationships:

- A `user` model which `has_many` `jobs` through a `jobs_project_managers` join table.
- A `job` model which `has_many` `users` through a `jobs_project_managers` join table.
- A `jobs_project_manager` model connecting the `job` and `user` models.

Default Rails conventions would create a `users` method on a `Job` instance. However, there may be times when you want to customize the column name to be more expressive. In my case, I want a `Job` to have a `project_managers` method instead. This would still associate a `job` with a `user` model, but it reads better.

In order to achieve this, you'll want to use the `class_name` and `foreign_key` options for the `belongs_to` method. Rails Guides provides an [example of how to use these options](https://guides.rubyonrails.org/association_basics.html#options-for-belongs-to-foreign-key). Essentially this allows you to create a custom name for the association, but tells Rails to refer to both the `User` class and the `user_id` column.

## Before

### Models

```ruby
class User < ApplicationRecord
  has_many :jobs_project_managers, dependent: :destroy
  has_many :jobs, through: :jobs_project_managers
end
```

```ruby
class Job < ApplicationRecord
  has_many :jobs_project_managers, dependent: :destroy
  has_many :users, through: :jobs_project_managers
end
```

```ruby
class JobsProjectManager < ApplicationRecord
  belongs_to :user
  belongs_to :job
end
```

### Factories

```ruby
FactoryBot.define do
  factory :jobs_project_manager do
    user
    job
  end
end
```

## After

### Models

```ruby
class User < ApplicationRecord
  has_many :jobs_project_managers, dependent: :destroy
  has_many :jobs, through: :jobs_project_managers
end
```

```ruby
class Job < ApplicationRecord
  has_many :jobs_project_managers, dependent: :destroy
  has_many :project_managers, through: :jobs_project_managers
end
```

```ruby
class JobsProjectManager < ApplicationRecord
  belongs_to :project_manager, class_name: "User", foreign_key: "user_id"
  belongs_to :job
end
```

### Factories

```ruby
FactoryBot.define do
  factory :jobs_project_manager do
    association :project_manager, factory: :user
    job
  end
end
```
