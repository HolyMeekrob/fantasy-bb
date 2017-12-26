module Profile exposing (..)

import Html exposing (Html, div, program, text)
import Http exposing (get)
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias Model =
    { firstName : String
    , lastName : String
    }


getInitialModel : Model
getInitialModel =
    { firstName = "Unknown"
    , lastName = "Unkown"
    }


type Msg
    = SetProfile (Result Http.Error Model)


fetchProfile : Cmd Msg
fetchProfile =
    let
        url =
            "http://localhost:4000/api/account/user"
    in
        Http.get url profileDecoder
            |> Http.send SetProfile


profileDecoder : Decoder Model
profileDecoder =
    decode Model
        |> required "firstName" string
        |> required "lastName" string


init : ( Model, Cmd Msg )
init =
    ( getInitialModel, fetchProfile )


view : Model -> Html Msg
view model =
    div
        []
        [ text model.firstName ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetProfile (Err _) ->
            ( { model | firstName = "Error", lastName = "Error" }, Cmd.none )

        SetProfile (Ok newModel) ->
            ( { model | firstName = newModel.firstName, lastName = newModel.lastName }, Cmd.none )


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
