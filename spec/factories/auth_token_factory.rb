Factory.define(:auth_token) do |f|
  f.token '5zuld3g9dv76yosy'
  f.permissions({
    'policy' => 'deny',
    'new' => false,
    'remove' => false,
    'protected' => [],
    'protected_types' => [],
    'allowed' => [
      ['example.com', '*'],
      ['www.example.com', '*']
    ]
  })
  f.expires_at 3.hours.since
end
