module Home exposing (..)

import Header.Types
import Header.State
import Header.View
import Html exposing (Html, div, header, main_, program, text)
import Html.Attributes exposing (class)


type alias Model =
    { header : Header.Types.Model
    }


type Msg
    = HeaderMsg Header.Types.Msg


init : ( Model, Cmd Msg )
init =
    let
        model =
            { header = Header.State.initialModel
            }
    in
        model ! [ Cmd.map HeaderMsg Header.State.initialize ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                ( { model | header = headerModel }, Cmd.map HeaderMsg headerCmd )


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
