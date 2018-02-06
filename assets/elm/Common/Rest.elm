module Common.Rest exposing (..)

import Http exposing (Body, Request, expectJson, request)
import Json.Decode exposing (Decoder)


put : String -> Body -> Decoder a -> Request a
put url body decoder =
    request
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
