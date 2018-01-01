module Common exposing (..)

import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, optional, required)


type alias User =
    { firstName : String
    , lastName : String
    , email : String
    , bio : String
    , avatarUrl : String
    }


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "firstName" string
        |> required "lastName" string
        |> required "email" string
        |> optional "bio" string "No bio"
        |> required "avatar" string
