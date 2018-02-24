module Common.Rest exposing (encodeMaybe, fetch, userRequest, put)

import Common.Types exposing (User)
import Http exposing (Body, Request, expectJson, request)
import Json.Decode exposing (Decoder, bool, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode


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


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "firstName" string
        |> required "lastName" string
        |> required "email" string
        |> optional "bio" string ""
        |> required "avatar" string
        |> optional "isAdmin" bool False


userRequest : Request User
userRequest =
    Http.get "/ajax/account/user" userDecoder


fetch : Request a -> (Result Http.Error a -> msg) -> Cmd msg
fetch request create =
    Http.send create request


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder val =
    Maybe.withDefault
        Encode.null
        (Maybe.map encoder val)
