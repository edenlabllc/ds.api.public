use Mix.Config

config :synchronizer_crl, SynchronizerCrl.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "kM4g3grYc77xl0Zglf381h8g6EgOBSH18TbWwMB1UCdWHxFFkIZcF8Ci3w9ZtLCF"

# Configures Elixir's Logger
config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

config :phoenix, :format_encoders, json: Jason

# Configure crl scheduler
config :synchronizer_crl, SynchronizerCrl.CrlService,
  retry_crl_timeout: 60_000,
  preload_crl: ~w(
    http://uakey.com.ua/list.crl
    http://uakey.com.ua/list-delta.crl

    http://acsk.privatbank.ua/crldelta/PB-Delta-S9.crl
    http://acsk.privatbank.ua/crl/PB-S9.crl
    http://acsk.privatbank.ua/crldelta/PB-Delta-S11.crl
    http://acsk.privatbank.ua/crl/PB-S11.crl

    http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Full.crl
    http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Delta.crl

    https://ca.informjust.ua/download/crls/CA-E7E53376-Delta.crl
    https://ca.informjust.ua/download/crls/CA-AD24A7C9-Delta.crl
    https://ca.informjust.ua/download/crls/CA-9A15A67B-Delta.crl
    https://ca.informjust.ua/download/crls/CA-5358AA45-Delta.crl
    https://ca.informjust.ua/download/crls/CA-AD24A7C9-Full.crl
    https://ca.informjust.ua/download/crls/CA-5358AA45-Full.crl
    https://ca.informjust.ua/download/crls/CA-9A15A67B-Full.crl
    https://ca.informjust.ua/download/crls/CA-E7E53376-Full.crl

    http://canbu.bank.gov.ua/download/crls/CANBU-RSA-2018-Delta.crl
    http://canbu.bank.gov.ua/download/crls/CANBU-DSTU-2017-Delta.crl
    http://canbu.bank.gov.ua/download/crls/CANBU-RSA-2018-Full.crl
    http://canbu.bank.gov.ua/download/crls/CANBU-DSTU-2017-Full.crl

    https://csk.uss.gov.ua/download/crls/CSKUSS2017-Full.crl
    https://csk.uss.gov.ua/download/crls/CSKUSS2017-Delta.crl
    https://csk.uss.gov.ua/download/crls/CSKUSS-Full.crl
    https://csk.uss.gov.ua/download/crls/CSKUSS-Delta.crl

    https://www.masterkey.ua/ca/crls/CA-4E6929B9-Delta.crl
    https://www.masterkey.ua/ca/crls/CA-4E6929B9-Full.crl
    https://www.masterkey.ua/ca/crls/CA-F3E31D2E-Delta.crl
    https://www.masterkey.ua/ca/crls/CA-F3E31D2E-Full.crl

    http://ca.ksystems.com.ua/download/crls/CA-B4F39E7B-Delta.crl
    http://ca.ksystems.com.ua/download/crls/CA-568D7635-Delta.crl
    http://ca.ksystems.com.ua/download/crls/CA-568D7635-Full.crl
    http://ca.ksystems.com.ua/download/crls/CA-B4F39E7B-Full.crl

    http://csk.uz.gov.ua/download/crls/CA-5FA2C5F8-Delta.crl
    http://csk.uz.gov.ua/download/crls/CA-5FA2C5F8-Full.crl
    http://csk.uz.gov.ua/download/crls/CA-59FB69AB-Delta.crl
    http://csk.uz.gov.ua/download/crls/CA-59FB69AB-Full.crl
    http://csk.uz.gov.ua/download/crls/CA-957791B9-Delta.crl
    http://csk.uz.gov.ua/download/crls/CA-957791B9-Full.crl

    http://www.acsk.er.gov.ua/download/crls/CA-Delta.crl
    http://www.acsk.er.gov.ua/download/crls/CA-Full.crl

    http://csk.ukrsibbank.com/download/crls/CA-22335CCC-Delta.crl
    http://csk.ukrsibbank.com/download/crls/CA-22335CCC-Full.crl
    http://csk.ukrsibbank.com/download/crls/CA-7B092570-Delta.crl
    http://csk.ukrsibbank.com/download/crls/CA-C718722D-Delta.crl
    http://csk.ukrsibbank.com/download/crls/CA-7B092570-Full.crl
    http://csk.ukrsibbank.com/download/crls/CA-C718722D-Full.crl
    http://csk.ukrsibbank.com/download/crls/CA-DC220F4D-Delta.crl
    http://csk.ukrsibbank.com/download/crls/CA-DC220F4D-Full.crl

    http://ca.mvs.gov.ua/download/crls/CA-C1CDBEF7-Delta.crl
    http://ca.mvs.gov.ua/download/crls/CA-C1CDBEF7-Full.crl
)

import_config "#{Mix.env()}.exs"
