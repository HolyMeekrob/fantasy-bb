module Home exposing (..)

import Common exposing (User)
import Header.Types
import Header.State
import Header.View
import Html exposing (Html, div, header, main_, program, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias Model =
    { header : Header.Types.Model
    }


type Msg
    = HeaderMsg Header.Types.Msg
    | SetUser (Result Http.Error User)


init : ( Model, Cmd Msg )
init =
    let
        model =
            { header = Header.State.initialModel
            }
    in
        ( model, fetchUser )


fetchUser : Cmd Msg
fetchUser =
    let
        url =
            "http://localhost:4000/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send SetUser


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "firstName" string
        |> required "lastName" string
        |> required "avatar" string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                ( { model | header = headerModel }, Cmd.map HeaderMsg headerCmd )

        SetUser (Err _) ->
            { model | header = Nothing } ! []

        SetUser (Ok user) ->
            { model | header = Just user } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div
        [ class "wrapper" ]
        [ header
            [ class "header" ]
            [ Html.map HeaderMsg <| Header.View.view model.header ]
        , main_
            [ class "content" ]
            [ text "Home page" ]
        ]


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
