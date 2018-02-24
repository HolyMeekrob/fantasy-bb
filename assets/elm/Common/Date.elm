module Common.Date exposing (date, dateToString, encodeDate)

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format exposing (formatUtc, isoDateFormat, utcIsoString)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


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


encodeDate : Date -> Encode.Value
encodeDate =
    Encode.string << dateToString
