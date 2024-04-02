# @summary API configuration
type Vas::API::Config = Array[
  Struct[
    url        => Stdlib::HttpsUrl,
    token      => Optional[String[1]],
    ssl_verify => Optional[Boolean],
  ]
]
