module Common.Rest exposing (..)

import Common.Types exposing (User, userDecoder)
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


fetchUser : (Result Http.Error User -> msg) -> Cmd msg
fetchUser createUser =
    let
        url =
            "/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send createUser
