module Profile exposing (..)

import Html exposing (Html, div, program, text)
import Http exposing (get)
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, optional, required)


type alias Model =
    { firstName : String
    , lastName : String
    , email : String
    , bio : String
    }


getInitialModel : Model
getInitialModel =
    { firstName = "Unknown"
    , lastName = "Unkown"
    , email = "Unknown"
    , bio = "Unknown"
    }


type Msg
    = SetProfile (Result Http.Error Model)


fetchProfile : Cmd Msg
fetchProfile =
    let
        url =
            "http://localhost:4000/ajax/account/user"
    in
        Http.get url profileDecoder
            |> Http.send SetProfile


profileDecoder : Decoder Model
profileDecoder =
    decode Model
        |> required "firstName" string
        |> required "lastName" string
        |> required "email" string
        |> optional "bio" string "No bio"


init : ( Model, Cmd Msg )
init =
    ( getInitialModel, fetchProfile )


view : Model -> Html Msg
view model =
    div
        []
        [ div
            []
            [ text <| fullName model ]
        , div
            []
            [ text model.email ]
        , div
            []
            [ text model.bio ]
        ]


fullName : Model -> String
fullName user =
    user.firstName ++ " " ++ user.lastName


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetProfile (Err _) ->
            ( { model | firstName = "Error", lastName = "Error" }, Cmd.none )

        SetProfile (Ok newModel) ->
            ( { model
                | firstName = newModel.firstName
                , lastName = newModel.lastName
                , email = newModel.email
                , bio = newModel.bio
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
