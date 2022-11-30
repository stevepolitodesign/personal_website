---
title: "Create Dependent Associations in FactoryBot"
categories: ["Ruby on Rails"]
resources: [
    {
        title: "Transient Attributes",
        url: "https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#transient-attributes"
    },
    {
        title: "Stack Overflow Question",
        url: "https://stackoverflow.com/questions/8820114/get-two-associations-within-a-factory-to-share-another-association/8864452#8864452"
    },
    {
        title: "Github Issue: Dependent Associations",
        url: "https://github.com/thoughtbot/factory_bot/issues/426"
    },
    {
        title: "Github Issue: Improve support for interrelated model associations?",
        url: "https://github.com/thoughtbot/factory_bot/issues/1063"  
    }
]
date: 2019-08-14
---

Imagine the following set of models and relationships: 

A `user` can add a `time_entry` to a `job`. The `time_entry` has a `task`, and that `task` has a `rate` which depends upon the `job`. So I need to validate that the associated `time_entry` on a `job` is associated with a `rate` that is also associated with that `job`. Basically, I want to make sure the correct `rate` is being applied to the `job`.

## Models

```ruby
class TimeEntry < ApplicationRecord
  belongs_to :job
  belongs_to :user
  belongs_to :task

  validates :job_id, inclusion: { in: :associated_rates_jobs }, unless: Proc.new { |time_entry| time_entry.task.nil? || time_entry.job.nil? }

  private

    def associated_rates_jobs
      @associated_rates_jobs = self.task.rates.where(job: self.job, task: self.task).map { |rate| rate.job_id }
    end

end
```

```ruby
class Rate < ApplicationRecord
  belongs_to :task
  belongs_to :job
end
```

```ruby
class Task < ApplicationRecord
    has_many :time_entries, dependent: :destroy
    has_many :rates, dependent: :destroy
    has_many :jobs, through: :rates
end
```

```ruby
class Job < ApplicationRecord
    has_many :time_entries, dependent: :destroy
    has_many :rates, dependent: :destroy
    has_many :tasks, through: :rates
end
```

I was able to configure this validation in my `TimeEntry` model using the custom `associated_rates_jobs` method. However, this made building valid factories really difficult. I needed my `time_entry` factory to be associated with a `rate` that shared the same `job`.

In order to do this, I used [Transient Attributes](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#transient-attributes).

> 
Transient attributes will be ignored within attributes_for and won't be set on the model, even if the attribute exists or you attempt to override it.

I added a transient attribute to create a `rate` from my `rate` Factory. Then, I used the values from that attribute to dynamically assign the values for the `job` and `task` attributes.

## Factories

### Before

```ruby
FactoryBot.define do
  factory :time_entry do    
    job
    task
  end
```

### After

```ruby{3-7}
FactoryBot.define do
  factory :time_entry do
    transient do
      rate { create(:rate) }
    end
    job { rate.job }
    task { rate.task }
  end
```