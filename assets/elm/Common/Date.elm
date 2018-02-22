module Common.Date exposing (date, dateToString)

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format exposing (formatUtc, isoDateFormat, utcIsoString)
import Json.Decode as Decode exposing (Decoder)


dateToString : Date -> String
dateToString =
    formatUtc config isoDateFormat


date : Decoder Date
date =
    Decode.andThen stringToDateDecoder Decode.string


stringToDateDecoder : String -> Decoder Date
stringToDateDecoder str =
    case Date.fromString str of
        Err _ ->
            Decode.fail ("Invalid date format: " ++ str)

        Ok date ->
            Decode.succeed date
