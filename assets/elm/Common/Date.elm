module Common.Date exposing (dateToString)

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format exposing (formatUtc, isoDateFormat, utcIsoString)


dateToString : Date -> String
dateToString =
    formatUtc config isoDateFormat
