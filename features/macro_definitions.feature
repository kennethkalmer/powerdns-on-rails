Example: Test the database operations of macros
Test the impact different types have on existing and non-existing records
Test the interpolation of %ZONE% in content

Scenario: Macro to create records
Given I have a domain
Given I have a macro
And the macro "creates" an "A" record for "www" with "127.0.0.1"
When I apply the macro
Then the domain should have an "A" record for "www" with "127.0.0.1"

Scenario: Macro to create interpolated records
Given I have a domain named "example.com"
Given I have a macro
And the macro "creates" a "CNAME" record for "ghs" with "%ZONE%.googleapps.com"
When I apply the macro
Then the domain should have a "CNAME" record for "ghs" with "example.com.googleapps.com"

Scenario: Macro to update existing records
Given I have a domain
And the domain has an "A" record for "www" with "127.0.0.1"
Given I have a macro
And the macro "updates" an "A" record for "www" with "127.0.0.2"
When I apply the macro
Then the domain should have an "A" record for "www" with "127.0.0.2"
And the domain should not have an "A" record for "www" with "127.0.0.1"

Scenario: Macro to update existing records with zone interpolation
Given I have a domain named "example.com"
And the domain has a "CNAME" record for "ghs" with "something.googleapps.com"
Given I have a macro
And the macro "updates" a "CNAME" record for "ghs" with "%ZONE%.googleapps.com"
When I apply the macro
Then the domain should have a "CNAME" record for "ghs" with "example.com.googleapps.com"

Scenario: Macro to remove existing records
Given I have a domain
And the domain has an "A" record for "www" with "127.0.0.1"
Given I have a macro
And the macro "removes" an "A" record for "www"
When I apply the macro
Then the domain should not have an "A" record for "www"

Scenario: Macro to remove all records by type
Given I have a domain
And the domain has an "A" record for "www" with "127.0.0.1"
And the domain has an "A" record for "ftp" with "127.0.0.2"
Given I have a macro
And the macro "removes" an "A" record for "*"
When I apply the macro
Then the domain should not have an "A" record for "www"
And the domain should not have an "A" record for "ftp"

Scenario: Macro to update non-existing records
Given I have a domain
Given I have a macro
And the macro "updates" an "A" record for "www" with "127.0.0.1"
When I apply the macro
Then the domain should not have an "A" record for "www"

Scenario: Macro to remove non-existing records
Given I have a domain
Given I have a macro
And the macro "removes" an "A" record for "www"
When I apply the macro
Then the domain should not have an "A" record for "www"

Scenario: Macro to create/update existing records
Given I have a domain
And the domain has an "A" record for "www" with "127.0.0.1"
Given I have a macro
And the macro "creates_updates" an "A" record for "www" with "127.0.0.2"
When I apply the macro
Then the domain should have an "A" record for "www" with "127.0.0.2"

Scenario: Macro to create/update non-existing records
Given I have a domain
Given I have a macro
And the macro "creates_updates" an "A" record for "www" with "127.0.0.1"
When I apply the macro
Then the domain should have an "A" record for "www" with "127.0.0.1"

Scenario: Macro to create multiple records of the same kind
Given I have a domain
Given I have a macro
And the macro "creates" an "MX" record with "mail" with priority "10"
And the macro "creates" an "MX" record with "backup" with priority "20"
When I apply the macro
Then the domain should have an "MX" record with priority "10"
And the domain should have an "MX" record with priority "20"
