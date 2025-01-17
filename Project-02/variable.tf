variable "nba_api_key" {
  type = string
  description = "this is an npa api key to interact with sports data api"
  sensitive = true
}
# variable "sns_topic_arn" {
#   type = string
#   description = "this is an sns arn"
#   sensitive = true
# }

variable "email_subscriber" {
  type = string
  description = "this will be subscriber email."
}